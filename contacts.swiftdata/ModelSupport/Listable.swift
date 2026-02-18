//
//  Listable.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.8 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
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
    var title: String { get }
    var content: String { get }
    var objectDescription: String { get }       // verbose object description for debug and logging purposes; may combine title, content, and other data
    var isValid: Bool { get }
    static var useBundledDefaults: Bool { get }
    static var bundledDefaults: [Self] { get }
}

extension Listable {
    static var typeDescription: String { String(describing: Self.self) }
}

extension Listable {
    func dateString(from date: Date?) -> String {
        guard let date else { return "unknown date" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
