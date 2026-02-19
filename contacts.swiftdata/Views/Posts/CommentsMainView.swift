//
//  CommentsMainView.swift
//
//  Template file created by Pete Maiser, 7/15/2025
//  Renamed from CommentPostsStackView.swift by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.9 (updated) — Fast Five Products LLC's public AGPL template.
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

struct CommentsMainView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var store: PublicCommentStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PostsScrollView(
                store: store,
                currentUserId: currentUserService.userKey.uid,
                showFromUser: true,
                hideWhenEmpty: true
            )
            .padding(.horizontal)

            Spacer(minLength: 0)

            Divider()
                .padding(.top, 8)
                .padding(.bottom, 12)
            if currentUserService.isVerifiedUser {
                VStackBox(title: "Write a Comment") {
                    NavigationLink {
                        UserPostsStackView(
                            currentUserService: currentUserService,
                            viewModel: UserPostViewModel<PublicComment>(),
                            store: store,
                            sectionTitle: "Your Past Comments",
                            composeTitle: "Write a Comment",
                            textFieldLabel: "Comment Text",
                            buttonText: "Submit New Comment",
                            createPost: { candidate in
                                try await store.createPublicComment(from: candidate)
                            }
                        )
                    } label: {
                        HStack {
                            Spacer()
                            Text("My Comments")
                            Spacer()
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                }
            } else if currentUserService.isRealUser {
                VerifyEmailLinkView(currentUserService: currentUserService, showDivider: false)
                    .frame(maxWidth: .infinity)
            } else {
                SignUpInLinkView(currentUserService: currentUserService, showDivider: false)
                    .frame(maxWidth: .infinity)
            }
        }
        .styledView()
        .polling({ store.fetch() })
    }
}


#if DEBUG
#Preview ("no-data and signed-out") {
    NavigationStack {
        CommentsMainView(
            currentUserService: CurrentUserTestService.sharedSignedOut,
            store: PublicCommentStore()
        )
    }
}
#Preview ("test-data anonymous") {
    NavigationStack {
        CommentsMainView(
            currentUserService: CurrentUserTestService.sharedAnonymous,
            store: PublicCommentStore.testLoaded()
        )
    }
}

#Preview ("test-data unverified user") {
    NavigationStack {
        CommentsMainView(
            currentUserService: CurrentUserTestService.sharedUnverifiedUser,
            store: PublicCommentStore.testLoaded()
        )
    }
}
#Preview ("test-data signed-in") {
    NavigationStack {
        CommentsMainView(
            currentUserService: CurrentUserTestService.sharedSignedIn,
            store: PublicCommentStore.testLoaded()
        )
    }
}
#endif
