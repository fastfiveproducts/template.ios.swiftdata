//
//  SignUpSignInSignOutView.swift
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


import SwiftUI

struct SignUpInOutView: View, DebugPrintable {
    @ObservedObject var viewModel: UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    @State private var showResetConfirmation = false
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .username:
                focusedField = .password
            case .password:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case username; case password }
    
    var body: some View {
        
        Section(header: Text(currentUserService.isRealUser ? "Signed-In User" : ( viewModel.createAccountMode ? "Sign-Up" : "Sign-In or Sign-Up"))) {
            if currentUserService.isRealUser {
                
                // email
                LabeledContent {
                    Text(currentUserService.user.auth.email)
                } label: { Text("email address:") }
                    .labeledContentStyle(TopLabeledContentStyle())
               
                // password
                LabeledContent {
                    Text("********")
                     //   .disabled(true)
                } label: { Text("password:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                // display name
                LabeledContent {
                    Text(currentUserService.user.account.displayName)
                } label: { Text("display name:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                // action
                Button(action: toggleSignUpInOut) {
                    Text(currentUserService.isRealUser ? "Sign Out" : "Submit")
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .listRowBackground(Color.accentColor)

            }
            else {
                
                // email
                LabeledContent {
                    TextField(text: $viewModel.capturedEmailText, prompt: Text(currentUserService.isRealUser ? currentUserService.user.auth.email : "sign-in or sign-up email address")) {}
                        .disabled(viewModel.createAccountMode)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .username)
                        .onTapGesture { nextField() }
                        .onSubmit { nextField() }
                } label: { Text("email address:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                // password + action (if applicable)
                if viewModel.createAccountMode {
                    LabeledContent {
                        SecureField(text: $viewModel.capturedPasswordText, prompt: Text("password")) {}
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .password)
                            .onTapGesture { nextField() }
                            .onSubmit { createAccount() }
                    } label: { Text("password:") }
                        .labeledContentStyle(TopLabeledContentStyle())
                } else {
                    LabeledContent {
                        SecureField(text: $viewModel.capturedPasswordText, prompt: Text("password")) {}
                            .disabled(currentUserService.isRealUser)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .password)
                            .onTapGesture { toggleSignUpInOut() }
                            .onSubmit { toggleSignUpInOut() }
                    } label: { Text("password:") }
                        .labeledContentStyle(TopLabeledContentStyle())
                    Button(action: toggleSignUpInOut) {
                        Text(currentUserService.isRealUser ? "Sign Out" : "Submit")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.accentColor)
                    .disabled(viewModel.capturedEmailText.isEmpty
                        || viewModel.capturedPasswordText.isEmpty
                    )
                }
            }
            
        }
        .onAppear {focusedField = .username}
        .onChange(of: currentUserService.isRealUser) {
            if currentUserService.isRealUser {
                viewModel.capturedPasswordText = ""
            }
        }
        .alert("Password Reset Sent", isPresented: $showResetConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your inbox to continue.\nIf you don't see the email, check your Junk folder.")
        }

        if viewModel.createAccountMode {
            CreateAccountView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        } else if currentUserService.isIncompleteUserAccount {
            CompleteAccountView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        } else if currentUserService.isRealUser && !currentUserService.isVerifiedUser {
            VerifyEmailView(currentUserService: currentUserService)
        } else if viewModel.changePasswordMode {
            ChangePasswordView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        } else if currentUserService.isRealUser {
            Button("Change Password", action: toggleChangePasswordMode)
                .frame(maxWidth: .infinity)
        } else {
            Button("Reset Password", action: resetPassword)
                .frame(maxWidth: .infinity)
                .disabled(viewModel.capturedEmailText.isEmpty)
        }
    
        Section {
            if currentUserService.isSigningIn {
                HStack {
                    Text("Checking Email Address...")
                    ProgressView()
                    Spacer()
                }
            } else if currentUserService.isRealUser && viewModel.showStatusMode {
                HStack {
                    Text("Checking Email Address...AVAILABLE")
                    Spacer()
                }
            }
        }
    }
}

private extension SignUpInOutView {
    private func toggleSignUpInOut() {
        if currentUserService.isRealUser {
            do {
                try CurrentUserService.shared.signOut()
            } catch {
                debugprint("🛑 ERROR:  (View) Error signing out of User Account: \(error)")
                viewModel.error = error
            }
        } else if viewModel.isReadyToSignIn() {
            Task {
                do {
                    let uid = try await currentUserService.signInExistingUser(
                        email: viewModel.capturedEmailText,
                        password: viewModel.capturedPasswordText)
                    debugprint("(View) User \(uid) signed in")
                } catch {
                    if let authError = error as? AuthError, authError == .userNotFound {
                        viewModel.createAccountMode = true
                    } else {
                        debugprint("🛑 ERROR:  (View) Error signing into User Account: \(error)")
                        viewModel.error = error
                    }
                }
            }
        }
    }
    
    private func createAccount() {
        debugprint("createAccount called")
        if viewModel.isReadyToCreateAccount() {
            Task {
                do {
                    try await viewModel.createAccountWithService(currentUserService)
                } catch {
                    debugprint("🛑 ERROR:  (View) Error creating User Account: \(error)")
                    viewModel.error = error
                }
            }
        }
    }
    
    private func resetPassword() {
        debugprint("resetPassword called")
        if viewModel.isReadyToResetPassword() {
            Task {
                do {
                    try await viewModel.resetPasswordWithService(currentUserService)
                    showResetConfirmation = true
                } catch {
                    debugprint("🛑 ERROR:  (View) Error requesting password reset: \(error)")
                    viewModel.error = error
                }
            }
        }
    }
    
    private func toggleChangePasswordMode() {
        viewModel.toggleChangePasswordMode()
    }
}


#if DEBUG
#Preview ("test-data signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    Form {
        SignUpInOutView(
            viewModel: UserAccountViewModel(),
            currentUserService: currentUserService
        )
    }
}
#Preview ("test-data creating-account") {
    let viewModel = UserAccountViewModel(createAccountMode: true)
    let currentUserService = CurrentUserTestService.sharedSignedOut
    Form {
        SignUpInOutView(
            viewModel: viewModel,
            currentUserService: currentUserService
        )
    }
}
#Preview ("test-data incomplete-user-account") {
    let viewModel = UserAccountViewModel()
    let currentUserService = CurrentUserTestService.sharedIncompleteUserAccount
    Form {
        SignUpInOutView(
            viewModel: viewModel,
            currentUserService: currentUserService
        )
    }
}
#Preview ("test-data unverified user") {
    let viewModel = UserAccountViewModel()
    let currentUserService = CurrentUserTestService.sharedUnverifiedUser
    Form {
        SignUpInOutView(
            viewModel: viewModel,
            currentUserService: currentUserService
        )
    }
}
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    Form {
        SignUpInOutView(
            viewModel: UserAccountViewModel(),
            currentUserService: currentUserService
        )
    }
}
#endif
