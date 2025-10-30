//
//  HelpTextStore.swift
//
//  Template created by Pete Maiser, July 2024 through October 2025
//      Template v0.2.3 Fast Five Products LLC's public AGPL template.
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

@MainActor
final class HelpTextStore: ListableStore<HelpText> {
    
    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = HelpTextStore()
    
    // enable local cache
    override var cacheFilename: String { "helpTextCache.json" }
    
    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [HelpText] {
        {
            try await HelpTextConnector().fetch()
        }
    }
    
    // MARK: - Convenience
    func text(forCode code: String) -> String? {
        if case let .loaded(objects) = list {
            return objects.first(where: { $0.code == code })?.text
        }
        return nil
    }
}


#if DEBUG
extension HelpTextStore {
    static func testLoaded() -> HelpTextStore {
        let store = HelpTextStore.shared
        store.list = .loaded(HelpText.testObjects)
        store.debugprint("loaded \(store.list.count) test Help Test Codes")
        return store
    }    
}
#endif
