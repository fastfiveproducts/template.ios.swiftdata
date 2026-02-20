//
//  PostsConnector.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/19/26.
//      Template v0.3.1 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//


import Foundation
import FirebaseDataConnect
import DefaultConnector

// Connector Defaults:
fileprivate let defaultFetchLimit: Int = 100

// Services:
struct PostsConnector {

    // MARK: - Public Comments

    func fetchPublicComments(limit: Int = defaultFetchLimit) async throws -> [PublicComment] {
        var comments: [PublicComment] = []
        let queryRef = DataConnect.defaultConnector.listPublicCommentsQuery.ref(appClientKey: ViewConfig.appClientKey, limit: limit)
        let operationResult = try await queryRef.execute()
        comments = try operationResult.data.publicComments.compactMap { firebaseComment -> PublicComment? in
            let comment = try makePublicCommentStruct(from: firebaseComment)
            guard comment.isValid else { throw FetchDataError.invalidCloudData }
            return comment
        }
        return comments
    }

    // MARK: - Private Messages

    func fetchMyPrivateMessages(limit: Int = defaultFetchLimit) async throws -> [PrivateMessage] {
        var messages: [PrivateMessage] = []
        let queryRef = DataConnect.defaultConnector.getMyPrivateMessagesQuery.ref(appClientKey: ViewConfig.appClientKey, limit: limit)
        let operationResult = try await queryRef.execute()
        messages = try operationResult.data.privateMessages.compactMap { firebaseMessage -> PrivateMessage? in
            let message = try makePrivateMessageStruct(from: firebaseMessage)
            guard message.isValid else { throw FetchDataError.invalidCloudData }
            return message
        }
        return messages
    }

    // MARK: - References

    func fetchPublicCommentReferences(for commentId: UUID, limit: Int = defaultFetchLimit) async throws -> [PostReference] {
        var references: [PostReference] = []
        let queryRef = DataConnect.defaultConnector.getPublicCommentReferencesQuery.ref(commentId: commentId, limit: limit)
        let operationResult = try await queryRef.execute()
        references = try operationResult.data.publicCommentReferences.compactMap { firebaseReference -> PostReference? in
            let reference = try makeMessageReferenceStruct(from: firebaseReference)
            guard reference.isValid else { throw FetchDataError.invalidCloudData }
            return reference
        }
        return references
    }
        
    func fetchMyPrivateMessageReferences(limit: Int = defaultFetchLimit) async throws -> [PostReference] {
        var references: [PostReference] = []
        let queryRef = DataConnect.defaultConnector.getMyPrivateMessageReferencesQuery.ref(limit: limit)
        let operationResult = try await queryRef.execute()
        references = try operationResult.data.privateMessageReferences.compactMap { firebaseReference -> PostReference? in
            let reference = try makeMessageReferenceStruct(from: firebaseReference)
            guard reference.isValid else { throw FetchDataError.invalidCloudData }
            return reference
        }
        return references
    }

    func fetchPrivateMessageReferences(for messageId: UUID, limit: Int = defaultFetchLimit) async throws -> [PostReference] {
        var references: [PostReference] = []
        let queryRef = DataConnect.defaultConnector.getPrivateMessageReferencesQuery.ref(messageId: messageId, limit: limit)
        let operationResult = try await queryRef.execute()
        references = try operationResult.data.privateMessageReferences.compactMap { firebaseReference -> PostReference? in
            let reference = try makeMessageReferenceStruct(from: firebaseReference)
            guard reference.isValid else { throw FetchDataError.invalidCloudData }
            return reference
        }
        return references
    }

    // MARK: - Create Mutations

    func createPublicComment(_ comment: PostCandidate) async throws -> PublicComment {
        guard comment.isValid else { throw UpsertDataError.invalidFunctionInput }
        let operationResult = try await DataConnect.defaultConnector.createPublicCommentMutation.execute(
            appClientKey: ViewConfig.appClientKey,
            toUserId: comment.to.uid,
            toUserDisplayNameText: comment.to.displayName,
            createDeviceIdentifierstamp: deviceIdentifierstamp(),
            createDeviceTimestamp: deviceTimestamp(),
            title: comment.title,
            content: comment.content
        )
        let commentId = operationResult.data.publicComment_insert.id
        let localComment = makePublicCommentStruct(from: comment, withId: commentId)
        if !comment.references.isEmpty {
            for rid in comment.references {
                let _ = try await createPublicCommentReference(commentId: commentId, referenceId: rid)
            }
        }
        return localComment
    }
    
    func createPrivateMessage(_ message: PostCandidate) async throws -> PrivateMessage {
        guard message.isValid else { throw UpsertDataError.invalidFunctionInput }
        let operationResult = try await DataConnect.defaultConnector.createPrivateMessageMutation.execute(
            appClientKey: ViewConfig.appClientKey,
            toUserId: message.to.uid,
            toUserDisplayNameText: message.to.displayName,
            createDeviceIdentifierstamp: deviceIdentifierstamp(),
            createDeviceTimestamp: deviceTimestamp(),
            title: message.title,
            content: message.content
        )
        let messageId = operationResult.data.privateMessage_insert.id
        let localMessage = makePrivateMessageStruct(from: message, withId: messageId)
        if !message.references.isEmpty {
            for rid in message.references {
                let _ = try await createPrivateMessageReference(messageId: messageId, referenceId: rid)
            }
        }
        return localMessage
    }

