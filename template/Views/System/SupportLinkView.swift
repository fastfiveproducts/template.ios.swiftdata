//
//  SupportLinkView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 10/31/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/22/26.
//      Template v0.3.3 (updated) — Fast Five Products LLC's public AGPL template.
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

struct SupportLinkView: View {
    @ObservedObject var currentUserService: CurrentUserService
    
    var inToolbar: Bool = false
    var inList: Bool = false
    var showDivider: Bool = true
    var onNavigate: (() -> Void)? = nil
    
    var leadingText: String {
        if inToolbar {
            return ""
        } else if !currentUserService.isRealUser {
            return "Getting Started Tutorial"
        } else {
            return "Tap Here for Support"
        }
    }
    
    var trailingText: String {
        if inToolbar {
            return ""
        } else {
            return ""
        }
    }
    
    var body: some View {
        if inList {
            ZStack {
                NavigationLink {
                    SupportView()
                        .onAppear { onNavigate?() }
                } label: { EmptyView() }
                .opacity(0)
                HStack {
                    Spacer()
                    Text(leadingText)
                    Spacer()
                }
                .foregroundStyle(ViewConfig.linkColor)
            }
        } else if inToolbar {
            NavigationLink {
                SupportView()
                    .onAppear { onNavigate?() }
            } label: {
                if inToolbar && currentUserService.isRealUser {
                    Label("Account Profile", systemImage: "\(NavigationItem.support.systemImage).fill")
                } else {
                    HStack {
                        Text(leadingText)
                        Image(systemName: currentUserService.isRealUser
                              ? "\(NavigationItem.support.systemImage).fill"
                              : NavigationItem.support.systemImage)
                        Text(trailingText)
                    }
                    .foregroundStyle(ViewConfig.linkColor)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        } else {
            if showDivider { Divider() }
            
            NavigationLink {
                SupportView()
                    .onAppear { onNavigate?() } 
            } label: {
                if inToolbar && currentUserService.isRealUser {
                    Label("Account Profile", systemImage: "\(NavigationItem.support.systemImage).fill")
                } else {
                    HStack {
                        Text(leadingText)
                        Image(systemName: currentUserService.isRealUser
                              ? "\(NavigationItem.support.systemImage).fill"
                              : NavigationItem.support.systemImage)
                        Text(trailingText)
                    }
                    .foregroundStyle(ViewConfig.linkColor)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
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
                Text("and see the link below this text")
                SupportLinkView(currentUserService: currentUserService)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SupportLinkView(currentUserService: currentUserService, inToolbar: true)
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
                Text("and see the link below this text")
                SupportLinkView(currentUserService: currentUserService)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SupportLinkView(currentUserService: currentUserService, inToolbar: true)
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
                SupportLinkView(currentUserService: currentUserService, inList: true)
            }
        }
    }
}
#endif
