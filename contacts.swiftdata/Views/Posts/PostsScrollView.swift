//
//  PostsScrollView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/4/26.
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
import Combine

struct PostsScrollView<T: Post>: View {
    @ObservedObject var store: ListableStore<T>
    var currentUserId: String

    // Optional filters
    var fromUserId: String?
    var toUserId: String?
    var conversationWith: String?  // For message conversations: shows posts between currentUserId and this user
    
    // Optional visuals
    var showFromUser: Bool = false
    var showToUser: Bool = false
    var hideWhenEmpty: Bool = false

    // Sort order: when true, displays newest first at top (like a feed); default is newest at bottom (like Messages app)
    var newestAtTop: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch store.list {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()

            case .error(let error):
                Text("Error loading content: \(error.localizedDescription)")
                    .foregroundStyle(.red)
                    .padding()

            case .none:
                Text("No Posts Yet.")
                    .padding(.top, 10)

            case .loaded:
                let posts = filteredPosts
                if posts.isEmpty {
                    if hideWhenEmpty {
                        EmptyView()
                    } else {
                        VStack(alignment: .leading) {
                            Text("None!")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            Spacer(minLength: 0) // optional, to push empty state up
                        }
                    }
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(posts) { post in
                                    PostBubbleView(
                                        post: post,
                                        isSent: post.from.uid == currentUserId,
                                        showFromUser: showFromUser,
                                        showToUser: showToUser
                                    )
                                    .id(post.id)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 4)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .task {
                            try? await Task.sleep(for: .milliseconds(500))
                            scrollToBottom(posts, proxy: proxy, animated: false)
                        }
                        .onChange(of: posts.count) {
                            scrollToBottom(posts, proxy: proxy)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                            scrollToBottom(posts, proxy: proxy, animated: false)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                            scrollToBottom(posts, proxy: proxy)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var filteredPosts: [T] {
        guard case let .loaded(posts) = store.list else { return [] }
        let filtered = posts.filter { post in
            // Conversation filter: show messages between currentUser and conversationWith
            if let conversationWith = conversationWith {
                let sentToThem = post.from.uid == currentUserId && post.to.uid == conversationWith
                let receivedFromThem = post.from.uid == conversationWith && post.to.uid == currentUserId
                return sentToThem || receivedFromThem
            }
            // Standard filters (AND logic)
            let toMatch = toUserId == nil || post.to.uid == toUserId
            let fromMatch = fromUserId == nil || post.from.uid == fromUserId
            return toMatch && fromMatch
        }
        if newestAtTop {
            return filtered.sorted { $0.timestamp > $1.timestamp }
        } else {
            return filtered.sorted { $0.timestamp < $1.timestamp }
        }
    }
    
    private func scrollToBottom(_ posts: [T], proxy: ScrollViewProxy, animated: Bool = true) {
        if !newestAtTop, let lastPost = posts.last {
            if animated {
                withAnimation {
                    proxy.scrollTo(lastPost.id, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastPost.id, anchor: .bottom)
            }
        }
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
}

#Preview ("Newest on Top") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
           
    Section(header: Text("All Comments")) {
        PostsScrollView(
            store: PublicCommentStore.testLoaded(),
            currentUserId: currentUserService.userKey.uid,
            showFromUser: true,
            newestAtTop: true
        )
    }
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
}
#endif
