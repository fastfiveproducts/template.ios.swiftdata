//
//  CompleteAccountView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 2/3/26.
//      Template v0.2.5 — Fast Five Products LLC's public AGPL template.
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

struct CompleteAccountView: View, DebugPrintable {
    @ObservedObject var viewModel: UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService

    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .displayName:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case displayName }

    var body: some View {

        if !viewModel.showStatusMode {

            Section(header: Text("Complete Your Account")) {
                Text("Your sign-in was successful, but your account setup is incomplete. Please complete your account to continue.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LabeledContent {
                    Text(currentUserService.user.auth.email)
                } label: { Text("email address:") }
                    .labeledContentStyle(TopLabeledContentStyle())

                LabeledContent {
                    TextField(text: $viewModel.capturedDisplayNameText) {}
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .displayName)
                        .onTapGesture { nextField() }
                        .onSubmit { completeAccount() }
                } label: { Text("enter a Display Name:") }
                    .labeledContentStyle(TopLabeledContentStyle())

                Button("Complete Account", action: completeAccount)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.accentColor)
                    .disabled(viewModel.capturedDisplayNameText.isEmpty ||
                        currentUserService.isCreatingUserAccount ||
                        currentUserService.isUpdatingUserAccount
                    )

            }
            .onAppear { focusedField = .displayName }
            .onChange(of: viewModel.capturedDisplayNameText) {
                viewModel.clearStatus()
            }
            .onSubmit {
                completeAccount()
            }
        }


        if viewModel.showStatusMode {
            Section (header: Text("Completing Account Setup")) {
                VStack(alignment: .leading, spacing: 8) {
                    statusRow("Creating User Profile",
                              isActive: currentUserService.isCreatingUserAccount,
                              isDone: !currentUserService.isCreatingUserAccount && (currentUserService.isUpdatingUserAccount || viewModel.showSuccessMode))

                    statusRow("Setting Display Name",
                              isActive: currentUserService.isUpdatingUserAccount,
                              isDone: !currentUserService.isUpdatingUserAccount && viewModel.showSuccessMode)

                    if viewModel.showSuccessMode {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Account Setup Complete!")
                                .fontWeight(.medium)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private extension CompleteAccountView {

    private func completeAccount() {
        debugprint("completeAccount called")
        if viewModel.isReadyToCompleteUserAccount() {
            Task {
                do {
                    try await viewModel.completeUserAccountWithService(currentUserService)
                } catch {
                    debugprint("🛑 ERROR:  (View) Error completing User Account: \(error)")
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
#Preview ("test-data incomplete user account") {
    let currentUserService = CurrentUserTestService.sharedIncompleteUserAccount
    ScrollViewReader { proxy in
        Form {
            CompleteAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService
            )
        }
    }
}
#Preview ("test-data showing status") {
    let currentUserService = CurrentUserTestService.sharedCreatingUser
    let viewModel = UserAccountViewModel(showStatusMode: true, completeUserAccountMode: true)
    ScrollViewReader { proxy in
        Form {
            CompleteAccountView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        }

        Spacer()
        Button("Next State", action: currentUserService.nextCreateState)
    }
}
#endif
