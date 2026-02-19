//
//  MessagesViewModel.swift
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


import Foundation

@MainActor
class MessagesViewModel: ObservableObject, DebugPrintable {

    // Search state
    @Published var searchText: String = ""
    @Published var searchResults: [UserKey] = []
    @Published var isSearching: Bool = false
    @Published var hasSearched: Bool = false
    @Published var error: Error?

    func searchUsers() async {
        guard !searchText.isEmpty else { return }

        isSearching = true
        error = nil

        do {
            let results = try await UsersConnector().searchUsers(byDisplayName: searchText.lowercased())
            searchResults = results
            isSearching = false
            hasSearched = true
        } catch {
            debugprint("🛑 ERROR:  User search failed: \(error)")
            self.error = error
            searchResults = []
            isSearching = false
            hasSearched = true
        }
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
        hasSearched = false
        error = nil
    }
}
