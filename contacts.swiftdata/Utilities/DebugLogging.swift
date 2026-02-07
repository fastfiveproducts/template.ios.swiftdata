//
//  DebugLogging.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.3 (updated) Fast Five Products LLC's public AGPL template.
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
import os.log

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

func deviceLog(_ message: StaticString, category: String = "General", error: Error? = nil) {
    
    let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "unknownBundleId"
    let log = OSLog(subsystem: bundleIdentifier, category: category)
    
    let msg = "\(message)"
    if let error = error {
        os_log(.error, log: log, "%{public}@ %@", msg, error.localizedDescription)
    } else {
        os_log(.error, log: log, "%{public}@", msg)
    }
    
}
