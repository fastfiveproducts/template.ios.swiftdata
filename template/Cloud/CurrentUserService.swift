//
//  CurrentUserService.swift
//
//  Template created by Pete Maiser, July 2024 through August 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/26/26.
//      Template v0.3.4 (updated) — Fast Five Products LLC's public AGPL template.
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
@preconcurrency import FirebaseAuth  // Suppresses Sendable warnings until Firebase ships proper conformances
import FirebaseDataConnect
import DefaultConnector

@MainActor
class CurrentUserService: ObservableObject, DebugPrintable {
    
    static let shared = CurrentUserService()     // this store passed to view models as singleton
    
    // ***** User *****
    @Published var user: User = User.blankUser
    var userKey: UserKey { UserKey(uid: user.auth.uid, userType: user.account.userType, displayName: user.account.displayName) }
    var isVerifiedUser: Bool { isRealUser && (user.auth.isEmailVerified || !ViewConfig.requiresEmailVerification) }
    
    
    // ***** Status and Modes *****

    // sign-in process
    @Published var isSigningIn = false
    @Published var isSignedIn = false
    @Published var isRealUser = false
    
    // because Auth masters users, creating a User in the Authentication system is "creating a user"
    // even if the user is not complete until the Account is created and complete
    @Published var isCreatingUser = false
    
    // no user is complete without the 'account' in the Application system
    @Published var isCreatingUserAccount = false
    @Published var isUpdatingUserAccount = false
    @Published var isIncompleteUserAccount = false

    // for email verification
    @Published var isSendingVerificationEmail = false
    @Published var isCheckingVerificationStatus = false
    
    // for password maintenance
    @Published var isReAuthenticatingUser = false
    @Published var isChangingPassword = false
    
