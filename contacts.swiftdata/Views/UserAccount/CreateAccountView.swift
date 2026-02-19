//
//  CreateAccountView.swift
//
//  Template created by Pete Maiser, July 2024 through August 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 8/28/25.
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


import SwiftUI

struct CreateAccountView: View, DebugPrintable {
    @ObservedObject var viewModel: UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .passwordAgain:
                focusedField = .displayName
            case .displayName:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case passwordAgain, displayName}

    var body: some View {
        
        if !viewModel.showStatusMode {
            
            Section(header: Text("Create New Account")) {
                LabeledContent {
                    SecureField(text: $viewModel.capturedPasswordMatchText, prompt: Text("password")) {}
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .passwordAgain)
                        .onTapGesture { nextField() }
                        .onSubmit { nextField() }
                } label: { Text("enter password again:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                LabeledContent {
                    TextField(text: $viewModel.capturedDisplayNameText) {}
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .displayName)
                        .onTapGesture { nextField() }
                        .onSubmit { nextField() }
                } label: { Text("enter a Display Name:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                Toggle(isOn: $viewModel.notRobot) {
                    Text("I am not a Robot")
                }
                Toggle(isOn: $viewModel.dislikesRobots) {
                    Text("I don't even like Robots")
                }
                
                Button("Submit", action: createAccount)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.accentColor)
                    .disabled(viewModel.capturedPasswordMatchText.isEmpty ||
                        viewModel.capturedDisplayNameText.isEmpty ||
                        viewModel.notRobot == false ||
                        currentUserService.isCreatingUser ||
                        currentUserService.isCreatingUserAccount ||
                        currentUserService.isUpdatingUserAccount
                    )
                
            }
            .onAppear { focusedField = .passwordAgain }
            .onChange(of: viewModel.capturedDisplayNameText) {
                viewModel.clearStatus()
            }
            .onSubmit {
                if (viewModel.notRobot) {
                    createAccount() }
            }
        }
        

        if viewModel.showStatusMode {
            Section (header: Text("Creating New Account")) {
                VStack(alignment: .leading, spacing: 8) {
                    statusRow("Creating User",
                              isActive: currentUserService.isCreatingUser,
                              isDone: !currentUserService.isCreatingUser && (currentUserService.isCreatingUserAccount || currentUserService.isUpdatingUserAccount || currentUserService.isSendingVerificationEmail || viewModel.showSuccessMode))

                    statusRow("Creating User Profile",
                              isActive: currentUserService.isCreatingUserAccount,
                              isDone: !currentUserService.isCreatingUserAccount && (currentUserService.isUpdatingUserAccount || currentUserService.isSendingVerificationEmail || viewModel.showSuccessMode))

                    statusRow("Setting Display Name",
                              isActive: currentUserService.isUpdatingUserAccount,
                              isDone: !currentUserService.isUpdatingUserAccount && (currentUserService.isSendingVerificationEmail || viewModel.showSuccessMode))

                    if ViewConfig.requiresEmailVerification {
                        statusRow("Sending Verification Email",
                                  isActive: currentUserService.isSendingVerificationEmail,
                                  isDone: !currentUserService.isSendingVerificationEmail && viewModel.showSuccessMode)
                    }

                    if viewModel.showSuccessMode {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Create Account Successful!")
                                .fontWeight(.medium)
                        }
                        .padding(.top, 4)
                        if ViewConfig.requiresEmailVerification {
                            Text("Check your inbox to verify your email address.\nIf you don't see the email, check your Junk folder.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        } else {
            Section {
                Button("Start Over", action: startOver)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.accentColor)
            }
        }
    }
}

private extension CreateAccountView {
    
    private func startOver() {
        debugprint("startOver called")
        viewModel.resetCreateAccount()
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
    
    private func statusRow(_ label: String, isActive: Bool, isDone: Bool) -> some View {
        HStack {
            if isDone {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.green)
            } else if isActive {
                ProgressView()
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.gray)
            }

            Text(label + (isDone ? " DONE" : isActive ? "..." : ""))
            
            Spacer()
        }
    }
}


#if DEBUG
#Preview ("test-data signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    ScrollViewReader { proxy in
        Form {
            CreateAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService
            )
        }
    }
}
#Preview ("test-data showing status") {
    let currentUserService = CurrentUserTestService.sharedCreatingUser
    let viewModel = UserAccountViewModel(createAccountMode: true, showStatusMode: true)
    ScrollViewReader { proxy in
        Form {
            CreateAccountView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        }
        
        Spacer()
        Button("Next State", action: currentUserService.nextCreateState)
    }
}
#endif

