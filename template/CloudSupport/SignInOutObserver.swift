//
//  SignInOutObserver.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/17/26.
//      Template v0.2.7 (updated)  — Fast Five Products LLC's public AGPL template.
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
import Combine

@MainActor
class SignInOutObserver: ObservableObject, DebugPrintable {

    // Subscribe to the sign-in publisher so we can refresh
    // data when a user signs-in
    private var signInPublisher: AnyCancellable?
    
    // Subscribe to the sign-out publisher so we can reset
    // data when a user signs-out
    private var signOutPublisher: AnyCancellable?
    
    init() {
        let currentUser = CurrentUserService.shared
        signInPublisher = currentUser.signInPublisher.sink { [weak self] in
            self?.postSignInSetup()
        }
        signOutPublisher = currentUser.signOutPublisher.sink { [weak self] in
             self?.postSignOutCleanup()
         }
    }
    
    // conforming classes override this to perform functions immediately after sign-in
    func postSignInSetup() { }
    
    // conforming classes override user-session dependent data after user sign-out
    func postSignOutCleanup() { }
}