    // for passwordless Authentication setup
    // WARNING - placeholder only - not fully implemented - not tested
    @Published var isWaitingOnEmailAuthenticaion = false
    
    
    // ***** Cloud Auth *****
    @Published var error: Error?
    private let auth = Auth.auth()
    private var userAuth = UserAuth.blankUser
    private var listener: AuthStateDidChangeListenerHandle?
    let signInPublisher = PassthroughSubject<Void, Never>()
    let signOutPublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        $isSignedIn.combineLatest($user)
            .map { signedIn, user in signedIn && !user.auth.isAnonymous }
            .removeDuplicates()
            .assign(to: &$isRealUser)
        setupListener()
    }
    
    
    // ***** Listener and Publisher Functions *****
    func setupListener() {
        #if DEBUG
        if isPreview {
            debugprint("[setupListener]: running in Xcode Preview, skipping Firebase listener")
            return
        }
        #endif
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.userAuth = user.map(UserAuth.init(from:)) ?? UserAuth.blankUser
            if Auth.auth().currentUser != nil {
                self?.debugprint( "[setupListener]: " + (self?.userAuth.uid ?? "no uid") )
                self?.postSignInSetup()
            } else {
                if self?.isSignedIn == true {
                    self?.postSignOutCleanup()
                }
                self?.debugprint("[setupListener]: no current user, attempting anonymous sign-in")
                self?.signInAnonymously()
            }
        }
    }

    private func signInAnonymously() {
        Task {
            do {
                try await auth.signInAnonymously()
                debugprint("anonymous sign-in initiated")
            } catch {
                debugprint("⚠️ WARNING: anonymous sign-in failed: \(error)")
                postSignOutCleanup()
            }
        }
    }
    
    private func postSignInSetup() {
        if userAuth.isAnonymous {
            user = User(auth: userAuth, account: UserAccount.blankUser)
            isSigningIn = false
            isSignedIn = true
            isIncompleteUserAccount = false
            debugprint("setup after anonymous sign-in; publishing sign-in")
            signInPublisher.send()
            return
        }
        if isCreatingUser {
            user = User(auth: userAuth, account: UserAccount.blankUser)
            isSigningIn = false
            isCreatingUser = false
            isSignedIn = true
            isIncompleteUserAccount = true
            debugprint ("setup after user sign-in as part of creating new user; publishing sign-in")
            signInPublisher.send()
        } else {
            Task {
                do {
                    let userProfile = try await fetchMyUserAccount()
                    user = User(auth: userAuth, account: userProfile)
                    isSigningIn = false
                    isSignedIn = true
                    isIncompleteUserAccount = false
                    debugprint ("setup after user sign-in; publishing sign-in")
                    signInPublisher.send()
                }
                catch {
                    user = User(auth: userAuth, account: UserAccount.blankUser)
                    isSigningIn = false
                    isSignedIn = true
                    isIncompleteUserAccount = true
                    debugprint ("⚠️ WARNING:  unable to fetch user profile after user sign-in; user account is incomplete")
                    debugprint ("setup after user sign-in; publishing sign-in")
                    signInPublisher.send()
                    self.error = UserProfileError.userProfileFetch(error)
                }
            }
        }
    }
    
    private func postSignOutCleanup() {
        userAuth = UserAuth.blankUser
        user = User(auth: userAuth, account: UserAccount.blankUser)
        isSignedIn = false
        isIncompleteUserAccount = false
        debugprint ("cleaned-up after user sign-out; publishing sign-out")
        signOutPublisher.send()
    }

    func clearIncompleteUserAccountState() {
        isIncompleteUserAccount = false
    }
    
    
    // ***** Auth Functions *****
    func signInExistingUser(email: String, password: String) async throws -> String {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }

        isSigningIn = true
        defer { isSigningIn = false }
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            if result.user.uid.isEmpty {
                debugprint("⚠️ WARNING:  signIn returned successful but user.uid is empty.")
                self.error = AuthError.userIdNotFound
            }
            // Auth listener may not fire if signing in as the same UID (e.g. after link),
            // so update state manually to ensure the UI reflects the real user
            let updatedAuth = UserAuth(from: result.user)
            if updatedAuth.uid == userAuth.uid && userAuth.isAnonymous && !updatedAuth.isAnonymous {
                userAuth = updatedAuth
                postSignInSetup()
            }
            return result.user.uid          // user existed + sign-in successful = we are done
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.userNotFound.rawValue {
                debugprint("User not found for Sign-In, error: \(error)")
                throw AuthError.userNotFound
            } else {
                debugprint("🛑 ERROR:  User Sign-In error: \(error)")
                if let message = AuthError.extractFirebaseMessage(from: error) {
                    let wrappedError = AuthError.internalError(message)
                    self.error = wrappedError
                    throw wrappedError
                }
                self.error = error
                throw error
            }
        }
    }

    func signInOrCreateUser(email: String, password: String) async throws -> String {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }

        isSigningIn = true
        defer { isSigningIn = false }

        // If anonymous, try linking first
        if let currentUser = auth.currentUser, currentUser.isAnonymous {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            do {
                let result = try await currentUser.link(with: credential)
                debugprint("anonymous user linked to email account: \(result.user.uid)")
                // Auth listener may not fire after link (same UID), so update state manually
                userAuth = UserAuth(from: result.user)
                isCreatingUser = true
                postSignInSetup()
                return result.user.uid
            } catch {
                let nsError = error as NSError
                if nsError.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
                   nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    debugprint("link failed (email in use), falling through to sign-in")
                } else {
                    if let message = AuthError.extractFirebaseMessage(from: error) {
                        let wrappedError = AuthError.internalError(message)
                        self.error = wrappedError
                        throw wrappedError
                    }
                    self.error = error
                    throw error
                }
            }
        }

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            if result.user.uid.isEmpty {
                debugprint("⚠️ WARNING:  signIn - via signInOrCreateUser func - returned successful but user.uid is empty.")
                self.error = AuthError.userIdNotFound
            }
            return result.user.uid          // user existed + sign-in successful = we are done
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.userNotFound.rawValue {
                isCreatingUser = true
                defer { isCreatingUser = false }
                do {
                    let result = try await auth.createUser(withEmail: email, password: password)
                    guard !result.user.uid.isEmpty else {
                        debugprint("⚠️ WARNING:  createUser returned successful but user.uid is empty.")
                        self.error = AccountCreationError.userIdNotFound
                        throw AccountCreationError.userIdNotFound
                    }
                    return result.user.uid  // user did not exist + create successful = we are done
                } catch {
                    debugprint("🛑 ERROR:  User Create error: \(error)")
                    if let message = AuthError.extractFirebaseMessage(from: error) {
                        let wrappedError = AuthError.internalError(message)
                        self.error = wrappedError
                        throw wrappedError
                    }
                    self.error = error
                    throw error
                }
            } else {
                debugprint("🛑 ERROR:  User Sign-In error: \(error)")
                if let message = AuthError.extractFirebaseMessage(from: error) {
                    let wrappedError = AuthError.internalError(message)
                    self.error = wrappedError
                    throw wrappedError
                }
                self.error = error
                throw error
            }
        }
    }

    func resetUserPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidInput
        }

        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            debugprint("🛑 ERROR:  Reset Password error: \(error)")
            self.error = error
            throw error
        }
    }

    func reAuthenticateUser(email: String, password: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.invalidInput }
        
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        isReAuthenticatingUser = true
        defer { isReAuthenticatingUser = false }
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            debugprint("🛑 ERROR:  Reauthentication error: \(error)")
            self.error = error
            throw error
        }
    }

    func changeUserPassword(newPassword: String) async throws {
        guard let user = auth.currentUser else { throw AuthError.invalidInput }
        
        guard !newPassword.isEmpty else {
            throw AuthError.invalidInput
        }

        isChangingPassword = true
        defer { isChangingPassword = false }
        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                debugprint("⚠️ WARNING:  Password cannot be changed because the user needs to re-authenticate.  Error: \(error)")
            } else {
                debugprint("🛑 ERROR:  Password Change error: \(error)")
            }
            if let message = AuthError.extractFirebaseMessage(from: error) {
                let wrappedError = AuthError.internalError(message)
                self.error = wrappedError
                throw wrappedError
            }
            self.error = error
            throw error
        }
    }
    
    func signOut() throws {
        guard !user.auth.isAnonymous else {
            debugprint("user is already anonymous, ignoring sign-out request")
            return
        }
        try auth.signOut()
    }
}


