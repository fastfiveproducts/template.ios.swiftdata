//
//  HomeViewModel.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.3 Fast Five Products LLC's public AGPL template.
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

class HomeViewModel: ObservableObject, DebugPrintable {
    
}

enum MenuItem: String, CaseIterable, Identifiable {
    case announcements,
         contacts,
         comments,
         messages,
         activity,
         settings,
         profile
    var id: String { rawValue }

    var label: String {
        switch self {
        case .announcements: return "Announcements"
        case .contacts: return "Contacts"
        case .comments: return "Public Comments"
        case .messages: return "Private Messages"
        case .activity: return "Activity Log"
        case .settings: return "Settings"
        case .profile: return "User Profile"
        }
    }
    
    var sortOrder: (Int, Int) {
        switch self {
        case .announcements: return (0,0)
        case .contacts: return (0,1)
        case .messages: return (0,2)
        case .comments: return (0,3)
        case .activity: return (1,0)
        case .settings: return (1,1)
        case .profile: return (1,2)
        }
    }

    var systemImage: String {
        switch self {
        case .announcements: return "megaphone"
        case .contacts: return "person.2.circle"
        case .messages: return "envelope"
        case .comments: return "text.bubble"
        case .activity: return "book.pages"
        case .settings: return "gearshape.fill"
        case .profile: return "person.text.rectangle"
        }
    }
}
