//
//  Contact.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 7/12/25.
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
import SwiftData

// Contact - example of data we might keep private - on our device only
// so for example's sake, we will store these via SwiftData

@Model
final class Contact {
    
    // attributes
    var firstName: String
    var lastName: String
    var isDog: Bool
    var contact: String
    var timestamp: Date

    init(firstName: String, lastName: String, isDog: Bool = false, contact: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.isDog = isDog
        self.contact = contact
        self.timestamp = Date()
    }
    
    var objectDescription: String {
        isDog ?
        "Dog: \(firstName) \(lastName)" :
        "Contact:  \(firstName) \(lastName)"
    }
    
    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension Contact {
    static var empty: Contact {
        Contact(firstName: "", lastName: "", contact: "")
    }
}


#if DEBUG
extension Contact {
    static let testObjects: [Contact] = [
        Contact(firstName: "Milhouse", lastName: "Van Houten", contact: "theHouse@vanhouten.org"),
        Contact(firstName: "Santas", lastName: "LittleHelper", isDog: true, contact: "here boy!")
    ]
}
#endif
