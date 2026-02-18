//
//  FeatureFlag.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.8 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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

struct FeatureFlag: Listable {
    var id: String { code }
    let code: String
    let enabled: Bool
}

extension FeatureFlag {    // to conform to Listable:
    var title: String { code }
    var content: String { enabled ? "enabled" : "disabled" }
    var objectDescription: String { "flag \(code): \(enabled ? "enabled" : "disabled")" }

    var isValid: Bool {
        !code.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static let usePlaceholder = true
    static var placeholder: [FeatureFlag] { ViewConfig.bundledFeatureFlags }
}


#if DEBUG
extension FeatureFlag {
    static var testObjects: [FeatureFlag] {
        [
            FeatureFlag(code: "publicComments", enabled: true),
            FeatureFlag(code: "privateMessages", enabled: true),
            FeatureFlag(code: "userDemographics", enabled: false),
            FeatureFlag(code: "userAssociations", enabled: false)
        ]
    }
}
#endif
