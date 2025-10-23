//
//  CurrentUserService.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.2.2 (updated) Fast Five Products LLC's public AGPL template.
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
import Combine
import FirebaseAuth
import FirebaseDataConnect
import DefaultConnector

@MainActor
class CurrentUserService: ObservableObject, DebugPrintable {
    
    static let shared = CurrentUserService()     // this store passed to view models as singleton
    
    // ***** Status and Modes *****

    // Auth process
    @Published var isSigningIn = false
    @Published var isSignedIn = false
    @Published var isReAuthenticatingUser = false
    @Published var isChangingPassword = false
    
    // because Auth masters users, creating a User in the Authententication system is "creating a user"
    // even if the user is not compplete until the Account is created and complete
    @Published var isCreatingUser = false
    
    // no user is complete without the 'account' in the Application system
    @Published var isCreatingUserAccount = false
    @Published var isUpdatingUserAccount = false
    
    // for passwordless Authentication setup
    // WARNING - placeholder only - not fully implemented - not tested
    @Published var isWaitingOnEmailVerification = false
    
    
    // ***** User *****
    @Published var user: User = User.blankUser
    var userKey: UserKey { UserKey(uid: user.auth.uid, displayName: user.account.displayName) }
    
    
    // ***** Cloud Auth *****
    @Published var error: Error?
    private let auth = Auth.auth()
    private var userAuth = UserAuth.blankUser
    private var listener: AuthStateDidChangeListenerHandle?
    let signInPublisher = PassthroughSubject<Void, Never>()
    let signOutPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        setupListener()
    }
    
    
    // ***** Listener and Publisher Functions *****
    func setupListener() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.userAuth = user.map(UserAuth.init(from:)) ?? UserAuth.blankUser
            if Auth.auth().currentUser != nil {
                debugPrint( "[setupListener]: " + (self?.userAuth.uid ?? "no uid") )
                self?.postSignInSetup()
            } else {
                self?.postSignOutCleanup()
            }
        }
    }
    
    private func postSignInSetup() {
        if isCreatingUser {
            user = User(auth: userAuth, account: UserAccount.blankUser)
            isSigningIn = false
            isCreatingUser = false
            isSignedIn = true
            debugprint ("setup after user sign-in as part of creating new user; publishing sign-in")
            signInPublisher.send()
        } else {
            Task {
                do {
                    let userProfile = try await fetchMyUserAccount()
                    user = User(auth: userAuth, account: userProfile)
                    isSigningIn = false
                    isSignedIn = true
                    debugprint ("setup after user sign-in; publishing sign-in")
                    signInPublisher.send()
                }
                catch {
                    // TODO:  (user profile) code below just continues; make this try-again,
                    // and/or implement logic to impair functionality,
                    // and encourage user to restart app or etc.
                    user = User(auth: userAuth, account: UserAccount.blankUser)
                    isSigningIn = false
                    isSignedIn = true
                    debugprint ("WARNING: unable to fetch user profile after user sign-in; execution will continue")
                    debugprint ("setup after user sign-in; publishing sign-in")
                    signInPublisher.send()
                    self.error = UserProfileError.userProfileFetch(error)
                    throw UserProfileError.userProfileFetch(error)
                }
            }
        }
    }
    
    private func postSignOutCleanup() {
        userAuth = UserAuth.blankUser
        user = User(auth: userAuth, account: UserAccount.blankUser)
        isSignedIn = false
        debugprint ("cleaned-up after user sign-out; publishing sign-out")
        signOutPublisher.send()
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
                debugprint("signIn returned successful but user.uid is empty.")
                self.error = AuthError.userIdNotFound
            }
            return result.user.uid          // user existed + sign-in successful = we are done
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.userNotFound.rawValue {
                debugprint("User not found for Sign-In, error: \(error)")
                throw AuthError.userNotFound
            } else {
                debugprint("User Sign-In error: \(error)")
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
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            if !result.user.uid.isEmpty {
                debugprint("signIn - via signInOrCreateUser func - returned successful but user.uid is empty.")
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
                        debugprint("createUser returned successful but user.uid is empty.")
                        self.error = AccountCreationError.userIdNotFound
                        throw AccountCreationError.userIdNotFound
                    }
                    return result.user.uid  // user did not exist + create successful = we are done
                } catch {
                    debugprint("User Create error: \(error)")
                    self.error = error
                    throw error
                }
            } else {
                debugprint("User Sign-In error: \(error)")
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
            debugprint("Reset Password error: \(error)")
            self.error = error
            throw error
        }
    }
    
    func reAuthenticateUser(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidInput
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        isReAuthenticatingUser = true
        defer { isReAuthenticatingUser = false }
        do {
            try await auth.currentUser?.reauthenticate(with: credential)
        } catch {
            debugprint("Reauthentication error: \(error)")
            self.error = error
            throw error
        }
    }
    
    func changeUserPassword(newPassword: String) async throws {
        guard !newPassword.isEmpty else {
            throw AuthError.invalidInput
        }
        
        isChangingPassword = true
        defer { isChangingPassword = false }
        do {
            try await auth.currentUser?.updatePassword(to: newPassword)
        } catch {
            let nsError = error as NSError
            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                debugprint("Password cannot be changed because the user needs to re-authenticate.  Error: \(error)")
            } else {
                debugprint("Password Change error: \(error)")
            }
            self.error = error
            throw error
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}


