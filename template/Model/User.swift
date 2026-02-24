//
//  User.swift
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

// User
struct User: Equatable, Codable {
    var auth: UserAuth              // from the Authentication Service, masters users themselves (parent because it masters User Id)
    var account: UserAccount        // from the Application Data Service, masters data about users (child)
}

// Auth Service Data
struct UserAuth: Equatable, Codable {
    let uid: String                 // "User Id" is 'uid' to distinguish it from the UUI Application Ids
    var email: String
    var phoneNumber: String?
    var isAnonymous: Bool
    var isEmailVerified: Bool
}

// User Account Data Service
struct UserAccount: Equatable, Codable {
    let uid: String                 // mastered by the Auth Service
    let displayName: String         // mastered by the Application Data Service
    let photoUrl: String
    let userType: String?
    var isValid: Bool { !uid.isEmpty && !displayName.isEmpty }
}

// Light, public, local-client helper-structure is most of the user data used throughout the app
struct UserKey: Equatable, Codable {
    let uid: String
    let displayName: String
    let userType: String?
    var isValid: Bool {
        !uid.isEmpty &&
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

// used to create or update a User Account:
struct UserAccountCandidate {
    let uid: String
    let displayName: String
    let photoUrl: String
    var isValid: Bool { !uid.isEmpty && !displayName.isEmpty }
}

extension User {
    static let blankUser = User(auth: UserAuth.blankUser, account: UserAccount.blankUser)
}

extension UserAuth {
    static let blankUser = UserAuth(uid: UserKey.blankUser.uid, email: "", phoneNumber: "", isAnonymous: false, isEmailVerified: false)
}

extension UserAccount {
    static let blankUser = UserAccount(uid: UserKey.blankUser.uid, displayName: "", photoUrl: "", userType: nil)
}

extension UserKey {
    static let blankUser = UserKey(uid: "", displayName: "", userType: nil)
}


#if DEBUG
extension User {
    static let testObject = User(auth: UserAuth.testObject, account: UserAccount.testObject)
    static let testObjectAnother = User(auth: UserAuth.testObjectAnother, account: UserAccount.testObjectAnother)
    static let testObjectUnverified = User(auth: UserAuth.testObjectUnverified, account: UserAccount.testObject)
    static let testObjects: [User] = [.testObject, .testObjectAnother]
}

extension UserAuth {
    static let testObject = UserAuth(uid: UserKey.testObject.uid, email: "lorem@ipsum.com", phoneNumber: "+5555550101", isAnonymous: false, isEmailVerified: true)
    static let testObjectAnother = UserAuth(uid: UserKey.testObjectAnother.uid, email: "alorem@ipsum.com", phoneNumber: "+5555550102", isAnonymous: false, isEmailVerified: true)
    static let testObjectUnverified = UserAuth(uid: UserKey.testObject.uid, email: "lorem@ipsum.com", phoneNumber: "+5555550101", isAnonymous: false, isEmailVerified: false)
    static let testObjects: [UserAuth] = [.testObject, .testObjectAnother]
}

extension UserAccount {
    static let testObject = UserAccount(
        uid: UserKey.testObject.uid,
        displayName: UserKey.testObject.displayName,
        photoUrl: "larryipsum.photo.com",
        userType: nil)
    static let testObjectAnother = UserAccount(
        uid: UserKey.testObjectAnother.uid,
        displayName: UserKey.testObjectAnother.displayName,
        photoUrl: "alisonipsum.photo.com",
        userType: nil)
    static let testObjects: [UserAccount] = [.testObject, .testObjectAnother]
}

extension UserKey {
    static let testObject = UserKey(uid: "00000000-0000-0000-0000-000000000001", displayName: "Larry Ipsum", userType: nil)
    static let testObjectAnother = UserKey(uid: "00000000-0000-0000-0000-000000000002", displayName: "Alison Loretta Ipsum", userType: nil)
    static let testObjects: [UserKey] = [.testObject, .testObjectAnother]
}
#endif
