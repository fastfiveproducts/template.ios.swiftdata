//
//  UserCommentPostsStackView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2 (renamed)
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
        VStack(spacing: 16) {
            
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
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
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
#Preview  {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PublicComment>()
    let store = PublicCommentStore.testLoaded()
    UserCommentPostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store
    )
}
#endif