// ***** Auth Functions via Passwordless Email Link *****
// ***** WARNING - placeholder only - not fully implemented - not tested *****
extension CurrentUserService {
    func requestSignInWithUrlEmail(email: String) async throws {
        guard !email.isEmpty else {
            throw AccountCreationError.invalidInput
        }
        
        isCreatingUser = true
        isWaitingOnEmailAuthenticaion = true
        do {
            // UserDefaults is acceptable here — the email is transient, used only
            // to complete the email-link sign-in flow, and cleared after use.
            UserDefaults.standard.set(email, forKey: "emailForSignIn")
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://placeholder.page.link/ios")  // TODO: replace with your app's Dynamic Link URL
            actionCodeSettings.handleCodeInApp = true
            try await auth.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
        } catch {
            isWaitingOnEmailAuthenticaion = false
            isCreatingUser = false
            throw error
        }
    }
      
    func completeSignInWithUrlLink(_ url: URL) async {
        isWaitingOnEmailAuthenticaion = false
        guard let email = UserDefaults.standard.string(forKey: "emailForSignIn")
        else {
            self.error = AuthError.signInInputsNotFound
            isCreatingUser = false
            return
        }
        
        var userId: String = ""
        
        if auth.isSignIn(withEmailLink: url.absoluteString) {
            
            isSigningIn = true
            defer { isSigningIn = false }
            do {
                let result = try await auth.signIn(withEmail: email, link: url.absoluteString)
                userId = result.user.uid
                debugprint("[completeCreateAccount]: " + result.user.uid)
                postSignInSetup()
            } catch {
                self.error = error
                isCreatingUser = false
                return
            }
        } else {
            self.error = AuthError.emailLinkInvalid
            isCreatingUser = false
            return
        }
        
        if isCreatingUser {
            do {
                // use the email address as the display name text to start,
                // making the app functional even if the user's chosen display name is taken
                try await createUserAccount(UserAccountCandidate(uid: userId, displayName: email, photoUrl: ""))
                UserDefaults.standard.removeObject(forKey: "emailForSignIn")
            } catch {
                debugprint("🛑 ERROR:  (View) User \(userId) created but Cloud error creating User Profile. Error: \(error)")
                self.error = error
            }
        }
    }
}


// ***** User Account Functions *****
extension CurrentUserService {
    func createUserAccount(_ profile: UserAccountCandidate, displayNameTextOverride: String? = nil) async throws {
        guard profile.isValid
        else { throw UpsertDataError.invalidFunctionInput }

        let displayNameText = displayNameTextOverride ?? profile.displayName
        
        isCreatingUserAccount = true
        defer { isCreatingUserAccount = false }
        do {
            let _ = try await DataConnect.defaultConnector.createUserAccountMutation.execute(
                createDeviceIdentifierstamp: deviceIdentifierstamp(),
                createDeviceTimestamp: deviceTimestamp(),
                displayNameText: displayNameText,
                displayNameTextLower: displayNameText.lowercased(),
                photoUrl: profile.photoUrl
            )
            let userProfile = UserAccount(uid: profile.uid, userType: nil, displayName: profile.displayName, photoUrl: profile.photoUrl)
            user.account = userProfile
        }
        catch {
            self.error = AccountCreationError.userAccountCreationIncomplete(error)
            throw AccountCreationError.userAccountCreationIncomplete(error)
        }
    }
    
