//
//  NavigationItem.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.4 (updated) Fast Five Products LLC's public AGPL template.
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
import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case home,
         announcements,
         contacts,
         comments,
         messages,
         activity,
         settings,
         support,
         profile
    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: return "Home"
        case .announcements: return "Announcements"
        case .contacts: return "Contacts"
        case .comments: return "Public Comments"
        case .messages: return "Private Messages"
        case .activity: return "Activity Log"
        case .settings: return "Settings"
        case .support: return "Support"
        case .profile: return "User Profile"
        }
    }
    
    var sortOrder: (Int, Int) {
        switch self {
        case .home: return (0,0)
        case .announcements: return (1,0)
        case .contacts: return (1,2)
        case .messages: return (-1,0)   // hide
        case .comments: return (-1,0)   // hide
        case .activity: return (2,0)
        case .settings: return (2,1)
        case .support: return (2,2)
        case .profile: return (-1,0)    // hide
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .announcements: return "megaphone"
        case .contacts: return "person.2.circle"
        case .messages: return "envelope"
        case .comments: return "text.bubble"
        case .activity: return "book.pages"
        case .settings: return "gearshape.fill"
        case .support: return "questionmark.circle"
        case .profile: return "person.text.rectangle"
        }
    }
}

extension NavigationItem {
    var labelView: Label<Text, Image>  {
        Label(label, systemImage: systemImage)
    }
}
