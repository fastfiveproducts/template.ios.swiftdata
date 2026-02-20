//
//  UserAccountViewModel.swift
//
//  Template created by Pete Maiser, July 2024 through August 2025
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

@MainActor
class UserAccountViewModel: ObservableObject, DebugPrintable {
    // Support Previews to jump-start into create-account or status-mode
    #if DEBUG
    init(createAccountMode: Bool = false, showStatusMode: Bool = false, completeUserAccountMode: Bool = false) {
        self.createAccountMode = createAccountMode
        self.showStatusMode = showStatusMode
        self.completeUserAccountMode = completeUserAccountMode
    }
    #endif
    
    // Status
    @Published private(set) var statusText = ""
    func clearStatus() { statusText = "" }
    @Published var error: Error?
    @Published var createAccountMode = false
    @Published var completeUserAccountMode = false
    @Published var showStatusMode = false
    @Published var showSuccessMode = false
    @Published var changePasswordMode = false
      
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

    // MARK: - Validation
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
        } else if capturedDisplayNameText.count > 100 {
            statusText = "Display Name is too long"
            isReady = false
        } else if RestrictedWordStore.shared.containsRestrictedWords(capturedDisplayNameText) {
            statusText = "Display Name matched one or more keywords on our Restricted Text List. Please adjust."
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
    
    func isReadyToChangePassword() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedPasswordTextOld.isEmpty {
            statusText = ("Please enter your current password")
            isReady = false
        } else if capturedPasswordsMatch() == false {
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
    
    // MARK: - Reset Create Account
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

    // MARK: - Complete User Account (recovery from incomplete account)
    func isReadyToCompleteUserAccount() -> Bool {
        statusText = ""
        var isReady = true

        if capturedDisplayNameText.isEmpty {
            statusText = ("Please enter your display name")
            isReady = false
        } else if capturedDisplayNameText.count > 100 {
            statusText = "Display Name is too long"
            isReady = false
        }

        if RestrictedWordStore.shared.containsRestrictedWords(capturedDisplayNameText) {
            statusText = "Display Name matched one or more keywords on our Restricted Text List. Please adjust."
            isReady = false
        }
        return isReady
    }

    func resetCompleteUserAccount(withDelay delay: TimeInterval = 0.0) {
        if delay > 0 {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                self.resetCompleteUserAccount()
            }
        } else {
            capturedDisplayNameText = ""
            error = nil
            completeUserAccountMode = false
            showStatusMode = false
            showSuccessMode = false
        }
    }

    func completeUserAccountWithService(_ currentUserService: CurrentUserService) async throws {
        showStatusMode = true

        let userId = currentUserService.user.auth.uid
        let email = currentUserService.user.auth.email
        let candidate = UserAccountCandidate(uid: userId, displayName: capturedDisplayNameText, photoUrl: "")

        // MARK:  create the user account in the Application system
        // use the email address as the display name text to start,
        // making the app functional even if the user's chosen display name is taken
        do {
            try await currentUserService.createUserAccount(candidate, displayNameTextOverride: email)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(userId) Auth exists, but Cloud error creating User Account: \(error)")
            self.error = AccountCreationError.userAccountCompletionFailed(error)
            throw AccountCreationError.userAccountCompletionFailed(error)
        }

        // MARK:  the User Account has been sufficiently created such that we will no longer throw errors,
        // do less-critical tasks and clean-up
        defer {
            currentUserService.clearIncompleteUserAccountState()
            resetCompleteUserAccount(withDelay: 4)
        }

        // create the user's chosen Display Name
        do {
            try await currentUserService.createUserDisplayName(candidate.displayName)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(userId) Account created, but Cloud error creating User Display Name: \(error)")
            self.error = AccountCreationError.userDisplayNameCreationFailed
        }

        // set that chosen display name
        do {
            try await currentUserService.setUserDisplayName(candidate.displayName)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(userId) Account created, Display Name created, but Cloud Error setting Display Name: \(error)")
            self.error = AccountCreationError.setUserDisplayNameFailed
        }

        // send verification email (non-critical)
        do {
            try await currentUserService.sendVerificationEmail()
        } catch {
            debugprint("WARNING: verification email send failed: \(error)")
        }

        showSuccessMode = true
    }
    
    // MARK: - Create Account
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
            debugprint("🛑 ERROR:  (View) Cloud Error creating User in the Authentication system: \(error)")
            self.error = error
            throw error
        }
        
        // MARK:  then create the user in the Application system
        // use the email address as the display name text to start,
        // making the app functional even if the user's chosen display name is taken
        do {
            try await currentUserService.createUserAccount(accountCandidate, displayNameTextOverride: capturedEmailText)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(createdUserId) created in the Authentication system, but Clould error creating User Account: \(error)")
            self.error = AccountCreationError.userAccountCreationIncomplete(error)
            throw AccountCreationError.userAccountCreationIncomplete(error)
        }
        
        // MARK:  the User Account has been sufficiently created such that we will no longer throw errors,
        // do less-critical tasks and clean-up
        defer {
            currentUserService.clearIncompleteUserAccountState()
            resetCreateAccount(withDelay: 4)
        }
        
        // create the user's chosen Display Name
        do {
            try await currentUserService.createUserDisplayName(accountCandidate.displayName)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(createdUserId) created and Account initialized, but Clould error creating User Display Name: \(error)")
            self.error = AccountCreationError.userDisplayNameCreationFailed
        }
        
        // set that chosen display name
        do {
            try await currentUserService.setUserDisplayName(accountCandidate.displayName)
        } catch {
            debugprint("🛑 ERROR:  (View) User \(createdUserId) created, Account initialized, Display Name created, but Cloud Error setting Display Name: \(error)")
            self.error = AccountCreationError.setUserDisplayNameFailed
        }

        // send verification email (non-critical)
        do {
            try await currentUserService.sendVerificationEmail()
        } catch {
            debugprint("WARNING: verification email send failed: \(error)")
        }

        showSuccessMode = true

    }
        
    // MARK: - Reset Password
    func resetPasswordWithService(_ currentUserService: CurrentUserService) async throws {
        
        // request the Auth system send a password-reset email
        do {
            try await currentUserService.resetUserPassword(
                email: capturedEmailText
            )
        } catch {
            debugprint("🛑 ERROR:  (View) Cloud Error sending password reset email from the Authentication system: \(error)")
            self.error = error
            throw error
        }
    }

    // MARK: - Change Password
    func toggleChangePasswordMode() {
        capturedPasswordTextOld = ""
        capturedPasswordText = ""
        capturedPasswordMatchText = ""
        error = nil
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
                email: currentUserService.user.auth.email,
                password: capturedPasswordTextOld)
        } catch {
            debugprint("🛑 ERROR:  (View) Cloud Error reAuthenticating the user: \(error)")
            self.error = error
            throw error
        }
        
        // MARK:  then reset the user's Password in the Auth system
        do {
            try await currentUserService.changeUserPassword(
                newPassword: capturedPasswordText)
        } catch {
            debugprint("🛑 ERROR:  (View) Cloud Error changing user password: \(error)")
            self.error = error
            throw error
        }
    }
    
}
