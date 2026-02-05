//
//  RestrictedWordConnector.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/5/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
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
//  This connector is to fetch a list of naughty words
//  that can be used to check if a string contains one of those words
//
//  Keywords: bad words, objectional words, swear words, blocked words, restricted text
//
//      Template v0.2.1
//

import Foundation
import FirebaseDataConnect
import DefaultConnector

// Connector Defaults:
fileprivate let defaultFetchLimit: Int = 10000

// Services:
struct RestrictedWordConnector {

    func fetch(limit: Int? = defaultFetchLimit) async throws -> [String] {
        let queryRef = DataConnect.defaultConnector.listRestrictedWordsQuery.ref(limit: limit!)
        let operationResult = try await queryRef.execute()
        return operationResult.data.restrictedWords.map { $0.word }
    }

}
