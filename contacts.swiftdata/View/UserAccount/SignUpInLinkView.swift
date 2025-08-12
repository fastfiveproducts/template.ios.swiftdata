//
//  SignUpInLinkView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/15/25.
//
//  Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
    var asPage: Bool = false
    var leadingText: String {
        if inToolbar { return "Sign In →" }
        else { return "Tap Here or" }
    }
    
    var body: some View {
        if !inToolbar { Divider() }
        
        NavigationLink {
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService)
        } label: {
            HStack {
                Spacer()
                Text(leadingText)
                Label("to Sign-Up or Sign-In!", systemImage: currentUserService.isSignedIn ? "\(MenuItem.profile.systemImage).fill" : MenuItem.profile.systemImage)
                Spacer()
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}


#Preview {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Greeting") {
                Text("Hello World!")
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
