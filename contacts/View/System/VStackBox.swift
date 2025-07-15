//
//  VStackBox.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.4 (updated)
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
#Preview ("List") {
    VStackBox () {
        List {
            Text("Hello, World!")
            Text("Hello, World!")
            Text("Hello, World!")
        }
    }
}
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
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
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
