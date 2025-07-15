//
//  ListableCaptureFormModel.swift
//
//  Created by Pete Maiser on 6/20/25.
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.4 (updated)
//


import Foundation

@MainActor
class ListableCaptureFormModel<T: Listable>: ObservableObject {
    @Published var fields: [CaptureField]

    let title: String
    private let makeStruct: ([CaptureField]) -> T
    private let insertAction: (T) -> Void

    init(
        title: String,
        fields: [CaptureField],
        makeStruct: @escaping ([CaptureField]) -> T,
        insertAction: @escaping (T) -> Void
    ) {
        self.title = title
        self.fields = fields
        self.makeStruct = makeStruct
        self.insertAction = insertAction
    }

    var isValid: Bool {
        guard fields.allSatisfy({ $0.isValid }) else { return false }
        let item = makeStruct(fields)
        return item.isValid
    }

    func insert() {
        let newItem = makeStruct(fields)
        insertAction(newItem)
    }
}

