//
//  ActivityLogEntry.swift
//
//  Created by Elizabeth Maiser on 7/5/25.
//      Template v0.1.4 (updated)
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      used here per terms of template.ios License file
//
//  This particular implementation is for:
//      APP_NAME
//      started from template 20YY-MM-DD
//      modifications cannot be used or copied without permission
//      from YOUR_NAME
//

import Foundation
import SwiftData

@Model
final class ActivityLogEntry {
    var event: String
    var timestamp: Date
    
    init(_ event: String, timestamp: Date = Date()) {
        self.event = event
        self.timestamp = timestamp
    }
}


#if DEBUG
extension ActivityLogEntry {
    static let testObjects: [ActivityLogEntry] = [
        ActivityLogEntry("test event"),
        ActivityLogEntry("another test event")
    ]
}
#endif
