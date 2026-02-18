//
//  DeviceStamping.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/17/26.
//      Template v0.2.7 (updated) — Fast Five Products LLC's public AGPL template.
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
import UIKit

#if DEBUG
nonisolated(unsafe) var deviceIdentifierstampLogged: Bool = false
#endif

@MainActor
func deviceIdentifierstamp() -> String {
    
    // DEPENDENCY: this function accesses the Device ID; this should be considered in Privacy declarations and/or statements
    
    let stamp = UIDevice.current.identifierForVendor?.uuidString ?? "device stamp failed"
    
    #if DEBUG
    if !deviceIdentifierstampLogged {
        print("deviceIdentifierstamp() function called.  If this function is used, the Device ID Identifier 'Data Type' should be listed in the App Store Privacy section ⚠️.")
        print("deviceIdentifierstamp() returning: \(stamp)")
        deviceIdentifierstampLogged = true
    }
    #endif
    
    return stamp
}

func deviceTimestamp() -> String {
    
    let stamp = Date().description
    
    #if DEBUG
    print("deviceTimestamp() function returning: \(stamp)")
    #endif
    
    return stamp
}
