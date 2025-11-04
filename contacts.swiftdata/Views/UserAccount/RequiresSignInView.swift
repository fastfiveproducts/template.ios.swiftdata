//
//  RequiresSignInView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 11/3/25.
//      Template v0.2.4 Fast Five Products LLC's public AGPL template.
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

struct RequiresSignInView<Content: View>: View {
    @ObservedObject var currentUserService: CurrentUserService
    let content: () -> Content

    init(
        currentUserService: CurrentUserService,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.currentUserService = currentUserService
        self.content = content
    }

    var body: some View {
        Group {
            if currentUserService.isSignedIn {
                content()
            } else {
                VStackBox {
                    Text("Not Signed In!")
                    SignUpInLinkView(currentUserService: currentUserService)
                }
                Spacer()
            }
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    RequiresSignInView(currentUserService: currentUserService) {
        CommentPostsStackView(
            currentUserService: currentUserService,
            store: PublicCommentStore.testLoaded()
        )
    }
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("no-data and signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    RequiresSignInView(currentUserService: currentUserService) {
        CommentPostsStackView(
            currentUserService: currentUserService,
            store: PublicCommentStore()
        )
    }
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
