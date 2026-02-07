//
//  MessagesMainView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/4/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
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
    @StateObject private var viewModel = MessagesViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Conversation partners list
            conversationsList

            Spacer(minLength: 0)

            // New message search section
            Divider()
                .padding(.bottom, 16)
            newMessageSection
        }
        .styledView()
        .alert("Search Error", error: $viewModel.error)
        .polling({ store.fetch() })
    }

    // MARK: - Conversations List

    private var conversationsList: some View {
        let partners = store.conversationPartners(for: currentUserService.userKey.uid)

        return Group {
            if partners.isEmpty {
                VStack {
                    Text("No conversations yet")
                        .foregroundStyle(.secondary)
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
                                .foregroundStyle(.secondary)
                                .font(.title2)
                            Text(partner.userKey.displayName)
                                .font(.body)
                            Spacer()
                            Text(partner.lastMessageDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
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

    private var filteredSearchResults: [UserKey] {
        viewModel.searchResults.filter { $0.uid != currentUserService.userKey.uid }
    }

    private var existingPartnerIds: Set<String> {
        Set(store.conversationPartners(for: currentUserService.userKey.uid).map { $0.userKey.uid })
    }

    private var newMessageSection: some View {
        VStackBox(title: "New Conversation") {
            // Search field
            HStack {
                TextField("Search for user display name...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        performSearch()
                    }

                Button(action: performSearch) {
                    if viewModel.isSearching {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .disabled(viewModel.searchText.isEmpty || viewModel.isSearching)
            }
            .padding(.horizontal)

            // Search results
            if !filteredSearchResults.isEmpty {
                Divider()
                    .padding(.vertical, 8)

                ForEach(filteredSearchResults, id: \.uid) { user in
                    let hasExistingConversation = existingPartnerIds.contains(user.uid)
                    NavigationLink {
                        UserPostsStackView(
                            currentUserService: currentUserService,
                            viewModel: UserPostViewModel<PrivateMessage>(),
                            store: store,
                            sectionTitle: "Messages with \(user.displayName)",
                            composeTitle: "New Message",
                            textFieldLabel: "Message Text",
                            buttonText: "Send Message",
                            createPost: { candidate in
                                try await store.createPrivateMessage(from: candidate)
                            },
                            conversationWith: user
                        )
                    } label: {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundStyle(Color.accentColor)
                            Text(user.displayName)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(hasExistingConversation ? "Resume Conversation" : "Start Conversation")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                }
            } else if viewModel.hasSearched && !viewModel.isSearching {
                Text("No users found")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }

    // MARK: - Search

    private func performSearch() {
        Task {
            await viewModel.searchUsers()
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
