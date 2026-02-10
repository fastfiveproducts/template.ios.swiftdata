//
//  HelpText.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/9/26.
//      Template v0.2.6 (updated) — Fast Five Products LLC's public AGPL template.
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

struct HelpText: Listable {
    var id: String { code }
    let code: String
    let text: String
}

extension HelpText {    // to conform to Listable:
    var title: String { code }
    var content: String { text }
    var objectDescription: String { "code \(code): text \(text)"}
    
    var isValid: Bool {
        !code.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static let usePlaceholder = true
    static var placeholder: [HelpText] = [
        HelpText(code: "testKey", text: "value of lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        HelpText(code: "testKeyAnother", text: "another value of lorem ipsum")
    ]
}


#if DEBUG
extension HelpText { static var testObjects: [HelpText] { placeholder } }
#endif
