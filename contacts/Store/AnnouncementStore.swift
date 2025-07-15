//
//  AnnouncementStore.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
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
