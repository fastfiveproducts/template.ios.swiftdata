//
//  DeviceStamping.swift
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
