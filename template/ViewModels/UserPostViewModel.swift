//
//  UserPostViewModel.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.8 (updated) — Fast Five Products LLC's public AGPL template.
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


import Foundation

@MainActor
class UserPostViewModel<T: Post>: ObservableObject, DebugPrintable {
    
    // Status
    @Published private(set) var statusText = ""
    func clearStatus() { statusText = "" }
    @Published var error: Error?
    @Published var isWorking = false

    // Capture
    var toUser: UserKey = UserKey.blankUser
    var capturedTitleText = ""
    @Published var capturedContentText = ""
    
    // Validation
    func isReadyToPost() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedContentText.isEmpty {
            statusText = ("No Content Entered")
            isReady = false
        } else if capturedTitleText.count > 100 {
            statusText = "Title is too long"
            isReady = false
        } else if capturedContentText.count > 1000 {
            statusText = "Content is too long"
            isReady = false
        } else if RestrictedWordStore.shared.containsRestrictedWords(capturedContentText) {
            statusText = "Content matched one or more keywords on our Restricted Text List. Please adjust."
            isReady = false
        }
        
        return isReady
    }
        
    // Create
    var postCandidate = PostCandidate.placeholder
    var createdPost = T.bundledDefaults[0]
}
