//
//  Posts.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/9/26.
//      Template v0.2.6 (updated) — Fast Five Products LLC's public AGPL template.
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

// base
protocol Post: Listable {
    var id: UUID { get }
    var timestamp: Date { get }
    var from: UserKey { get }
    var to: UserKey { get }
    var title: String { get }
    var content: String { get }
    var references: Set<UUID> { get }
    static var typeDisplayName: String { get }
}


// used to submit-send
struct PostCandidate: DebugPrintable {
    let from: UserKey
    var to: UserKey
    var title: String
    var content: String
    var references: Set<UUID> = []
    
    var isValid: Bool {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              from.isValid
        else {
            debugprint("validation failed.")
            return false
        }
        return true
    }
}


// optional reference to any other object:
struct PostReference {
    let id: UUID
    let referenceId: UUID
    
    var isValid: Bool {
        id != referenceId
    }
}


// search
extension Post {
    func contains(_ string: String) -> Bool {
        var properties = [title, content].map { $0.lowercased() }
        if !to.displayName.isEmpty {
            properties.append(to.displayName.lowercased())
        }
        if !from.displayName.isEmpty {
            properties.append(from.displayName.lowercased())
        }
        let query = string.lowercased()
        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}


// subtype of "public comment" (one-to-everyone, public)
// also supports to one-to-everyone with a 'to' for replies or callout
struct PublicComment: Post, Listable {
    private(set) var id: UUID
    private(set) var timestamp: Date
    let from: UserKey
    let to: UserKey
    let title: String
    let content: String
    var references: Set<UUID> = []
    
    // to conform to Post, establish a short displayable type description
    static let typeDisplayName: String = "Comment"
       
    // to conform to Listable, use known data to describe the object
    var objectDescription: String { "Comment from " + from.displayName + ": " + content }
    
    // to conform to Listable, supply a 'is valid' computed property
    var isValid: Bool {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              from.isValid
        else {
            debugprint("validation failed.")
            return false
        }
        return true
    }
}


// subtype of "private message" (one-to-one, private)
struct PrivateMessage: Post, Listable  {
    private(set) var id: UUID
    private(set) var timestamp: Date
    let from: UserKey
    let to: UserKey
    let title: String
    let content: String
    var references: Set<UUID> = []
    var status: [MessageStatus] = []
    
    // to conform to Post, establish a short displayable type description
    static let typeDisplayName: String = "Message"
    
    // to conform to Listable, use known data to describe the object
    var objectDescription: String { "Message from " + from.displayName + ": " + content }
    
    // to conform to Listable, supply a 'is valid' computed property
    var isValid: Bool {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              from.isValid,
              to.isValid
        else {
            debugprint("validation failed.")
            return false
        }
        return true
    }
}


// (private) message status
enum MessageStatusCode: String, Codable { case
    draft,
    sent,
    read,
    archived,
    deleted,
    error
}

struct MessageStatus: Codable, Hashable {
    private(set) var timestamp: Date?
    var uid: String
    var status: MessageStatusCode
}


// placeholders
extension PostCandidate {
    static let placeholder = PostCandidate(
        from: UserKey.blankUser,
        to: UserKey.blankUser,
        title: "",
        content: ""
    )
}

extension PublicComment {
    // to conform to Listable, add placeholder features
    static let usePlaceholder = false
    static let placeholder = [PublicComment(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        timestamp: Date(),
        from: UserKey.blankUser,
        to: UserKey.blankUser,
        title: "",
        content: "No Messages!"
    )]
}

extension PrivateMessage {
    // to conform to Listable, add placeholder features
    static let usePlaceholder = false
    static let placeholder = [PrivateMessage(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        timestamp: Date(),
        from: UserKey.blankUser,
        to: UserKey.blankUser,
        title: "",
        content: "No Messages!"
    )]
}


#if DEBUG
extension PrivateMessage {
    static let testObject = PrivateMessage(
        id: UUID(),
        timestamp: Date().addingTimeInterval(-86400*2),
        from: UserKey.testObject,
        to: UserKey.testObjectAnother,
        title: "Title Lorem Ipsum",
        content: "Test Message from tO to tOA, lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
    static let testObjectAnother = PrivateMessage(
        id: UUID(),
        timestamp: Date().addingTimeInterval(-86400*1),
        from: UserKey.testObjectAnother,
        to: UserKey.testObject,
        title: "Another Title Lorem ipsum",
        content: "Test Message from tOA  to tO, more Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
    static let testObjectTiny = PrivateMessage(
        id: UUID(),
        timestamp: Date(),
        from: UserKey.testObject,
        to: UserKey.testObjectAnother,
        title: "t",
        content: "tO to tOA"
    )
    static let testObjects: [PrivateMessage] = [.testObject, .testObjectAnother, .testObjectTiny]
}

extension PublicComment {
    static let testObject = PublicComment(
        id: UUID(),
        timestamp: Date().addingTimeInterval(-86400*2),
        from: UserKey.testObject,
        to: UserKey.blankUser,
        title: "",
        content: "Test Comment from tO, lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
    static let testObjectAnother = PublicComment(
        id: UUID(),
        timestamp: Date().addingTimeInterval(-86400*1),
        from: UserKey.testObjectAnother,
        to: UserKey.blankUser,
        title: "",
        content: "Test Comment from tOA, more lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
    static let testObjectTiny = PublicComment(
        id: UUID(),
        timestamp: Date(),
        from: UserKey.testObject,
        to: UserKey.blankUser,
        title: "",
        content: "tO comment"
    )
    static let testObjects: [PublicComment] = [.testObject, .testObjectAnother, .testObjectTiny]
}
#endif
