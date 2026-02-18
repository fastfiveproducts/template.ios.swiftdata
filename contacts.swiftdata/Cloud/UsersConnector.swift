//
//  UsersConnector.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/17/26.
//      Template v0.2.7 (updated) — Fast Five Products LLC's public AGPL template.
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
fileprivate let defaultSearchLimit: Int = 20

// Services:
struct UsersConnector {

    func fetchUserAccount(forUserId uid: String) async throws -> UserAccount {
        guard !uid.isEmpty else { throw FetchDataError.invalidFunctionInput }
        let queryRef = DataConnect.defaultConnector.getUserAccountQuery.ref(userId: uid)
        let operationResult = try await queryRef.execute()
        let accounts = try operationResult.data.userAccounts.compactMap { firebaseAccount -> UserAccount? in
            let account = makeUserAccount(from: firebaseAccount)
            guard account.isValid else { throw FetchDataError.invalidCloudData }
            return account
        }
        guard let account = accounts.first, accounts.count == 1 else {
            throw accounts.count > 1 ? FetchDataError.userDataDuplicatesFound : FetchDataError.userDataNotFound
        }
        return account
    }

    func searchUsers(byDisplayName searchText: String, limit: Int = defaultSearchLimit) async throws -> [UserKey] {
        guard !searchText.isEmpty else { return [] }
        let queryRef = DataConnect.defaultConnector.userDisplayNameSearchQuery.ref(searchText: searchText, limit: limit)
        let operationResult = try await queryRef.execute()
        return try operationResult.data.userAccounts.compactMap { firebaseAccount -> UserKey? in
            let userKey = UserKey(uid: firebaseAccount.id, displayName: firebaseAccount.displayNameText)
            guard userKey.isValid else { throw FetchDataError.invalidCloudData }
            return userKey
        }
    }

}

// helpers to make local structs:
private extension UsersConnector {

    func makeUserAccount(
        from firebaseAccount: GetUserAccountQuery.Data.UserAccount
    ) -> UserAccount {
        return UserAccount(
            uid: firebaseAccount.id,
            displayName: firebaseAccount.displayNameText,
            photoUrl: firebaseAccount.photoUrl
        )
    }

}
