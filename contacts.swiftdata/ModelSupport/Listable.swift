//
//  Listable.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1 Fast Five Products LLC's public AGPL template.
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

protocol Listable: Identifiable, Equatable, Codable, DebugPrintable {
    var objectDescription: String { get }
    var isValid: Bool { get }
    static var usePlaceholder: Bool { get }
    static var placeholder: Self { get }
}

extension Listable {
    var title: String { String(describing: Self.self) }                     // TEMP as part of moving to v0.2.3
    var content: String { objectDescription }                               // TEMP as part of moving to v0.2.3
}

extension Listable {
    static var typeDescription: String { String(describing: Self.self) }
}

extension Listable {
    func dateString(from date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let string = date != nil ? dateFormatter.string(from: date!) : "unknown date"
        return string
    }
}
