//
//  SignUpSignInSignOutView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
//


import SwiftUI
import SwiftData

struct SignUpInOutView: View, DebugPrintable {
    @ObservedObject var viewModel : UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    
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
                LabeledContent {
                    Text(currentUserService.user.auth.email)
                } label: { Text("email address:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                LabeledContent {
                    Text(currentUserService.user.account.displayName)
                } label: { Text("display name:") }
                    .labeledContentStyle(TopLabeledContentStyle())
                
                Button(action: toggleLogin) {
                    Text(currentUserService.isSignedIn ? "Sign Out" : "Submit")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .listRowBackground(Color.accentColor)
            }
            else {
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
                            .onTapGesture { toggleLogin() }
                            .onSubmit { toggleLogin() }
                    } label: { Text("password:") }
                        .labeledContentStyle(TopLabeledContentStyle())
                    Button(action: toggleLogin) {
                        Text(currentUserService.isSignedIn ? "Sign Out" : "Submit")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }
            

        }
        .onAppear {focusedField = .username}
        
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
        
        if viewModel.createAccountMode {
            CreateAccountView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        }
    }
}

private extension SignUpInOutView {
    private func toggleLogin() {
        if currentUserService.isSignedIn {
            do {
                try CurrentUserService.shared.signOut()
                addLoginEventToLog()
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
                    addLoginEventToLog()
                } catch {
                    if let signInError = error as? SignInError, signInError == .userNotFound {
                        viewModel.createAccountMode = true
                    } else {
                        debugprint("(View) Error signing into User Account: \(error)")
                        viewModel.error = error
                        throw error
                    }
                }
            }
        }
    }
    
    private func createAccount() {
        debugprint("createAccount called")
        if viewModel.isReadyToCreateAccount() {
            Task {
                try await viewModel.createAccountWithService(currentUserService)
            }
        }
    }
    
    private func addLoginEventToLog() {
        let newLogEntry = ActivityLogEntry(currentUserService.isSignedIn ? "User signed out": "User signed in")
        modelContext.insert(newLogEntry)
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