    // MARK: - Reference Mutations

    func createPublicCommentReference(commentId: UUID, referenceId: UUID) async throws {
        let _ = try await DataConnect.defaultConnector.createPublicCommentReferenceMutation.execute(
                    publicCommentId: commentId,
                    referenceId: referenceId
                )
        
    }
    
    func createPrivateMessageReference(messageId: UUID, referenceId: UUID) async throws {
        let _ = try await DataConnect.defaultConnector.createPrivateMessageReferenceMutation.execute(
            privateMessageId: messageId,
            referenceId: referenceId
        )
    }

    // MARK: - Status Mutation

    func createPrivateMessageStatus(messageId: UUID, status: MessageStatusCode) async throws {
        let _ = try await DataConnect.defaultConnector.createPrivateMessageStatusMutation.execute(
            privateMessageId: messageId,
            status: status.rawValue
        )
    }
    
}

// helpers to make local structs:
private extension PostsConnector {
           
    func makePublicCommentStruct(
        from firebaseMessage: ListPublicCommentsQuery.Data.PublicComment
    ) throws -> PublicComment {
        let toUserKey: UserKey = UserKey.init(
            uid: firebaseMessage.toUserId ?? "00000000-0000-0000-0000-000000000000",
            displayName: firebaseMessage.toUserDisplayNameText ?? ""
        )
        return PublicComment(
            id: firebaseMessage.id,
            timestamp: firebaseMessage.createTimestamp.dateValue(),
            from: UserKey.init(uid: firebaseMessage.createUser.id, displayName: firebaseMessage.createUser.displayNameText),
            to: toUserKey,
            title: firebaseMessage.title,
            content: firebaseMessage.content,
            references: []
        )
    }
    
    func makePublicCommentStruct(from postCandidate: PostCandidate, withId createdId: UUID) -> PublicComment {
        return PublicComment(
            id: createdId,
            timestamp: Date(),
            from: postCandidate.from,
            to: postCandidate.to,
            title: postCandidate.title,
            content: postCandidate.content
        )
    }
    
    func makePrivateMessageStruct(
        from firebaseMessage: GetMyPrivateMessagesQuery.Data.PrivateMessage
    ) throws -> PrivateMessage {
        let toUserKey: UserKey = UserKey.init(
            uid: firebaseMessage.toUserId ?? "00000000-0000-0000-0000-000000000000",
            displayName: firebaseMessage.toUserDisplayNameText ?? ""
        )
        return PrivateMessage(
            id: firebaseMessage.id,
            timestamp: firebaseMessage.createTimestamp.dateValue(),
            from: UserKey.init(uid: firebaseMessage.createUser.id, displayName: firebaseMessage.createUser.displayNameText),
            to: toUserKey,
            title: firebaseMessage.title,
            content: firebaseMessage.content,
            references: [],
            status: []
        )
    }
    
    func makePrivateMessageStruct(from postCandidate: PostCandidate, withId createdId: UUID) -> PrivateMessage {
        return PrivateMessage(
            id: createdId,
            timestamp: Date(),
            from: postCandidate.from,
            to: postCandidate.to,
            title: postCandidate.title,
            content: postCandidate.content
        )
    }
    
    func makeMessageReferenceStruct<T>(
        from firebaseReference: T
    ) throws -> PostReference {
        let id: UUID
        let referenceId: UUID
        if let publicComment = firebaseReference as? GetPublicCommentReferencesQuery.Data.PublicCommentReference {
            id = publicComment.publicCommentId
            referenceId = publicComment.referenceId
        } else if let privateMessage = firebaseReference as? GetMyPrivateMessageReferencesQuery.Data.PrivateMessageReference {
            id = privateMessage.privateMessageId
            referenceId = privateMessage.referenceId
        } else if let privateMessage = firebaseReference as? GetPrivateMessageReferencesQuery.Data.PrivateMessageReference {
            id = privateMessage.privateMessageId
            referenceId = privateMessage.referenceId
        } else {
            throw FetchDataError.invalidFunctionInput
        }
        return PostReference(
            id: id,
            referenceId: referenceId)
    }
    
    func makeMessageStatusStruct(
        from firebaseMessageStatus: GetMyPrivateMessageStatusQuery.Data.PrivateMessageStatus
    ) throws -> MessageStatus {
        var status: MessageStatusCode
        if let statusTry = MessageStatusCode(rawValue: firebaseMessageStatus.status) {
            status = statusTry
        } else { status = .error }
        return MessageStatus(
            timestamp: firebaseMessageStatus.createTimestamp.dateValue(),
            uid: firebaseMessageStatus.createUserId,
            status: status
        )
    }

}
