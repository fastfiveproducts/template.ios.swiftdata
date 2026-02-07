//
//  ChangePasswordView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 8/20/25.
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

struct ChangePasswordView: View, DebugPrintable {
    @ObservedObject var viewModel: UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    @State private var showConfirmation = false
    
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .passwordOld:
                focusedField = .passwordNew
            case .passwordNew:
                focusedField = .passwordOld
            case .passwordAgain:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case passwordOld, passwordNew, passwordAgain }

    var body: some View {
        Section(header: Text("Change Password")) {
            LabeledContent {
                SecureField(text: $viewModel.capturedPasswordTextOld, prompt: Text("current password")) {}
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .passwordOld)
                    .onTapGesture { nextField() }
                    .onSubmit { nextField() }
            } label: { Text("current password:") }
                .labeledContentStyle(TopLabeledContentStyle())
            
            LabeledContent {
                SecureField(text: $viewModel.capturedPasswordText, prompt: Text("new password")) {}
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .passwordNew)
                    .onTapGesture { nextField() }
                    .onSubmit { nextField() }
            } label: { Text("new password:") }
                .labeledContentStyle(TopLabeledContentStyle())
            
            LabeledContent {
                SecureField(text: $viewModel.capturedPasswordMatchText, prompt: Text("new password")) {}
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .passwordAgain)
                    .onTapGesture { nextField() }
                    .onSubmit { nextField() }
            } label: { Text("enter new password again:") }
                .labeledContentStyle(TopLabeledContentStyle())
            
            Button("Submit", action: changePassword)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .listRowBackground(Color.accentColor)
                .disabled(viewModel.capturedPasswordTextOld.isEmpty
                          || viewModel.capturedPasswordText.isEmpty
                          || viewModel.capturedPasswordMatchText.isEmpty
                )
            
            Button("Cancel", role: .cancel) {
                viewModel.toggleChangePasswordMode()
            }
            .frame(maxWidth: .infinity)
            
        }
        .onAppear {focusedField = .passwordOld}
        .alert("Password Change Successful", isPresented: $showConfirmation) {
            Button("OK", role: .cancel) {
                viewModel.toggleChangePasswordMode()
            }
        } 
    }
}

private extension ChangePasswordView {
    private func changePassword() {
        debugprint("changePassword called")
        if viewModel.isReadyToChangePassword() {
            Task {
                do {
                    try await viewModel.changePasswordWithService(currentUserService)
                } catch {
                    debugprint("🛑 ERROR:  (View) Error requesting password change: \(error)")
                    viewModel.error = error
                    throw error
                }
                modelContext.insert(ActivityLogEntry("Password changed"))
                showConfirmation = true
            }
        }
    }
}


#if DEBUG
#Preview {
    let currentUserService = CurrentUserTestService.sharedCreatingUser
    let viewModel = UserAccountViewModel(createAccountMode: true, showStatusMode: true)
    ScrollViewReader { proxy in
        Form {
            ChangePasswordView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        }
    }
}
#endif
