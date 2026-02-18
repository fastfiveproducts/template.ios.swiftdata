//
//  FeatureFlagStore.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.8 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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
final class FeatureFlagStore: ListableStore<FeatureFlag> {

    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = FeatureFlagStore()

    // no caching — bundled flags (from ViewConfig) are used as the initial placeholder,
    // then the server fetch replaces them. If the server is unreachable, bundled values persist.

    // override ListableStore func below to set how to fetch data into the store
    override var fetchFromService: () async throws -> [FeatureFlag] {
        {
            try await FeatureFlagConnector().fetch()
        }
    }

    // use bundled flags only (no server fetch) for local-only apps
    func initializeWithBundledFlags() {
        if case .loaded = list { return }
        list = .loaded(ViewConfig.bundledFeatureFlags)
        debugprint("loaded \(list.count) Feature Flags from bundle")
    }

    // MARK: - Convenience
    func isEnabled(_ code: String) -> Bool {
        guard case let .loaded(flags) = list else { return false }
        return flags.first(where: { $0.code == code })?.enabled ?? false
    }
}


#if DEBUG
extension FeatureFlagStore {
    static func testLoaded() -> FeatureFlagStore {
        let store = FeatureFlagStore.shared
        store.list = .loaded(FeatureFlag.testObjects)
        store.debugprint("loaded \(store.list.count) test Feature Flags")
        return store
    }
}
#endif
