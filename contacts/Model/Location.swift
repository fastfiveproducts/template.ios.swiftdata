//
//  Location.swift
//
//  Template by Pete Maiser, July 2024 through July 2025
//      Template v0.1.4 (updated)
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      used here per terms of the MIT License
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
//     Location: is a sample of a struct that is then later used in the app
//     and persisted locally using FileManager
//
//     Also note other examples/samples:
//     "ActivityLog" in this app is persisted locally using SwiftData
//     "Announcement" in this app is ready-only and sourced from Firebase Firestore
//     "User" in this app is a mix of Firebase Authentication and Firebase Data Connect
//     "Post" in this app is a read-write struct protocol with data stored via Firebase Data Connect
//


import Foundation

struct Location: Listable {
    var id = UUID()
    
    // attributes
    var displayName: String
    var forBreakfast = false
    var forLunch = false
    var forDinner = false
    var forHangout = false
    var forNightlife = false

    // to conform to Listable, use known data to describe the object
    var objectDescription: String {
        "Name: \(displayName)"
    }
    
    // to conform to Listable, supply a 'is valid' computed property
    var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        forBreakfast || forLunch || forDinner || forHangout || forNightlife
    }
}

// to conform to Listable, add placeholder features --
// some patterns use a 'placeholder' until/if data is available
extension Location {
    static let usePlaceholder = false
    static let placeholder = Location(displayName: "")
}

// create a CaptureForm ViewModel Fatory so this struct is capturable
extension Location {
    @MainActor static func makeCaptureFormViewModel(store: ListableFileStore<Location>) -> ListableCaptureFormModel<Location> {
        ListableCaptureFormModel(
            title: "Add new Location:",
            fields: [
                CaptureField(id: "displayName", labelText: "Name", promptText: "Name of this Meet-up Location", type: .text, required: true),
                CaptureField(id: "forBreakfast", labelText: "Breakfast", promptText: "Suitable for Breakfast?", type: .bool),
                CaptureField(id: "forLunch", labelText: "Lunch", promptText: "Suitable for Lunch?", type: .bool),
                CaptureField(id: "forDinner", labelText: "Dinner", promptText: "Suitable for Dinner?", type: .bool),
                CaptureField(id: "forHangout", labelText: "Hangout", promptText: "Suitable for Hangout?", type: .bool),
                CaptureField(id: "forNightlife", labelText: "Nightlife", promptText: "Suitable for Nightlife?", type: .bool)
            ],
            makeStruct: { fields in
                let dict = Dictionary(uniqueKeysWithValues: fields.map { ($0.id, $0) })
                return Location(
                    displayName: dict["displayName"]?.text ?? "",
                    forBreakfast: dict["forBreakfast"]?.bool ?? false,
                    forLunch: dict["forLunch"]?.bool ?? false,
                    forDinner: dict["forDinner"]?.bool ?? false,
                    forHangout: dict["forHangout"]?.bool ?? false,
                    forNightlife: dict["forNightlife"]?.bool ?? false
                )
            },
            insertAction: { item in
                store.insert(item)
            }
        )
    }
}


#if DEBUG
extension Location {
    static let testObjects: [Location] = [
        Location(displayName: "Eggies", forBreakfast: true),
        Location(displayName: "Sandwich Shop", forLunch: true, forHangout: true),
        Location(displayName: "The Diner", forBreakfast: true, forLunch: true, forDinner: true, forHangout: true),
        Location(displayName: "All Nighter", forDinner: true, forNightlife: true)
    ]
}
#endif
