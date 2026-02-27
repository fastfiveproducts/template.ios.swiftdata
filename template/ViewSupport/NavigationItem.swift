//
//  NavigationItem.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/26/26.
//      Template v0.3.4 (updated) — Fast Five Products LLC's public AGPL template.
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
import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case
        // Template Items:
        home,
        announcements,
        comments,
        messages,
        activity,
        settings,
        support,
        profile,
    
        // App-specific Items:
        contacts
    
    
    
    
    var id: String { rawValue }

    var label: String {
        switch self {
        // Template Items:
        case .home: return "Home"
        case .announcements: return "Announcements"
        case .comments: return "Public Comments"
        case .messages: return "Private Messages"
        case .activity: return "Activity Log"
        case .settings: return "Settings"
        case .support: return "Support"
        case .profile: return "User Profile"
            
        // App-specific Items:
        case .contacts: return "Contacts"
            
            
            
        }
    }
    
    var sortOrder: (Int, Int) {
        switch self {
        // Template Items:
        case .home: return (0,0)
        case .announcements: return (1,0)
        case .comments: return (1,4)    // visibility driven by feature flag
        case .messages: return (1,3)    // visibility driven by feature flag
        case .activity: return (2,0)    // visibility driven by feature flag
        case .settings: return (2,1)    // visibility driven by feature flag
        case .support: return (2,2)
        case .profile: return (-1,0)    // hide because template shows as separate item

        // App-specific Items:
        case .contacts: return (1,2)
            
            
            
        }
    }

    var featureFlagCode: String? {
        switch self {
        case .comments: return "publicComments"
        case .messages: return "privateMessages"
        case .activity: return "activityLog"
        case .settings: return "settings"
        default: return nil
        }
    }

    @MainActor
    var isVisible: Bool {
        guard sortOrder.0 >= 0 else { return false }
        guard let code = featureFlagCode else { return true }
        return FeatureFlagStore.shared.isEnabled(code)
    }

    var systemImage: String {
        switch self {
        // Template Items:
        case .home: return "house"
        case .announcements: return "megaphone"
        case .messages: return "bubble.left.and.bubble.right"
        case .comments: return "exclamationmark.bubble"
        case .activity: return "book.pages"
        case .settings: return "gearshape.fill"
        case .support: return "questionmark.circle"
        case .profile: return "person.text.rectangle"
            
        // App-specific Items:
        case .contacts: return "person.2.circle"
            
            
            
        }
    }
}

extension NavigationItem {
    var labelView: Label<Text, Image>  {
        Label(label, systemImage: systemImage)
    }
}
