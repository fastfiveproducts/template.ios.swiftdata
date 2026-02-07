//
//  MainViewPreviewWrapper.swift
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

#if DEBUG
enum MainViewStyle {
    case menu
    case tab
}

struct MainViewPreviewWrapper<Content: View>: View {
    let currentUserService: CurrentUserService
    let style: MainViewStyle
    let content: Content
    
    init(
        currentUserService: CurrentUserService,
        style: MainViewStyle = ViewConfig.mainViewStyle,
        @ViewBuilder content: () -> Content
    ) {
        self.currentUserService = currentUserService
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            switch style {
            case .menu:
                VStack(alignment: .leading, spacing: 24) {
                    content
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("Other Menu Items") { }
                        } label: {
                            Label("Menu", systemImage: "line.3.horizontal")
                        }
                    }
                }
                .padding(.vertical)
                
            case .tab:
                TabView {
                    content
                        .tabItem {
                            Text("Main Tabs Go Here")
                        }
                }
                .environment(\.tabSafeAreaBackground, true)
                .navigationTitle(ViewConfig.brandName)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .styledView()
    }
}
#endif
