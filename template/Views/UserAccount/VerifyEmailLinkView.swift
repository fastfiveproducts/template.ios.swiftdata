//
//  VerifyEmailLinkView.swift
//
//  Created by Claude, Fast Five Products LLC, on 2/18/26.
//      Template v0.3.3 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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

struct VerifyEmailLinkView: View {
    @ObservedObject var currentUserService: CurrentUserService

    var inList: Bool = false
    var showDivider: Bool = true
    var onNavigate: (() -> Void)? = nil

    var body: some View {
        if currentUserService.isRealUser && !currentUserService.isVerifiedUser {
            if inList {
                ZStack {
                    NavigationLink {
                        UserAccountView(
                            viewModel: UserAccountViewModel(),
                            currentUserService: currentUserService)
                        .onAppear { onNavigate?() }
                    } label: { EmptyView() }
                    .opacity(0)
                    HStack {
                        Spacer()
                        Text("Verify email")
                        Image(systemName: "envelope.badge.shield.half.filled")
                        Text("to unlock all features!")
                        Spacer()
                    }
                    .foregroundStyle(ViewConfig.linkColor)
                }
            } else {
                if showDivider { Divider() }

                NavigationLink {
                    UserAccountView(
                        viewModel: UserAccountViewModel(),
                        currentUserService: currentUserService)
                    .onAppear { onNavigate?() }
                } label: {
                    HStack {
                        Text("Verify your email")
                        Image(systemName: "envelope.badge.shield.half.filled")
                        Text("to unlock all features!")
                    }
                    .foregroundStyle(ViewConfig.linkColor)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        } else {
            EmptyView()
        }
    }
}


#if DEBUG
#Preview ("unverified user") {
    let currentUserService = CurrentUserTestService.sharedUnverifiedUser
    NavigationStack {
        VStackBox(title: "Preview Helper (Unverified)") {
            Text("Link should appear below this text")
            VerifyEmailLinkView(currentUserService: currentUserService)
        }
        Spacer()
    }
}
#Preview ("Form-List unverified user") {
    let currentUserService = CurrentUserTestService.sharedUnverifiedUser
    NavigationStack {
        Form {
            Section(header: Text("Form-List Preview")) {
                VerifyEmailLinkView(currentUserService: currentUserService, inList: true)
            }
        }
    }
}
#Preview ("verified user") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    NavigationStack {
        VStackBox(title: "Preview Helper (Verified)") {
            Text("NO link should appear below this text")
            VerifyEmailLinkView(currentUserService: currentUserService)
        }
        Spacer()
    }
}
#endif
