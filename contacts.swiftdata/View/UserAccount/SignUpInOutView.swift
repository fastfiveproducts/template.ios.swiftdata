//
//  SignUpSignInSignOutView.swift
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


import SwiftUI
import SwiftData

struct SignUpInOutView: View, DebugPrintable {
    @ObservedObject var viewModel : UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    @State private var showResetConfirmation = false
    
    @Environment(\.modelContext) private var modelContext
    
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
        
        Section(header: Text(currentUserService.isSignedIn ? "Signed-In User" : ( viewModel.createAccountMode ? "Sign-Up" : "Sign-In or Sign-Up"))) {
            if currentUserService.isSignedIn {
                
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
                Button(action: toggleSignIn) {
                    Text(currentUserService.isSignedIn ? "Sign Out" : "Submit")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .listRowBackground(Color.accentColor)
                
            }
            else {
                
                // email
                LabeledContent {
                    TextField(text: $viewModel.capturedEmailText, prompt: Text(currentUserService.isSignedIn ? currentUserService.user.auth.email : "sign-in or sign-up email address")) {}
                        .disabled(viewModel.createAccountMode)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .username)
                        .onTapGesture { nextField() }
                        .onSubmit { nextField() }
                } label: { Text("email address:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                // password + action (if applicable)
                if viewModel.createAccountMode {
                    LabeledContent {
                        SecureField(text: $viewModel.capturedPasswordText, prompt: Text("password")) {}
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .password)
                            .onTapGesture { nextField() }
                            .onSubmit { createAccount() }
                    } label: { Text("password:") }
                        .labeledContentStyle(TopLabeledContentStyle())
                } else {
                    LabeledContent {
                        SecureField(text: $viewModel.capturedPasswordText, prompt: Text("password")) {}
                            .disabled(currentUserService.isSignedIn)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .password)
                            .onTapGesture { toggleSignIn() }
                            .onSubmit { toggleSignIn() }
                    } label: { Text("password:") }
                        .labeledContentStyle(TopLabeledContentStyle())
                    Button(action: toggleSignIn) {
                        Text(currentUserService.isSignedIn ? "Sign Out" : "Submit")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }

        }
        .onAppear {focusedField = .username}
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
        } else if viewModel.changePasswordMode {
            ChangePasswordView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        } else if currentUserService.isSignedIn {
            Button(action: toggleChangePassword) {
                Text("Change Password")
            }
            .frame(maxWidth: .infinity)
        } else {
            Button(action: resetPassword) {
                Text("Reset Password")
            }
            .frame(maxWidth: .infinity)
        }
    
        Section {
            if currentUserService.isSigningIn {
                HStack {
                    Text("Checking Email Address...")
                    ProgressView()
                    Spacer()
                }
            } else if currentUserService.isSignedIn && viewModel.showStatusMode {
                HStack {
                    Text("Checking Email Address...AVAILABLE")
                    Spacer()
                }
            }
        }
    }
}

private extension SignUpInOutView {
    private func toggleSignIn() {
        if currentUserService.isSignedIn {
            do {
                try CurrentUserService.shared.signOut()
            } catch {
                debugprint("(View) Error signing out of User Account: \(error)")
                viewModel.error = error
            }
        } else if viewModel.isReadyToSignIn() {
            Task {
                do {
                    let uid = try await currentUserService.signInExistingUser(
                        email: viewModel.capturedEmailText,
                        password: viewModel.capturedPasswordText)
                    viewModel.capturedPasswordText = ""
                    debugprint("(View) User \(uid) signed in")
                } catch {
                    if let authError = error as? AuthError, authError == .userNotFound {
                        viewModel.createAccountMode = true
                    } else {
                        debugprint("(View) Error signing into User Account: \(error)")
                        viewModel.error = error
                        throw error
                    }
                }
            }
        }
        modelContext.insert(ActivityLogEntry(currentUserService.isSignedIn ? "User signed out": "User signed in"))
    }
    
    private func createAccount() {
        debugprint("createAccount called")
        if viewModel.isReadyToCreateAccount() {
            Task {
                try await viewModel.createAccountWithService(currentUserService)
            }
        }
    }
    
    private func resetPassword() {
        debugprint("resetPassword called")
        if viewModel.isReadyToResetPassword() {
            Task {
                do {
                    try await viewModel.resetPasswordWithService(currentUserService)
                } catch {
                    debugprint("(View) Error requesting password reset: \(error)")
                    viewModel.error = error
                    throw error
                }
                modelContext.insert(ActivityLogEntry("Password reset email sent"))
                showResetConfirmation = true
            }
        }
    }
    
    private func toggleChangePassword() {
        viewModel.toggleChangePasswordMode()
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    Form {
        SignUpInOutView(
            viewModel: UserAccountViewModel(),
            currentUserService: currentUserService
        )
        .modelContainer(for: ActivityLogEntry.self, inMemory: true)
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("test-data signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    Form {
        SignUpInOutView(
            viewModel: UserAccountViewModel(),
            currentUserService: currentUserService
        )
        .modelContainer(for: ActivityLogEntry.self, inMemory: true)
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("test-data creating-account") {
    let viewModel = UserAccountViewModel(createAccountMode: true)
    let currentUserService = CurrentUserTestService.sharedSignedOut
    Form {
        SignUpInOutView(
            viewModel: viewModel,
            currentUserService: currentUserService
        )
        .modelContainer(for: ActivityLogEntry.self, inMemory: true)
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
