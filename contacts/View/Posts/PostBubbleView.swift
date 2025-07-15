//
//  PostBubbleView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
//


import SwiftUI

struct PostBubbleView: View {
    let post: any Post
    let isSent: Bool   // true = sent by current user
    var showFromUser: Bool = false
    var showToUser: Bool = false

    var bubbleColor: Color {
        isSent ? Color.accentColor : Color(.systemGray5)
    }

    var textColor: Color {
        isSent ? .white : .primary
    }

    var bubbleAlignment: Alignment {
        isSent ? .trailing : .leading
    }

    var body: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
            if showFromUser {
                HStack {
                    if isSent { Spacer() }
                    Text("From:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(post.from.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !isSent { Spacer() }
                }
                .frame(maxWidth: .infinity)
            }

            if showToUser {
                HStack {
                    if isSent { Spacer() }
                    Text("To:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(post.to.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !isSent { Spacer() }
                }
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 4) {
                if !post.title.isEmpty {
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(textColor)
                }

                Text(post.content)
                    .font(.body)
                    .foregroundColor(textColor)
            }
            .padding(10)
            .background(bubbleColor)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, alignment: bubbleAlignment)

            HStack {
                if isSent { Spacer() }
                Text(post.timestamp.formatted(.dateTime))
                    .font(.caption2)
                    .foregroundColor(.gray)
                if !isSent { Spacer() }
            }
            .padding(.horizontal, 10)
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}


#if DEBUG
#Preview ("Various Views") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Section(header: Text("All Comments View")) {
                PostBubbleView(post: PublicComment.testObject, isSent: true, showFromUser: true)
                PostBubbleView(post: PublicComment.testObjectAnother, isSent: false, showFromUser: true)
            }

            Section(header: Text("My Comments View")) {
                PostBubbleView(post: PublicComment.testObject, isSent: true)
            }

            Section(header: Text("Inbox Messages View")) {
                PostBubbleView(post: PrivateMessage.testObjectAnother, isSent: false, showFromUser: true)
            }

            Section(header: Text("Sent View")) {
                PostBubbleView(post: PrivateMessage.testObject, isSent: true, showToUser: true)
            }

            Section(header: Text("Private Messages No Filter (Mixed)")) {
                PostBubbleView(post: PrivateMessage.testObject, isSent: true, showToUser: true)
                PostBubbleView(post: PrivateMessage.testObjectAnother, isSent: false, showFromUser: true)
            }
        }
        .padding()
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
