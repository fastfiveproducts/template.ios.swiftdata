//
//  RequiresSignInView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 11/3/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/26/26.
//      Template v0.3.4 (updated) — Fast Five Products LLC's public AGPL template.
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

struct RequiresSignInView<Content: View>: View {
    @ObservedObject var currentUserService: CurrentUserService
    var requiresRealUser: Bool = false
    var requiresVerifiedUser: Bool = false
    let content: () -> Content

    init(
        currentUserService: CurrentUserService,
        requiresRealUser: Bool = false,
        requiresVerifiedUser: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.currentUserService = currentUserService
        self.requiresRealUser = requiresRealUser
        self.requiresVerifiedUser = requiresVerifiedUser
        self.content = content
    }

    private var isAuthorized: Bool {
        if requiresVerifiedUser { return currentUserService.isVerifiedUser }
        else if requiresRealUser { return currentUserService.isRealUser }
        else { return currentUserService.isSignedIn }
    }

    // AnyView is used deliberately here — the branches return different view
    // types and the performance cost is negligible for these simple layouts.
    var body: some View {
        Group {
            if isAuthorized {
                AnyView(content())
            } else if requiresVerifiedUser && currentUserService.isRealUser {
                AnyView(
                    Form {
                        VerifyEmailView(currentUserService: currentUserService)
                    }
                )
            } else {
                AnyView(
                    VStackBox {
                        Text(requiresRealUser || requiresVerifiedUser ? "Sign In Required" : "Not Signed In!")
                        SignUpInLinkView(currentUserService: currentUserService)
                    }
                )
            }
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    RequiresSignInView(currentUserService: currentUserService) {
        CommentsMainView(
            currentUserService: currentUserService,
            store: PublicCommentStore.testLoaded()
        )
    }
}
#Preview ("no-data and signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    RequiresSignInView(currentUserService: currentUserService) {
        CommentsMainView(
            currentUserService: currentUserService,
            store: PublicCommentStore()
        )
    }
}
#Preview ("test-data unverified user") {
    let currentUserService = CurrentUserTestService.sharedUnverifiedUser
    RequiresSignInView(currentUserService: currentUserService, requiresVerifiedUser: true) {
        CommentsMainView(
            currentUserService: currentUserService,
            store: PublicCommentStore.testLoaded()
        )
    }
}
#endif
