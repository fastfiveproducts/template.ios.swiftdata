//
//  UserMessagePostsStackView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.4 (updated) Fast Five Products LLC's public AGPL template.
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

// ***** User Private Message Functionality *****
// ***** WARNING - placeholder only - not fully implemented - not tested *****

struct UserMessagePostsStackView: View, DebugPrintable {
    @ObservedObject var viewModel: UserPostViewModel<PrivateMessage>
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var store: PrivateMessageStore
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .firstField:
                focusedField = .secondField
            case .secondField:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case firstField, secondField }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: -- Write
            VStackBox(title: "Write Message"){
                Text("To User Placeholder") // TODO: Replace with user lookup
                
                LabeledContent {
                    TextField("new message", text: $viewModel.capturedTitleText)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .firstField)
                        .onTapGesture { nextField() }
                        .onSubmit { nextField() }
                } label: {
                    Text("subject")
                }
                .labeledContentStyle(TopLabeledContentStyle())
                
                LabeledContent {
                    TextEditor(text: $viewModel.capturedContentText)
                        .frame(minHeight: 80, maxHeight: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .secondField)
                } label: {
                    Text("message text")
                }
                .labeledContentStyle(TopLabeledContentStyle())
                
                Button(action: submit) {
                    if viewModel.isWorking {
                        ProgressView()
                    } else {
                        Text("Send New Message")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .onAppear {focusedField = .firstField}
            .onChange(of: viewModel.isWorking) {
                guard !viewModel.isWorking, viewModel.error == nil else { return }
                // do something, if needed
            }
            
            // MARK: -- Inbox
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("Inbox")       // TODO: touch here to open a browsing-specific View
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                PostsScrollView(
                    store: store,
                    currentUserId: currentUserService.userKey.uid,
                    toUserId: currentUserService.userKey.uid,
                    showFromUser: true
                )
                .padding(.horizontal)
            }
            
            // MARK: -- Sent
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("Sent")        // TODO: touch here to open a browsing-specific View
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                PostsScrollView(
                    store: store,
                    currentUserId: currentUserService.userKey.uid,
                    fromUserId: currentUserService.userKey.uid,
                    showToUser: true
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
        .disabled(viewModel.isWorking)
        .alert("Error", error: $viewModel.error)
    }    
}


private extension UserMessagePostsStackView {
    private func submit() {
        debugprint("(View) submit called")
        viewModel.isWorking = true
        
        Task {
            defer { viewModel.isWorking = false }
            do {
                viewModel.postCandidate = PostCandidate(
                    from: currentUserService.userKey,
                    to: currentUserService.userKey,         // TODO: Replace with actual recipient
                    title: viewModel.capturedTitleText,
                    content: viewModel.capturedContentText
                )
                viewModel.createdPost = try await store.createPrivateMessage(from: viewModel.postCandidate)
                debugprint(viewModel.createdPost.objectDescription)
            } catch {
                debugprint("Cloud Error publishing Comment: \(error)")
                viewModel.error = error
            }
        }
    }
}


#if DEBUG
#Preview ("Loaded") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PrivateMessage>()
    let store = PrivateMessageStore.testLoaded()
    UserMessagePostsStackView(
        viewModel: viewModel,
        currentUserService: currentUserService,
        store: store
    )
}
#Preview ("Empty") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PrivateMessage>()
    let store = PrivateMessageStore()
    UserMessagePostsStackView(
        viewModel: viewModel,
        currentUserService: currentUserService,
        store: store
    )
}
#endif
