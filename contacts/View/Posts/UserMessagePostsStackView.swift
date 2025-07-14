//
//  UserMessagePostsStackView.swift
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

// ***** User Private Message Functionality *****
// ***** WARNING - placeholder only - not fully implemented - not tested *****

struct UserMessagePostsStackView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var viewModel: UserPostViewModel<PrivateMessage>
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
        VStack(spacing: 16) {
            
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
#Preview  {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let viewModel = UserPostViewModel<PrivateMessage>()
    let store = PrivateMessageStore.testLoaded()
    UserMessagePostsStackView(
        currentUserService: currentUserService,
        viewModel: viewModel,
        store: store
    )
}
#endif
