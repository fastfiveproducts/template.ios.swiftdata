//
//  deviceLog.swift
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
import os.log

func deviceLog(_ message: StaticString, category: String = "General", error: Error? = nil) {
    
    let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "unknownBundleId"
    let log = OSLog(subsystem: bundleIdentifier, category: category)
    
    if let error = error {
        os_log(.error, log: log, "%{public}@ %@", message as? CVarArg ?? "unknown log message", error.localizedDescription)
    } else {
        os_log(.error, log: log, "%{public}@", message as? CVarArg ?? "unknown log message")
    }
    
}
