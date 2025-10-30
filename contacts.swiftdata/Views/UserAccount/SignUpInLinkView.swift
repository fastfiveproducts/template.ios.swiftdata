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
    var onNavigate: (() -> Void)? = nil
    
    var leadingText: String {
        if inToolbar, !currentUserService.isSignedIn {
            if #available(iOS 26, *) { return "" }
            else { return "Sign In →" }
        } else if inToolbar, currentUserService.isSignedIn {
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
        if inToolbar || !currentUserService.isSignedIn {
            
            if !inToolbar && !currentUserService.isSignedIn {
                Divider()
            }
            
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
                    .foregroundColor(ViewConfig.fgColor)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            
        } else {
            EmptyView( )
        }
        
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Preview (Signed-In)") {
                Text("ToolbarItem is filled,")
                Text("and no message below")
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
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Preview (Signed-Out)") {
                Text("ToolbarItem not filled,")
                Text("and there is a message below")
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
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif

