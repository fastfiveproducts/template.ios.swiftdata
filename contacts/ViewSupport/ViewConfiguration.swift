//
//  ViewConfiguration.swift
//
//  Template by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      used here per terms of the MIT License
//
//  This particular implementation is for:
//      APP_NAME
//      started from template 20YY-MM-DD
//      modifications cannot be used or copied without permission from YOUR_NAME
//


import SwiftUI

// The "ViewConfiguration" struct contains smallish settings, config, and ref data
// specific to SwiftUI and this application that are generally hard-coded
// here or inferred quickly upon app startup
struct ViewConfiguration {
    
    static let dynamicSizeMax = DynamicTypeSize.xxxLarge
    
}


#if DEBUG
var isPreview: Bool { return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
#endif
