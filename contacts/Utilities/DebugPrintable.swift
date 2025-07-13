//
//  DebugPrintable.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.2 (split-renamed from DebugLogging)
//


import Foundation

protocol DebugPrintable {}

extension DebugPrintable {
    static var debug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    func debugprint(_ str: String) {
        if Self.debug {
            print("\(String(describing: self.self)) \(str)")
        }
    }
}