    func createUserDisplayName(_ displayName: String) async throws {
        guard !displayName.isEmpty
        else { throw UpsertDataError.invalidFunctionInput }
        
        isUpdatingUserAccount = true
        defer { isUpdatingUserAccount = false }
        let _ = try await DataConnect.defaultConnector.createUserDisplayNameMutation.execute(
            displayNameText: displayName)
    }
    
    func setUserDisplayName(_ displayName: String) async throws {
        guard !displayName.isEmpty
        else { throw UpsertDataError.invalidFunctionInput }
        
        isUpdatingUserAccount = true
        defer { isUpdatingUserAccount = false }
        let _ = try await DataConnect.defaultConnector.updateUserAccountDisplayNameMutation.execute(
            updateDeviceIdentifierstamp: deviceIdentifierstamp(),
            updateDeviceTimestamp: deviceTimestamp(),
            displayNameText: displayName,
            displayNameTextLower: displayName.lowercased()
        )
    }
        
    func updateUserAccountProfile(_ profile: UserAccount) async throws {
        guard profile.isValid
        else { throw UpsertDataError.invalidFunctionInput }
        
        isUpdatingUserAccount = true
        defer { isUpdatingUserAccount = false }
        let _ = try await DataConnect.defaultConnector.updateUserAccountProfileMutation.execute(
            updateDeviceIdentifierstamp: deviceIdentifierstamp(),
            updateDeviceTimestamp: deviceTimestamp(),
            photoUrl: profile.photoUrl
        )
    }
    
    func fetchMyUserAccount() async throws -> UserAccount {
        let queryRef = DataConnect.defaultConnector.getMyUserAccountQuery.ref()
        let operationResult = try await queryRef.execute()
        let accounts = try operationResult.data.userAccounts.compactMap { firebaseAccount -> UserAccount? in
            let account = try makeUserAccount(from: firebaseAccount)
            guard account.isValid else { throw FetchDataError.invalidCloudData }
            return account
        }
        guard let account = accounts.first, accounts.count == 1 else {
            throw accounts.count > 1 ? FetchDataError.userDataDuplicatesFound : FetchDataError.userDataNotFound
        }
        return account
    }
    
}


// ***** Email Verification Functions *****
extension CurrentUserService {
    func sendVerificationEmail() async throws {
        guard ViewConfig.requiresEmailVerification else { return }
        guard let firebaseUser = auth.currentUser, !user.auth.isAnonymous else { return }
        guard !user.auth.isEmailVerified else { return }

        isSendingVerificationEmail = true
        defer { isSendingVerificationEmail = false }
        try await firebaseUser.sendEmailVerification()
    }

    func checkEmailVerificationStatus() async throws -> Bool {
        guard let firebaseUser = auth.currentUser else { return false }

        isCheckingVerificationStatus = true
        defer { isCheckingVerificationStatus = false }

        try await firebaseUser.reload()

        // the auth listener does NOT fire after reload, so update local state manually
        userAuth.isEmailVerified = firebaseUser.isEmailVerified
        user.auth.isEmailVerified = firebaseUser.isEmailVerified

        if firebaseUser.isEmailVerified {
            // refresh the ID token so the email_verified claim is up-to-date for server rules
            let _ = try await firebaseUser.getIDToken(forcingRefresh: true)
        }
        return firebaseUser.isEmailVerified
    }
}


// ***** helpers to make local structs *****

private extension UserAuth {
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.phoneNumber = firebaseUser.phoneNumber ?? ""
        self.isAnonymous = firebaseUser.isAnonymous
        self.isEmailVerified = firebaseUser.isEmailVerified
    }
}

extension CurrentUserService {
    private func makeUserAccount(
        from firebaseAccount: GetMyUserAccountQuery.Data.UserAccount
    ) throws -> UserAccount {
        return UserAccount(
            uid: firebaseAccount.id,
            userType: firebaseAccount.userType,
            displayName: firebaseAccount.displayNameText,
            photoUrl: firebaseAccount.photoUrl
        )
    }
}


// ***** Custom Auth User Profile Data *****
/* This code below allows you to put custom keyed-value data on to the auth user profile
 * This app doesn't intend this and will use a custom data connect user profile instead
private extension FirebaseAuth.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}
*/


#if DEBUG
class CurrentUserTestService: CurrentUserService {
    let startSignedIn: Bool
    let startCreatingUser: Bool
    let startIncompleteUserAccount: Bool
    let startAnonymous: Bool
    let startUnverified: Bool

