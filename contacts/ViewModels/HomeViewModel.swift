//
//  HomeViewModel.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//
//      Template v0.1.3
//


import Foundation
import SwiftUI

class HomeViewModel: ObservableObject, DebugPrintable {
    
}

enum MenuItem: String, CaseIterable, Identifiable {
    case announcements,
         contacts,
         locations,
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
        case .locations: return "Meet-up Spots"
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
        case .locations: return (0,2)
        case .messages: return (0,3)
        case .comments: return (0,4)
        case .activity: return (1,0)
        case .settings: return (1,1)
        case .profile: return (1,2)
        }
    }

    var systemImage: String {
        switch self {
        case .announcements: return "megaphone"
        case .contacts: return "person.2.circle"
        case .locations: return "mappin.and.ellipse"
        case .messages: return "envelope"
        case .comments: return "text.bubble"
        case .activity: return "book.pages"
        case .settings: return "gearshape.fill"
        case .profile: return "person.text.rectangle"
        }
    }
}
