//
//  UserAccountViewModel.swift
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
import SwiftUICore

@MainActor
class UserAccountViewModel: ObservableObject, DebugPrintable
{
    @Environment(\.modelContext) private var modelContext
    
    // MARK: -- Status
    @Published private(set) var statusText = ""
    @Published var error: Error?
    @Published var createAccountMode = false
    @Published var showStatusMode = false
    @Published var showSuccessMode = false
    @Published var changePasswordMode = false
    
    init(createAccountMode: Bool = false, showStatusMode: Bool = false) {
        self.createAccountMode = createAccountMode
        self.showStatusMode = showStatusMode
    }
    
    // Capture
    @Published var capturedEmailText = ""
    @Published var capturedPhoneNumberText = ""
    @Published var capturedPasswordTextOld = ""
    @Published var capturedPasswordText = ""
    @Published var capturedPasswordMatchText = ""
    @Published var capturedDisplayNameText = ""
    @Published var notRobot: Bool = false {
        didSet {
            statusText = ("")
        }
    }
    var dislikesRobots: Bool = false

    // MARK: -- Validation
    func isReadyToSignIn() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedEmailText.isEmpty {
            statusText = ("Please enter a sign-in email")
            isReady = false
        } else if capturedPasswordText.isEmpty {
            statusText = ("Please re-enter a password")
            isReady = false
        }
        return isReady
    }

    func isReadyToCreateAccount() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedEmailText.isEmpty {
            statusText = ("Please enter a sign-in email")
            isReady = false
        } else if capturedPasswordsMatch() == false {
            isReady = false
        } else if capturedDisplayNameText.isEmpty {
            statusText = ("Please enter your display name")
            isReady = false
        }
        
        if RestrictedWordStore.shared.containsRestrictedWords(capturedDisplayNameText) {
            statusText = "Display Name matched one or more keywords on our Restricted Text List. Please adjust.";
            isReady = false
        }
        return isReady
    }
    
    func isReadyToResetPassword() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedEmailText.isEmpty {
            statusText = ("Please enter a sign-in email")
            isReady = false
        }
        return isReady
    }
    
    func capturedPasswordsMatch() -> Bool {
        var match = true
        if capturedPasswordText.isEmpty {
            statusText = ("Complete both password fields with the same password")
            match = false
        } else if capturedPasswordMatchText.isEmpty {
            statusText = ("Complete both password fields with the same password")
            match = false
        } else if capturedPasswordText != capturedPasswordMatchText {
            statusText = ("Passwords don't match, please try again")
            match = false
        }
        return match
    }
    
    // MARK: -- Reset Create Account
    func resetCreateAccount(withDelay delay: TimeInterval = 0.0) {
        if delay > 0 {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                self.resetCreateAccount()
            }
        } else {
            capturedPasswordText = ""
            capturedPasswordMatchText = ""
            capturedDisplayNameText = ""
            notRobot = false
            dislikesRobots = false
            error = nil
            createAccountMode = false
            showStatusMode = false
            showSuccessMode = false
        }
    }
    
    // MARK: -- Create Account
    var createdUserId: String = ""
    var accountCandidate: UserAccountCandidate {
        return UserAccountCandidate(uid: createdUserId, displayName: capturedDisplayNameText, photoUrl: "")
    }
    
    func createAccountWithService(_ currentUserService: CurrentUserService) async throws {
        
        showStatusMode = true
        
        // MARK:  create the user in the Auth system first
        do {
            createdUserId = try await currentUserService.signInOrCreateUser(
                email: capturedEmailText,
                password: capturedPasswordText)
        } catch {
            debugprint("(View) Cloud Error creating User in the Authentication system: \(error)")
            self.error = error
            throw error
        }
        
        // MARK:  then create the user in the Application system
        // use the email address as the display name text to start,
        // making the app functional even if the user's chosen display name is taken
        do {
            try await currentUserService.createUserAccount(accountCandidate, displayNameTextOverride: capturedEmailText)
        } catch {
            debugprint("(View) User \(createdUserId) created in the Authentication system, but Clould error creating User Account: \(error)")
            self.error = AccountCreationError.userAccountCreationIncomplete(error)
            throw AccountCreationError.userAccountCreationIncomplete(error)
        }
        
        // MARK:  the User Account has been sufficiently created such that we will no longer throw errors,
        // do less-critial tasks and clean-up
        defer {
            resetCreateAccount(withDelay: 4)
        }
        
        // create the user's chosen Display Name
        do {
            try await currentUserService.createUserDisplayName(accountCandidate.displayName)
        } catch {
            debugprint("(View) User \(createdUserId) created and Account initialized, but Clould error creating User Display Name: \(error)")
            self.error = AccountCreationError.userDisplayNameCreationFailed
        }
        
        // set that chosen display name
        do {
            try await currentUserService.setUserDisplayName(accountCandidate.displayName)
            showSuccessMode = true
        } catch {
            debugprint("(View) User \(createdUserId) created, Account initialized, Display Name created, but Cloud Error setting Display Name: \(error)")
            self.error = AccountCreationError.setUserDisplayNameFailed
        }
        
    }
        
    // MARK: -- Reset Password
    func resetPasswordWithService(_ currentUserService: CurrentUserService) async throws {
        
        // request the Auth system send a password-reset email
        do {
            try await currentUserService.resetUserPassword(
                email: capturedEmailText
            )
        } catch {
            debugprint("(View) Cloud Error sending password reset email from the Authentication system: \(error)")
            self.error = error
            throw error
        }
    }

    // MARK: -- Change Password
    func toggleChangePasswordMode() {
        if changePasswordMode {
            changePasswordMode = false
        } else {
            changePasswordMode = true
        }
    }
    
    func changePasswordWithService(_ currentUserService: CurrentUserService) async throws {
        
        // MARK:  re-authenticate the user in the Auth system first
        do {
            try await currentUserService.reAuthenticateUser(
                email: capturedEmailText,
                password: capturedPasswordTextOld)
        } catch {
            debugprint("(View) Cloud Error reAuthenticating the user: \(error)")
            self.error = error
            throw error
        }
        
        // MARK:  then reset the user's Password in the Auth system
        do {
            try await currentUserService.reAuthenticateUser(
                email: capturedEmailText,
                password: capturedPasswordText)
            modelContext.insert(ActivityLogEntry("User changed password"))
        } catch {
            debugprint("(View) Cloud Error changing user password: \(error)")
            self.error = error
            throw error
        }
    }
    
}
