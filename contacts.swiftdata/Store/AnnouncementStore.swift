//
//  AnnouncementStore.swift
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

final class AnnouncementStore: ListableCloudStore<Announcement> {
    
    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = AnnouncementStore()
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [Announcement] {
        {
            // ***** Template functionality:  retrieve data from Firestore
            try await FirestoreConnector().fetchAnnouncements()
        }
    }
    
}

#if DEBUG
extension AnnouncementStore {
    static func testLoaded() -> AnnouncementStore {
        let store = AnnouncementStore()
        store.list = .loaded(Announcement.testObjects)
        return store
    }
}
#endif
