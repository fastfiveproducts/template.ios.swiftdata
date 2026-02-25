//
//  ViewHelpers.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 2/10/26 (split from ViewConfig.swift)
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/24/26.
//      Template v0.3.3 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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


import SwiftUI

#if DEBUG
var isPreview: Bool { return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
#endif

extension OverlayState {
    var defaultAnimation: OverlayAnimation {
        switch self {
        case .splash: return .none
        case .brand: return .none
        case .loading: return .none
        case .custom: return .slow
        case .hidden: return .none
        }
    }
}

extension OverlayAnimation {
    var swiftUIAnimation: Animation? {
        switch self {
        case .none: return nil
        case .fast: return .easeInOut(duration: 0.5)
        case .slow: return .easeInOut(duration: 2.0)
        case .slideUp: return .spring(response: 0.6, dampingFraction: 0.8)
        case .custom(let anim): return anim
        }
    }
}

extension View {
    func styledView() -> some View {
        self
            .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
            .environment(\.font, Font.body)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// Used by MainViewPreviewWrapper to signal tab-style safe area background
extension EnvironmentValues {
    var tabSafeAreaBackground: Bool {
        get { self[TabSafeAreaBackgroundKey.self] }
        set { self[TabSafeAreaBackgroundKey.self] = newValue }
    }
}
private struct TabSafeAreaBackgroundKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
