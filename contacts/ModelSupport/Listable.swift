//
//  Listable.swift
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

protocol Listable: Identifiable, Equatable, Codable, DebugPrintable {
    var objectDescription: String { get }
    static var usePlaceholder: Bool { get }
    static var placeholder: Self { get }
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
