//
//  CaptureField.swift
//
//  Template created by Pete Maiser, July 2024 through July 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2 (renamed and split-out from TextCaptureSectionView)
//


import Foundation

enum CaptureType: String, Codable { case
    bool,
    text
}

struct CaptureField: Identifiable {
    var id: String            // this will be the 'name' of the field; 'id' ensures conformance to Identifiable
    var labelText: String
    var promptText: String
    var type: CaptureType
    var bool: Bool = false
    var text: String = ""
    var required: Bool = false
    var autoCapitalize: Bool = true
    var checkRestrictedWordList: Bool = true

    var value: Any {
        switch type {
        case .bool:
            return bool
        case .text:
            return text
        }
    }
    
    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !required
    }
}
