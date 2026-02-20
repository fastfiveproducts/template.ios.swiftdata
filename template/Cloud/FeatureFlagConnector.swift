//
//  FeatureFlagConnector.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/19/26.
//      Template v0.3.1 (updated)  — Fast Five Products LLC's public AGPL template.
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
import FirebaseDataConnect
import DefaultConnector

// Connector Defaults:
fileprivate let defaultFetchLimit: Int = 100

// Services:
struct FeatureFlagConnector {
    func fetch(limit: Int = defaultFetchLimit) async throws -> [FeatureFlag] {
        var list: [FeatureFlag] = []
        let queryRef = DataConnect.defaultConnector.listFeatureFlagsQuery.ref(appClientKey: ViewConfig.appClientKey, limit: limit)
        let operationResult = try await queryRef.execute()
        list = try operationResult.data.featureFlags.compactMap { firebaseResultRow in
            try makeFeatureFlagStruct(from: firebaseResultRow)
        }

        return list
    }
}

// helper to make local struct:
private extension FeatureFlagConnector {
    func makeFeatureFlagStruct(
        from firebaseResultRow: ListFeatureFlagsQuery.Data.FeatureFlag
    ) throws -> FeatureFlag {
        return FeatureFlag(
            code: firebaseResultRow.code,
            enabled: firebaseResultRow.enabled
        )
    }
}
