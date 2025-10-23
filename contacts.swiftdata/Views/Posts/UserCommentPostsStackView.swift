//
//  UserCommentPostsStackView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.2 (renamed) Fast Five Products LLC's public AGPL template.
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

struct UserCommentPostsStackView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var viewModel: UserPostViewModel<PublicComment>
    @ObservedObject var store: PublicCommentStore
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .firstField:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case firstField }
         
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: -- Write
            VStackBox(title: "Write Comment"){
                LabeledContent {
                    TextEditor(text: $viewModel.capturedContentText)
                        .frame(minHeight: 80, maxHeight: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .firstField)
                } label: {
                    Text("Comment Text")
                }
                .labeledContentStyle(TopLabeledContentStyle())

                Button(action: submit) {
                    if viewModel.isWorking {
                        ProgressView()
                    } else {
                        Text("Submit New Comment")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .onAppear {focusedField = .firstField}
            .onSubmit(submit)
            .onChange(of: viewModel.isWorking) {
                guard !viewModel.isWorking, viewModel.error == nil else { return }
                dismiss()
            }

            // MARK: -- Past Comments
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Past Comments")      // TODO: touch here to open a browsing-specific View
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                PostsScrollView(
                    store: store,
                    currentUserId: currentUserService.userKey.uid,
                    fromUserId: currentUserService.userKey.uid
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
        .disabled(viewModel.isWorking)
        .alert("Error", error: $viewModel.error)
    }
}


private extension UserCommentPostsStackView {
    private func submit() {
        debugprint("(View) submit called")
        viewModel.isWorking = true
        Task {
            defer { viewModel.isWorking = false }
            do {
                viewModel.postCandidate = PostCandidate(
                    from: currentUserService.userKey,
                    to: UserKey.blankUser,
                    title: viewModel.capturedTitleText,
                    content: viewModel.capturedContentText)
                viewModel.createdPost = try await store.createPublicComment(from: viewModel.postCandidate)
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
    let viewModel = UserPostViewModel<PublicComment>()
    let store = PublicCommentStore.testLoaded()
    UserCommentPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store
    )
}
#Preview ("Empty") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PublicComment>()
    let store = PublicCommentStore()
    UserCommentPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store
    )
}
#endif