    init(startSignedIn: Bool, startCreatingUser: Bool = false, startIncompleteUserAccount: Bool = false, startAnonymous: Bool = false, startUnverified: Bool = false) {
        self.startSignedIn = startSignedIn
        self.startCreatingUser = startCreatingUser
        self.startIncompleteUserAccount = startIncompleteUserAccount
        self.startAnonymous = startAnonymous
        self.startUnverified = startUnverified
    }

    static let sharedSignedIn = CurrentUserTestService(startSignedIn: true) // as CurrentUserService
    static let sharedSignedOut = CurrentUserTestService(startSignedIn: false) // as CurrentUserService
    static let sharedAnonymous = CurrentUserTestService(startSignedIn: false, startAnonymous: true) // as CurrentUserService
    static let sharedCreatingUser = CurrentUserTestService(startSignedIn: false, startCreatingUser: true) // as CurrentUserService
    static let sharedIncompleteUserAccount = CurrentUserTestService(startSignedIn: true, startIncompleteUserAccount: true) // as CurrentUserService
    static let sharedUnverifiedUser = CurrentUserTestService(startSignedIn: true, startUnverified: true) // as CurrentUserService
    
    func nextSignInState() {
        if isSigningIn {
            debugprint("was isSigningIn")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = true
            isCreatingUserAccount = false
        } else if isSignedIn {
            debugprint("was CreatingUserProfile")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = false
            isCreatingUserAccount = false
        } else {
            debugprint("was Signed Out")
            isCreatingUser = false
            isSigningIn = true
            isSignedIn = false
            isCreatingUserAccount = false
        }
    }
    
    func nextCreateState() {
        if isCreatingUser {
            debugprint("was isCreatingUser")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = true
            isCreatingUserAccount = true
            isUpdatingUserAccount = false
        } else if isCreatingUserAccount {
            debugprint("was CreatingUserAccount")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = true
            isCreatingUserAccount = false
            isUpdatingUserAccount = true
        } else if isUpdatingUserAccount {
            debugprint("was UpdatingUserAccount")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = true
            isCreatingUserAccount = false
            isUpdatingUserAccount = false
            isSendingVerificationEmail = true
        } else if isSendingVerificationEmail {
            debugprint("was SendingVerificationEmail")
            isCreatingUser = false
            isSigningIn = false
            isSignedIn = true
            isCreatingUserAccount = false
            isUpdatingUserAccount = false
            isSendingVerificationEmail = false
        } else {
            debugprint("reset")
            isCreatingUser = true
            isSigningIn = false
            isSignedIn = false
            isCreatingUserAccount = false
            isUpdatingUserAccount = false
            isSendingVerificationEmail = false
        }
    }
    
    override func setupListener() {
        if startSignedIn {
            if startIncompleteUserAccount {
                loadIncompleteUser()
            } else if startUnverified {
                loadUnverifiedUser()
            } else {
                loadTestUser()
            }
        } else if startAnonymous {
            loadAnonymousUser()
        } else {
            loadBlankUser()
        }
        isCreatingUser = startCreatingUser
    }
    
    override func signInExistingUser(email: String, password: String) async throws -> String {
        loadTestUser()
        return self.userKey.uid
    }
    
    override func signInOrCreateUser(email: String, password: String) async throws -> String {
        loadTestUser()
        return self.userKey.uid
    }
        
    override func signOut() throws {
        loadAnonymousUser()
    }

    private func loadAnonymousUser() {
        let anonAuth = UserAuth(uid: "anon-00000000-0000-0000-0000-000000000000", email: "", phoneNumber: "", isAnonymous: true, isEmailVerified: false)
        user = User(auth: anonAuth, account: UserAccount.blankUser)
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = true
        isCreatingUserAccount = false
        isIncompleteUserAccount = false
    }

    private func loadTestUser() {
        user = User.testObject
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = true
        isCreatingUserAccount = false
        isIncompleteUserAccount = false
    }

    private func loadUnverifiedUser() {
        user = User.testObjectUnverified
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = true
        isCreatingUserAccount = false
        isIncompleteUserAccount = false
    }

    private func loadIncompleteUser() {
        user = User(auth: User.testObject.auth, account: UserAccount.blankUser)     // incomplete user
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = true
        isCreatingUserAccount = false
        isIncompleteUserAccount = true
    }

    private func loadBlankUser() {
        self.user = User.blankUser
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = false
        isCreatingUserAccount = false
        isIncompleteUserAccount = false
    }

}
#endif
