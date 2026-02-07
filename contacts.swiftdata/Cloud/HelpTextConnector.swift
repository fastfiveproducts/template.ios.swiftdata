//
//  HelpTextConnector.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
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
import FirebaseDataConnect
import DefaultConnector

// Connector Defaults:
fileprivate let defaultFetchLimit: Int = 1000

// Services:
struct HelpTextConnector {
    func fetch(limit: Int = defaultFetchLimit) async throws -> [HelpText] {
        var list: [HelpText] = []
        let queryRef = DataConnect.defaultConnector.listHelpTextQuery.ref(limit: limit)
        let operationResult = try await queryRef.execute()
        list = try operationResult.data.helpTexts.compactMap { firebaseResultRow in
            try makeHelpTextStruct(from: firebaseResultRow)
        }
        
        return list
    }
}

// helper to make local struct:
private extension HelpTextConnector {
    func makeHelpTextStruct(
        from firebaseResultRow: ListHelpTextQuery.Data.HelpText
    ) throws -> HelpText {
        return HelpText(
            code: firebaseResultRow.code,
            text: firebaseResultRow.text
        )
    }
}

