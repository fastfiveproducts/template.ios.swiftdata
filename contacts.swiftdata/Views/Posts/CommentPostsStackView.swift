//
//  CommentPostsStackView.swift
//
//  Template file created by Pete Maiser, 7/15/2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
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

struct CommentPostsStackView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var store: PublicCommentStore
    
    var body: some View {
        VStackBox {
            PostsScrollView(
                store: store,
                currentUserId: currentUserService.userKey.uid,
                showFromUser: true,
                hideWhenEmpty: true
            )
            Divider()
            NavigationLink {
                UserPostsStackView(
                    currentUserService: currentUserService,
                    viewModel: UserPostViewModel<PublicComment>(),
                    store: store,
                    sectionTitle: "Your Past Comments",
                    composeTitle: "Write Comment",
                    textFieldLabel: "Comment Text",
                    buttonText: "Submit New Comment",
                    createPost: { candidate in
                        try await store.createPublicComment(from: candidate)
                    }
                )
            } label: {
                HStack {
                    Spacer()
                    Text("Write a Comment")
                    Spacer()
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}


#if DEBUG
#Preview  {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let store = PublicCommentStore.testLoaded()
    CommentPostsStackView(
        currentUserService: currentUserService,
        store: store
    )
}
#endif
