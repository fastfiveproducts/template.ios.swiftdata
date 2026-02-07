//
//  UserPostsStackView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Made/renamed from UserCommentPostsStackView.swift by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/5/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
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

struct UserPostsStackView<T: Post>: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var viewModel: UserPostViewModel<T>
    @ObservedObject var store: ListableStore<T>

    // Configuration
    let sectionTitle: String
    let composeTitle: String
    let textFieldLabel: String
    let buttonText: String
    let createPost: (PostCandidate) async throws -> T

    // Optional: for message conversations, filter to show only posts with this user
    var conversationWith: UserKey?

    // Polling timer for active conversations
    @State private var pollTimer: Timer?

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

            // MARK: - Past Posts
            VStack(alignment: .leading, spacing: 8) {
                Text(sectionTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                PostsScrollView(
                    store: store,
                    currentUserId: currentUserService.userKey.uid,
                    fromUserId: conversationWith == nil ? currentUserService.userKey.uid : nil,
                    conversationWith: conversationWith?.uid
                )
                .padding(.horizontal)
            }

            Spacer(minLength: 0)

            // MARK: - Write
            Divider()
            VStackBox(title: composeTitle){
                LabeledContent {
                    TextEditor(text: $viewModel.capturedContentText)
                        .frame(height: 40)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .firstField)
                } label: {
                    Text(textFieldLabel)
                }
                .labeledContentStyle(TopLabeledContentStyle())

                if !viewModel.statusText.isEmpty {
                    Text(viewModel.statusText)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button(action: submit) {
                    if viewModel.isWorking {
                        ProgressView()
                    } else {
                        Text(buttonText)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.capturedContentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding()
                .background(viewModel.capturedContentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .onAppear {
                if conversationWith == nil { focusedField = .firstField }
            }
            .onSubmit(submit)
            .onChange(of: viewModel.capturedContentText) {
                viewModel.clearStatus()
            }
            .onChange(of: viewModel.isWorking) {
                guard !viewModel.isWorking, viewModel.error == nil else { return }
                if conversationWith != nil {
                    viewModel.capturedContentText = ""
                    focusedField = nil
                } else {
                    dismiss()
                }
            }
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
        .disabled(viewModel.isWorking)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Cancel") {
                    viewModel.capturedContentText = ""
                    focusedField = nil
                }
            }
        }
        .alert("Error", error: $viewModel.error)
        .onAppear {
            pollTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                Task { @MainActor in
                    store.fetch()
                }
            }
        }
        .onDisappear {
            pollTimer?.invalidate()
            pollTimer = nil
        }
    }
}


private extension UserPostsStackView {
    private func submit() {
        debugprint("submit called")
        viewModel.postCandidate = PostCandidate(
            from: currentUserService.userKey,
            to: conversationWith ?? UserKey.blankUser,
            title: viewModel.capturedTitleText,
            content: viewModel.capturedContentText)
        if viewModel.isReadyToPost() {
            viewModel.isWorking = true
            Task {
                defer { viewModel.isWorking = false }
                do {
                    viewModel.createdPost = try await createPost(viewModel.postCandidate)
                    debugprint(viewModel.createdPost.objectDescription)
                } catch {
                    debugprint("🛑 ERROR:  Cloud Error publishing \(T.typeDisplayName): \(error)")
                    viewModel.error = error
                }
            }
        }
    }
}


#if DEBUG
#Preview ("Comments - Loaded") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PublicComment>()
    let store = PublicCommentStore.testLoaded()
    UserPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store,
        sectionTitle: "Your Past Comments",
        composeTitle: "Write a Comment",
        textFieldLabel: "Comment Text",
        buttonText: "Submit New Comment",
        createPost: { candidate in
            try await store.createPublicComment(from: candidate)
        }
    )
}
#Preview ("Comments - Empty") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PublicComment>()
    let store = PublicCommentStore()
    UserPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store,
        sectionTitle: "Your Past Comments",
        composeTitle: "Write a Comment",
        textFieldLabel: "Comment Text",
        buttonText: "Submit New Comment",
        createPost: { candidate in
            try await store.createPublicComment(from: candidate)
        }
    )
}
#Preview ("Messages - Loaded") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PrivateMessage>()
    let store = PrivateMessageStore.testLoaded()
    UserPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store,
        sectionTitle: "Messages with Test User",
        composeTitle: "New Message",
        textFieldLabel: "Message Text",
        buttonText: "Send Message",
        createPost: { candidate in
            try await store.createPrivateMessage(from: candidate)
        },
        conversationWith: UserKey.testObjectAnother
    )
}
#endif
