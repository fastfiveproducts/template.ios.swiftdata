//  SettingsView.swift
//
//  Template file created by Elizabeth Maiser, Fast Five Products LLC, on 7/5/25.
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("darkMode") var darkMode = false
    @AppStorage("soundEffects") var soundEffects = true
    
    func resetAllSettings() {
        darkMode = false
        soundEffects = true
    }
}
