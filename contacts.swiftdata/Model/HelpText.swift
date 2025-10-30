//
//  HelpText.swift
//
//  Template created by Pete Maiser, July 2024 through October 2025
//      Template v0.2.3 Fast Five Products LLC's public AGPL template.
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
        HelpText(code: "incomeTypeGuidance", text: "Maximize what you earn with all seven types of Income:"),
        HelpText(code: "corePrincipleGuidance", text: "Own your future with the Streems Core Principles:"),
        HelpText(code: "proResourceGuidance", text: "These Professionsal Resources can help you plan and manage your Income:"),
        HelpText(code: "onlineResourceGuidance", text: "These Online Resources can help you build additional Streems of Income!")
    ]
}


#if DEBUG
extension HelpText { static var testObjects: [HelpText] { placeholder } }
#endif
