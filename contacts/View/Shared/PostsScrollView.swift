//
//  PostsScrollView.swift
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

struct PostsScrollView<T: Post>: View {
    @ObservedObject var store: ListableCloudStore<T>
    var currentUserId: String

    // Optional filters
    var fromUserId: String?
    var toUserId: String?
    
    // Optional visuals
    var showFromUser: Bool = false
    var showToUser: Bool = false
    var hideWhenEmpty: Bool = false

    // Apply filters
    private var filteredPosts: [T] {
        guard case let .loaded(posts) = store.list else { return [] }
        return posts.filter { post in
            let toMatch = toUserId == nil || post.to.uid == toUserId
            let fromMatch = fromUserId == nil || post.from.uid == fromUserId
            return toMatch && fromMatch
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch store.list {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()

            case .error(let error):
                Text("Error loading content: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()

            case .none:
                Text("Nothing here")
                    .padding(.top, 10)

            case .loaded:
                if filteredPosts.isEmpty {
                    if hideWhenEmpty {
                        EmptyView()
                    } else {
                        VStack(alignment: .leading) {
                            Text("None!")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            Spacer(minLength: 0) // optional, to push empty state up
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(filteredPosts) { post in
                                PostBubbleView(
                                    post: post,
                                    isSent: post.from.uid == currentUserId,
                                    showFromUser: showFromUser,
                                    showToUser: showToUser
                                )
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}


#if DEBUG
#Preview ("Various Views") {
    let currentUserService = CurrentUserTestService.sharedSignedIn

    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Section(header: Text("My Published Comments")) {
                PostsScrollView(
                    store: PublicCommentStore.testLoaded(),
                    currentUserId: currentUserService.userKey.uid,
                    fromUserId: currentUserService.userKey.uid,
                )
            }
            
            Section(header: Text("All Comments")) {
                PostsScrollView(
                    store: PublicCommentStore.testLoaded(),
                    currentUserId: currentUserService.userKey.uid,
                    showFromUser: true
                )
            }
        

            Section(header: Text("Inbox Messages")) {
                PostsScrollView(
                    store: PrivateMessageStore.testLoaded(),
                    currentUserId: currentUserService.userKey.uid,
                    toUserId: currentUserService.userKey.uid,
                    showFromUser: true
                )
            }
            
            Section(header: Text("Sent Messages")) {
                PostsScrollView(
                    store: PrivateMessageStore.testLoaded(),
                    currentUserId: currentUserService.userKey.uid,
                    fromUserId: currentUserService.userKey.uid,
                    showToUser: true
                )
            }

            Section(header: Text("All Messages")) {
                PostsScrollView(
                    store: PrivateMessageStore.testLoaded(),
                    currentUserId: currentUserService.userKey.uid,
                    showFromUser: true,
                    showToUser: true
                )
            }
        }
        .padding()
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}

#Preview ("Empty") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    
    VStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
            Text("InBox")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            PostsScrollView(
                store: PrivateMessageStore.testEmpty(),
                currentUserId: currentUserService.userKey.uid,
                toUserId: currentUserService.userKey.uid,
                showFromUser: true
            )
        }
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
