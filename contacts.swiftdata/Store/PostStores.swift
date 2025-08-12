//
//  PostStores.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1 Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
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

final class PublicCommentStore: ListableCloudStore<PublicComment> {
    
    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = PublicCommentStore()
    
    // override SignInOutObserver func below to fetch data into the store immediatey after sign-in
    override func postSignInSetup() {
        fetch()
        debugprint ("setup after user sign-in")
    }
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [PublicComment] {
        {
            // ***** Template functionality:  retrieve data from Firebase Data Connect
            try await PostsConnector().fetchPublicComments()
        }
    }
    
    func createPublicComment(from candidate: PostCandidate) async throws -> PublicComment {
        do {
            // ***** Template functionality:  write data to Firebase Data Connect
            let newPost = try await PostsConnector().createPublicComment(candidate)
            add(newPost)
            return newPost
        } catch {
            debugprint("Failed to create public comment: \(error)")
            throw error
        }
    }
    
}


final class PrivateMessageStore: ListableCloudStore<PrivateMessage> {
    
    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = PrivateMessageStore()
    
    // override SignInOutObserver func below to fetch data into the store immediatey after sign-in
    override func postSignInSetup() {
        fetch()
        debugprint ("setup after user sign-in")
    }
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [PrivateMessage] {
        {
            // ***** Template functionality:  retrieve data from Firebase Data Connect
            try await PostsConnector().fetchMyPrivateMessages()
        }
    }
    
    func createPrivateMessage(from candidate: PostCandidate) async throws -> PrivateMessage {
        do {
            // ***** Template functionality:  write data to Firebase Data Connect
            let newPost = try await PostsConnector().createPrivateMessage(candidate)
            add(newPost)
            return newPost
        } catch {
            debugprint("Failed to create private message: \(error)")
            throw error
        }
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
