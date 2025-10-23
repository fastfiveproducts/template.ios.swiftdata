//
//  Announcement.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
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

struct Announcement: Listable {
    let id: Int
    let title: String
    let content: String
    let displayStartDate: Date
    let displayEndDate: Date
    private(set) var imageUrl: String?

    var isValid: Bool {
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension Announcement {
    // to conform to Listable, use known data to describe the object
    var objectDescription: String { "(\(id)) \(title): \(content)" }
}

extension Announcement {
    // to conform to Listable, add placeholder features
    static let usePlaceholder = false
    static let placeholder = [Announcement(
        id: 0,
        title: "",
        content: "Announcements not available!",
        displayStartDate: Date(),
        displayEndDate: Date()
    )]
}


#if DEBUG
extension Announcement {
    static let testObjects: [Announcement] = [
        Announcement(
            id: 202501311200,
            title: "A Lorem Ipsum Title",
            content: "Announcement content lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            displayStartDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            displayEndDate: Calendar.current.date(byAdding: .day, value: 364, to: Date())!
        ),
        Announcement(
            id: 202502281200,
            title: "Another Lorem Ipsum Title",
            content: "Another announcement content lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            displayStartDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            displayEndDate: Calendar.current.date(byAdding: .day, value: 365, to: Date())!
        )
    ]
}
#endif
