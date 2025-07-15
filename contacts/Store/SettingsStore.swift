//  SettingsView.swift
//
//  Created by Elizabeth Maiser on 7/7/25.
//      Template v0.1.3
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
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("darkMode") var darkMode = false
    @AppStorage("soundEffects") var soundEffects = true
    
    func resetAllSettings() {
        darkMode = false
        soundEffects = true
    }
}
