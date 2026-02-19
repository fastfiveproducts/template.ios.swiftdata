//
//  PostStores.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.9 (updated) — Fast Five Products LLC's public AGPL template.
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

final class PublicCommentStore: ListableStore<PublicComment> {

    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = PublicCommentStore()

    override var requiresSignIn: Bool { true }

    // override SignInOutObserver func below to fetch data into the store immediately after sign-in
    override func postSignInSetup() {
        initialize()
        debugprint ("setup after user sign-in")
    }
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [PublicComment] {
        {
            try await PostsConnector().fetchPublicComments()
        }
    }
    
    func createPublicComment(from candidate: PostCandidate) async throws -> PublicComment {
        do {
            let newPost = try await PostsConnector().createPublicComment(candidate)
            insert(newPost)
            return newPost
        } catch {
            debugprint("🛑 ERROR:  Failed to create public comment: \(error)")
            throw error
        }
    }
    
}


final class PrivateMessageStore: ListableStore<PrivateMessage> {

    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = PrivateMessageStore()

    override var requiresSignIn: Bool { true }
    override var requiresRealUser: Bool { true }

    // override SignInOutObserver func below to fetch data into the store immediately after sign-in
    override func postSignInSetup() {
        initialize()
        debugprint ("setup after user sign-in")
    }
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [PrivateMessage] {
        {
            try await PostsConnector().fetchMyPrivateMessages()
        }
    }
    
    func createPrivateMessage(from candidate: PostCandidate) async throws -> PrivateMessage {
        do {
            let newPost = try await PostsConnector().createPrivateMessage(candidate)
            insert(newPost)
            return newPost
        } catch {
            debugprint("🛑 ERROR:  Failed to create private message: \(error)")
            throw error
        }
    }

    // Returns unique conversation partners (users the current user has exchanged messages with),
    // sorted by oldest first so most recent appears at bottom (Messages-style).
    func conversationPartners(for currentUserId: String) -> [(userKey: UserKey, lastMessageDate: Date)] {
        guard case let .loaded(messages) = list else { return [] }

        // Dictionary to track the most recent message timestamp for each partner
        var partnerTimestamps: [String: (userKey: UserKey, timestamp: Date)] = [:]

        for message in messages {
            let partnerKey: UserKey
            if message.from.uid == currentUserId {
                // Current user sent this message, partner is the recipient
                partnerKey = message.to
            } else {
                // Current user received this message, partner is the sender
                partnerKey = message.from
            }

            // Skip blank/invalid users
            guard partnerKey.isValid else { continue }

            // Update if this is a newer message with this partner
            if let existing = partnerTimestamps[partnerKey.uid] {
                if message.timestamp > existing.timestamp {
                    partnerTimestamps[partnerKey.uid] = (partnerKey, message.timestamp)
                }
            } else {
                partnerTimestamps[partnerKey.uid] = (partnerKey, message.timestamp)
            }
        }

        // Sort by oldest first (so newest appears at bottom, Messages-style)
        return partnerTimestamps.values
            .sorted { $0.timestamp < $1.timestamp }
            .map { (userKey: $0.userKey, lastMessageDate: $0.timestamp) }
    }

}

#if DEBUG
extension PublicCommentStore {
    static func testLoaded() -> PublicCommentStore {
        let store = PublicCommentStore()
        store.list = .loaded(PublicComment.testObjects)
        return store
    }
}
#endif

#if DEBUG
extension PrivateMessageStore {
    static func testLoaded() -> PrivateMessageStore {
        let store = PrivateMessageStore()
        store.list = .loaded(PrivateMessage.testObjects)
        return store
    }
}
#endif
