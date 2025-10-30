//
//  VStackBox.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
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

struct VStackBox<Content: View>: View {
    let titleView: AnyView
    let content: Content
    var widthMode: VStackBoxWidthMode = .expand
       
    // no title
    init(widthMode: VStackBoxWidthMode = .expand, @ViewBuilder content: () -> Content) {
        self.titleView = AnyView(EmptyView())
        self.content = content()
        self.widthMode = widthMode
    }

    // "title" as just text
    init(title: String, widthMode: VStackBoxWidthMode = .expand, @ViewBuilder content: () -> Content) {
        self.titleView = AnyView(
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        )
        self.content = content()
        self.widthMode = widthMode
    }

    // accept an entire view as the title
    init<Title: View>(
        widthMode: VStackBoxWidthMode = .expand,
        @ViewBuilder titleView: () -> Title,
        @ViewBuilder content: () -> Content
    ) {
        self.titleView = AnyView(titleView())
        self.content = content()
        self.widthMode = widthMode
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
            content
        }
        .padding()
        .frame(
            maxWidth: widthMode == .fitContent ? nil : .infinity,
            alignment: .leading
        )
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

enum VStackBoxWidthMode {
    case expand        // fills width
    case fitContent    // resizes to content
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
#Preview ("Resize") {
    VStackBox(widthMode: .fitContent) {
        Text("Hello, World!")
    }
}
@ViewBuilder
func previewContent() -> some View {
    Text("Hello World!")
    NavigationLink {
        VStackBox() {
            Text("Simple Example: Hello World!")
        }
    } label: {
        Text("Click for Simple Example")
            .foregroundColor(.accentColor)
    }
}
#endif
