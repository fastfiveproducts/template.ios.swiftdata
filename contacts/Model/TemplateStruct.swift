//
//  TemplateStruct.swift
//
//  Template by Pete Maiser, July 2024 through July 2025
//      Template v0.1.2 (July)
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
//
//     TemplateStruct: is a sample of a struct that is then later used in the app
//     and persisted locally using FileManager
//
//     TemplateObject: is a sample of a class that is then later used in the app
//     and persisted locally using SwiftData.  TODO:  actually add this
//
//     Also note other examples/samples:
//     "Annoucement" in this app is ready-only and sourced from Firebase Firestore
//     "User" in this app is a mix of Firebase Authentication and Firebase Data Connect
//     "Post" in this app is read-write and stored via Firebase Data Connect
//


import Foundation

struct TemplateStruct: Listable {
    var id = UUID()
    
    // attributes
    var passwordHint: String
    var favoriteColor: String
    var dogName: String

    // to conform to Listable, use known data to describe the object
    var objectDescription: String {
        "Hint: \(passwordHint), Color: \(favoriteColor), Dog: \(dogName)"
    }
    
    // add a helper to determine if a particular struct instance is valid
    var isValid: Bool {
        guard !favoriteColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !dogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            debugprint("validation failed.")
            return false
        }
        return true
    }
}

// to conform to Listable, add placeholder features --
// some patterns use a 'placeholder' until/if data is available
extension TemplateStruct {

    static let usePlaceholder = false
    static let placeholder = TemplateStruct(passwordHint: "", favoriteColor: "", dogName: "")
}

// create a CaptureForm ViewModel Fatory so this struct is capturable
extension TemplateStruct {
    @MainActor static func makeCaptureFormViewModel(store: ListableFileStore<TemplateStruct>) -> CaptureFormViewModel<TemplateStruct> {
        CaptureFormViewModel(
            title: "Sample Form",
            fields: [
                CaptureField(id: "passwordHint", labelText: "Password Hint", promptText: "optional: Password Hint", required: false, autoCapitalize: false, checkRestrictedWordList: false),
                CaptureField(id: "favoriteColor", labelText: "Favorite Color", promptText: "required: Favorite Color"),
                CaptureField(id: "dogName", labelText: "Dog's Name", promptText: "required: Your Dog's Name")
            ],
            makeStruct: { fields in
                let dict = Dictionary(uniqueKeysWithValues: fields.map { ($0.id, $0) })
                return TemplateStruct(
                    passwordHint: dict["passwordHint"]?.text ?? "",
                    favoriteColor: dict["favoriteColor"]?.text ?? "",
                    dogName: dict["dogName"]?.text ?? ""
                )
            },
            insertAction: { item in
                store.insert(item)
            }
        )
    }
}


#if DEBUG
extension TemplateStruct {
    static let testObject = TemplateStruct(
        passwordHint: "Sunshine",
        favoriteColor: "Blue",
        dogName: "Daisy"
    )
}
#endif