// ***** Auth Functions via Passwordless Email Link *****
// ***** WARNING - placeholder only - not fully implemented - not tested *****
extension CurrentUserService {
    
    func requestNewUser(email: String) async throws {
        guard !email.isEmpty else {
            throw AccountCreationError.invalidInput
        }
        
        isCreatingUser = true
        do {
            isWaitingOnEmailVerification = true
            UserDefaults.standard.set(email, forKey: "emailForSignIn")
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://placeholder.page.link/ios")
            actionCodeSettings.handleCodeInApp = true
            try await auth.sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
        } catch {
            isCreatingUser = false
            throw error
        }
    }
      
    func completeSignInWithUrlLink(_ url: URL) async {
        
        isWaitingOnEmailVerification = false
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
                debugPrint("[completeCreateAccount]: " + result.user.uid)
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
                debugprint("(View) User \(userId) created but Clould error creating User Profile. Error: \(error)")
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
                photoUrl: profile.photoUrl
            )
            let userProfile = UserAccount(uid: profile.uid, displayName: profile.displayName, photoUrl: profile.displayName)
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
            displayNameText: displayName
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
        if accounts.count == 1 { return accounts.first! }
        else if accounts.count >= 1 { throw FetchDataError.userDataDuplicatesFound }
        else { throw FetchDataError.userDataNotFound }
    }
    
    func fetchUserAccount(forUserId uid: String) async throws -> UserAccount {
        guard !uid.isEmpty else { throw FetchDataError.invalidFunctionInput}
        let queryRef = DataConnect.defaultConnector.getUserAccountQuery.ref(userId: uid)
        let operationResult = try await queryRef.execute()
        let accounts = try operationResult.data.userAccounts.compactMap { firebaseAccount -> UserAccount? in
            let account = try makeUserAccount(from: firebaseAccount)
            guard account.isValid else { throw FetchDataError.invalidCloudData }
            return account
        }
        if accounts.count == 1 { return accounts.first! }
        else if accounts.count >= 1 { throw FetchDataError.userDataDuplicatesFound }
        else { throw FetchDataError.userDataNotFound }
    }
}


// ***** helpers to make local structs *****

private extension UserAuth {
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.phoneNumber = firebaseUser.phoneNumber ?? ""
    }
}

extension CurrentUserService {
    private func makeUserAccount(
        from firebaseAccount: GetUserAccountQuery.Data.UserAccount
    ) throws -> UserAccount {
        return UserAccount(
            uid: firebaseAccount.id,
            displayName: firebaseAccount.displayNameText,
            photoUrl: firebaseAccount.photoUrl
        )
    }
    private func makeUserAccount(
        from firebaseAccount: GetMyUserAccountQuery.Data.UserAccount
    ) throws -> UserAccount {
        return UserAccount(
            uid: firebaseAccount.id,
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
    
    init(startSignedIn: Bool, startCreatingUser: Bool = false) {
        self.startSignedIn = startSignedIn
        self.startCreatingUser = startCreatingUser
    }
    
    static let sharedSignedIn = CurrentUserTestService(startSignedIn: true) // as CurrentUserService
    static let sharedSignedOut = CurrentUserTestService(startSignedIn: false) // as CurrentUserService
    static let sharedCreatingUser = CurrentUserTestService(startSignedIn: false, startCreatingUser: true) // as CurrentUserService
    
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
        } else {
            debugprint("reset")
            isCreatingUser = true
            isSigningIn = false
            isSignedIn = false
            isCreatingUserAccount = false
            isUpdatingUserAccount = false
        }
    }
    
    override func setupListener() {
        if startSignedIn {
            loadTestUser()
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
        loadBlankUser()
    }
    
    private func loadTestUser() {
        user = User.testObject
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = true
        isCreatingUserAccount = false
    }
    
    private func loadBlankUser() {
        self.user = User.blankUser
        user = User.testObject
        isCreatingUser = false
        isSigningIn = false
        isSignedIn = false
        isCreatingUserAccount = false
    }
    
}
#endif
