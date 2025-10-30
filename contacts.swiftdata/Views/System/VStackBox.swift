//
//  VStackBox.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.4 (updated) Fast Five Products LLC's public AGPL template.
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

struct VStackBox<Content: View>: View {
    let titleView: AnyView
    let content: Content
    
    // no title
    init(@ViewBuilder content: () -> Content) {
        self.titleView = AnyView(EmptyView())
        self.content = content()
    }
    
    // "title" as just text
    init(title: String, @ViewBuilder content: () -> Content) {
        self.titleView = AnyView(
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        )
        self.content = content()
    }

    // accept an entire view as the title
    init<Title: View>(@ViewBuilder titleView: () -> Title, @ViewBuilder content: () -> Content) {
        self.titleView = AnyView(titleView())
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


#if DEBUG
#Preview ("fancy") {
    NavigationStack {
        VStackBox {
            HStack {
                Text("View-Title Example")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink {
                    VStackBox(title: "Text-Title Example") {
                        previewContent()
                    }
                } label: {
                    Text("Text-Title")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
        } content: {
            previewContent()
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
}
#Preview ("List") {
    VStackBox () {
        List {
            Text("Hello, World!")
            Text("Hello, World!")
            Text("Hello, World!")
        }
    }
}
@ViewBuilder
func previewContent() -> some View {
    Text("Hello World!")
    NavigationLink {
        VStackBox() {
            Text("Hello World!")
        }
    } label: {
        Text("No Title Example")
            .foregroundColor(.accentColor)
    }
}
#endif
