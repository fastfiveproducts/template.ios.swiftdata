//
//  Announcement.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
//


import Foundation

struct Announcement: Listable {
    let id: Int
    let title: String
    let content: String
    let displayStartDate: Date
    let displayEndDate: Date
    private(set) var imageUrl: String?

    // to conform to Listable, use known data to describe the object
    var objectDescription: String { content }
}

extension Announcement {
    // to conform to Listable, add placeholder features
    static let usePlaceholder = false
    static let placeholder = Announcement(
        id: 0,
        title: "",
        content: "Announcements not available!",
        displayStartDate: Date(),
        displayEndDate: Date()
    )
}


#if DEBUG
extension Announcement {
    static let testObject = Announcement(
        id: 202501311200,
        title: "A Lorem Ipsum Title",
        content: "Announcement content lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        displayStartDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        displayEndDate: Calendar.current.date(byAdding: .day, value: 364, to: Date())!
    )
    static let testObjectAnother = Announcement(
        id: 202502281200,
        title: "Another Lorem Ipsum Title",
        content: "Another announcement content lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        displayStartDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        displayEndDate: Calendar.current.date(byAdding: .day, value: 365, to: Date())!
    )
    static let testObjects: [Announcement] = [.testObject, .testObjectAnother]
}
#endif
