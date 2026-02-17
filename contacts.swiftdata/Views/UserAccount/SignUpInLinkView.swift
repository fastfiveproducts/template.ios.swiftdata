//
//  SignUpInLinkView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/15/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.4 (updated) Fast Five Products LLC's public AGPL template.
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

struct SignUpInLinkView: View {
    @ObservedObject var currentUserService: CurrentUserService
    
    var inToolbar: Bool = false
    var inList: Bool = false
    var showDivider: Bool = true
    var onNavigate: (() -> Void)? = nil
    
    var leadingText: String {
        if inToolbar, currentUserService.isSignedIn {
            return ""
        } else if !inToolbar, !currentUserService.isSignedIn {
            return "Tap Here or"
        } else {
            return ""
        }
    }
    
    var trailingText: String {
        if !inToolbar {
            return "to Sign-In!"
        } else {
            return ""
        }
    }
    
    var body: some View {
        if inList, !currentUserService.isSignedIn {

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
                    Text(leadingText)
                    Image(systemName: NavigationItem.profile.systemImage)
                    Text(trailingText)
                    Spacer()
                }
                .foregroundStyle(ViewConfig.linkColor)
            }

        } else if inToolbar || !currentUserService.isSignedIn {

            if !inToolbar, !currentUserService.isSignedIn, showDivider { Divider() }

            NavigationLink {
                UserAccountView(
                    viewModel: UserAccountViewModel(),
                    currentUserService: currentUserService)
                .onAppear { onNavigate?() } 
            } label: {
                if inToolbar && currentUserService.isSignedIn {
                    Label("Account Profile", systemImage: "\(NavigationItem.profile.systemImage).fill")
                } else {
                    HStack {
                        Text(leadingText)
                        Image(systemName: currentUserService.isSignedIn
                              ? "\(NavigationItem.profile.systemImage).fill"
                              : NavigationItem.profile.systemImage)
                        Text(trailingText)
                    }
                    .foregroundStyle(ViewConfig.linkColor)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            
        } else {
            EmptyView( )
        }
        
    }
}


#if DEBUG
#Preview ("signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Preview Helper (Signed-In)") {
                Text("ToolbarItem above-right filled;")
                Text("NO link appears below this text")
                SignUpInLinkView(currentUserService: currentUserService)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SignUpInLinkView(currentUserService: currentUserService, inToolbar: true)
            }
        }
        Spacer()
    }
}
#Preview ("signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Preview Helper (Signed-Out)") {
                Text("ToolbarItem NOT filled;")
                Text("there IS a link below this text")
                SignUpInLinkView(currentUserService: currentUserService)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SignUpInLinkView(currentUserService: currentUserService, inToolbar: true)
            }
        }
        Spacer()
    }
}
#Preview ("Form-List signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    NavigationStack {
        Form {
            Section(header: Text("Form-List Preview")) {
                SignUpInLinkView(currentUserService: currentUserService, inList: true)
            }
        }
    }
}
#endif
