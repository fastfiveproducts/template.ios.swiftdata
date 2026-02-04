//
//  MessagesMainView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//      Template v0.2.5 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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

struct MessagesMainView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var store: PrivateMessageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Conversation partners list
            conversationsList

            Spacer(minLength: 0)

            // New message section (placeholder for Phase 2 user search)
            Divider()
            newMessageSection
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }

    // MARK: - Conversations List

    private var conversationsList: some View {
        let partners = store.conversationPartners(for: currentUserService.userKey.uid)

        return Group {
            if partners.isEmpty {
                VStack {
                    Text("No conversations yet")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            } else {
                List(partners, id: \.userKey.uid) { partner in
                    NavigationLink {
                        UserPostsStackView(
                            currentUserService: currentUserService,
                            viewModel: UserPostViewModel<PrivateMessage>(),
                            store: store,
                            sectionTitle: "Messages with \(partner.userKey.displayName)",
                            composeTitle: "New Message",
                            textFieldLabel: "Message Text",
                            buttonText: "Send Message",
                            createPost: { candidate in
                                try await store.createPrivateMessage(from: candidate)
                            },
                            conversationWith: partner.userKey
                        )
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.title2)
                            Text(partner.userKey.displayName)
                                .font(.body)
                            Spacer()
                            Text(partner.lastMessageDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - New Message Section

    private var newMessageSection: some View {
        VStackBox(title: "New Message") {
            Text("User search coming soon...")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
    }
}


#if DEBUG
#Preview ("With Conversations") {
    NavigationStack {
        MessagesMainView(
            currentUserService: CurrentUserTestService.sharedSignedIn,
            store: PrivateMessageStore.testLoaded()
        )
    }
}

#Preview ("Empty") {
    NavigationStack {
        MessagesMainView(
            currentUserService: CurrentUserTestService.sharedSignedIn,
            store: PrivateMessageStore()
        )
    }
}
#endif
