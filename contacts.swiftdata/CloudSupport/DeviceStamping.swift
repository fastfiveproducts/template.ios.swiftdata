//
//  DeviceStamping.swift
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
import UIKit

func deviceIdentifierstamp() -> String {
    
    // DEPENDENCY: if this function is used, the Privacy Statement must tell users we record an identifier from their device
    
    let stamp = UIDevice.current.identifierForVendor?.uuidString ?? "device stamp failed"
    
    #if DEBUG
    print("deviceIdentifierstamp() function called.  If this function is used, the Privacy Statement must tell users we record an identifier from their device.")
    print("deviceIdentifierstamp() function returning: \(stamp)")
    #endif
    
    return stamp
}

func deviceTimestamp() -> String {
    
    let stamp = Date().description
    
    #if DEBUG
    print("deviceTimestamp() function returning: \(stamp)")
    #endif
    
    return Date().description
}
