//
//  ViewConfig.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.4 (updated) Fast Five Products LLC's public AGPL template.
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


import SwiftUI

// The "ViewConfig" ("View Configuration") struct contains smallish settings, config, and ref data
// specific to SwiftUI and this application that are generally hard-coded
// here or inferred quickly upon app startup
struct ViewConfig {
    static let dynamicSizeMax = DynamicTypeSize.xxxLarge
    
    // App-Specific Strings
    static let brandName = "Template App"
    
    static let privacyText = "Privacy Policy"
    static let privacyURL = URL(string: "https://www.fastfiveproducts.llc/")!

    static let supportText = "\(brandName) Support"
    static let supportURL = URL(string: "https://www.fastfiveproducts.llc/")!
    
    static let backgroundVideoName = ""
    static let backgroundVideoExtension = "mp4"
    
    // Launch Screen
    static let fadeMainViewInterval: TimeInterval = 1.25
    static let delayLoadingMessageInterval: TimeInterval = 1.25
    
    // Home Screen
    static let topHalfSpaceRatio: CGFloat = 0.6     // Top ratio when splitting screen top-to-bottom
    static let bottomTabBarSpace: CGFloat = 48      // Leave space for Tab Bar (if applicable)
    
    // Fixed Colors
    static let brandColor: Color =
        Color(.opaqueSeparator)
    
    static let linkColor: Color =
        Color.accentColor
    
    static let bgColor: Color =
        Color(UIColor.systemBackground)
    
    static let fgColor =
        Color(.label)
    
}

extension ViewConfig {
    struct SpashTextView: View {
        var body: some View {
            let lineOne = ViewConfig.brandName
            let lineTwo = ""
            Text(lineOne + lineTwo)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .lineLimit(nil)
        }
    }
}

extension OverlayState {
    var defaultAnimation: OverlayAnimation {
        switch self {
        case .splash: return .none
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


#if DEBUG
var isPreview: Bool { return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }

extension ViewConfig {
    // set the style for previews (MainViewPreviewWrapper)
    static let mainViewStyle: MainViewStyle = .menu
//    static let mainViewStyle: MainViewStyle = .tab
}

#Preview ("Colors") {
    ScrollView {
        VStackBox {
            Text("brandColor").foregroundStyle(ViewConfig.brandColor)
            Text("linkColor").foregroundStyle(ViewConfig.linkColor)
        }
        VStackBox (backgroundColor: ViewConfig.bgColor) {
            Text("fgColor on bgColor").foregroundStyle(ViewConfig.fgColor)
        }
        VStackBox (backgroundColor: Color(.gray)) {
            ColorTest()
        }
        VStackBox (backgroundColor: Color(.black)) {
            ColorTest()
        }
        VStackBox (backgroundColor: Color(.white)) {
            ColorTest()
        }
    }
    .styledView()
}

#Preview ("Splash Text") {
    ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        ViewConfig.SpashTextView()
            .font(.title)
            .fontWeight(.semibold)
            .foregroundStyle(ViewConfig.fgColor)
            .styledView()
    }
}

fileprivate struct ColorTest: View {
    var body: some View {
        Text("brandColor").foregroundStyle(ViewConfig.brandColor)
        Text("linkColor").foregroundStyle(ViewConfig.linkColor)
        Text("bgColor").foregroundStyle(ViewConfig.bgColor)
        Text("fgColor").foregroundStyle(ViewConfig.fgColor)
    }
}
#endif
