//
//  PostBubbleView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1 Fast Five Products LLC's public AGPL template.
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
                        .foregroundStyle(.secondary)
                    Text(post.from.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !isSent { Spacer() }
                }
                .frame(maxWidth: .infinity)
            }

            if showToUser {
                HStack {
                    if isSent { Spacer() }
                    Text("To:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(post.to.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !isSent { Spacer() }
                }
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 4) {
                if !post.title.isEmpty {
                    Text(post.title)
                        .font(.headline)
                        .foregroundStyle(textColor)
                }

                Text(post.content)
                    .font(.body)
                    .foregroundStyle(textColor)
            }
            .padding(10)
            .background(bubbleColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity, alignment: bubbleAlignment)

            HStack {
                if isSent { Spacer() }
                Text(post.timestamp.formatted(.dateTime))
                    .font(.caption2)
                    .foregroundStyle(.gray)
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
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
