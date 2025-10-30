//
//  UserPostViewModel.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.3 (updated) Fast Five Products LLC's public AGPL template.
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


import Foundation

@MainActor
class UserPostViewModel<T: Post>: ObservableObject, DebugPrintable {
    
    // Status
    @Published private(set) var statusText = ""
    @Published var error: Error?
    @Published var isWorking = false

    // Capture
    var toUser: UserKey = UserKey.blankUser
    var capturedTitleText = ""
    var capturedContentText = ""
    
    // Validation
    func isReadyToSubmitComment() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedContentText.isEmpty {
            statusText = ("No Content Entered")
            isReady = false
        }
        
        if RestrictedWordStore.shared.containsRestrictedWords(capturedContentText) {
            statusText = "Content matched one or more keywords on our Restricted Text List. Please adjust.";
            isReady = false
        }
        
        return isReady
    }
    
    func isReadyToSendMessage() -> Bool {
        statusText = ""
        var isReady = true
        
        if capturedTitleText.isEmpty {
            statusText = ("No Subject Entered")
            isReady = false
        }
        if capturedContentText.isEmpty {
            statusText = ("No Content Entered")
            isReady = false
        }

        if RestrictedWordStore.shared.containsRestrictedWords(capturedTitleText) {
            statusText = "Subject matched one or more keywords on our Restricted Text List. Please adjust.";
            isReady = false
        }
        if RestrictedWordStore.shared.containsRestrictedWords(capturedContentText) {
            statusText = "Content matched one or more keywords on our Restricted Text List. Please adjust.";
            isReady = false
        }
        
        return isReady
    }
    
    // Create
    var postCandidate = PostCandidate.placeholder
    var createdPost = T.placeholder[0]
}
