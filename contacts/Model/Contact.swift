//
//  Contact.swift
//
//  Created by Pete Maiser on 7/12/25.
//      Template v0.1.3
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      used here per terms of template.ios License file
//
//  This particular implementation is for:
//      APP_NAME
//      started from template 20YY-MM-DD
//      modifications cannot be used or copied without permission from YOUR_NAME
//
//  READ and Delete when using template:
//     Contact: is a sample of a class that is used in the app
//     and persisted locally using SwiftData.
//
//     Also note other examples/samples:
//     "Annoucement" in this app is ready-only and sourced from Firebase Firestore
//     "User" in this app is a mix of Firebase Authentication and Firebase Data Connect
//     "Post" in this app is read-write and stored via Firebase Data Connect
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
