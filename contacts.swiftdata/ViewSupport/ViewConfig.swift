//
//  ViewConfig.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/11/26.
//      Template v0.2.6 (updated) — Fast Five Products LLC's public AGPL template.
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


import SwiftUI

// The "ViewConfig" ("View Configuration") struct contains branding,
// settings, config, and reference data specific to this implementation

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

    // Launch Sequence - Splash
    static let splashDuration: TimeInterval = 1.25          // time before splash image begins fade-out
    static let splashFadeDuration: TimeInterval = 1.25      // fade-out duration (0 = no fade-out)

    // Launch Sequence - Main View
    static let mainFadeDelay: TimeInterval = 1.25           // time before fade-in starts
    static let mainFadeDuration: TimeInterval = 1.25        // fade-in duration (0 = no fade-in)

    // Launch Sequence - Background Task Overlays (if needed)
    static let loadingOverlayDelay: TimeInterval = 1.25     // show "loading" overlay if still loading after this time

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

struct SplashView: View {
    var body: some View {
        GeometryReader { geo in
            BrandTextView()
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()
                .id(geo.size)   // forces rebuild when size changes (e.g. iPad rotation)
        }
    }
}

struct BrandTextView: View {
    var body: some View {
        let lineOne = ViewConfig.brandName
        let lineTwo = ""
        Text(lineOne + lineTwo)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .lineLimit(nil)
    }
}


#if DEBUG
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

#Preview ("Splash") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .splash,
            view: nil,
            animation: .none,
            zIndex: 10
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}
#Preview ("Brand Text") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .brand,
            view: nil,
            animation: .none,
            zIndex: 10
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}
#Preview ("Splash + Brand Text") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .splash,
            view: nil,
            animation: .none,
            zIndex: 10
        ),
        OverlayManager.OverlayItem(
            state: .brand,
            view: nil,
            animation: .none,
            zIndex: 20
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}

#Preview ("Splash + Brand + Loading") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .splash,
            view: nil,
            animation: .none,
            zIndex: 10
        ),
        OverlayManager.OverlayItem(
            state: .brand,
            view: nil,
            animation: .none,
            zIndex: 20
        ),
        OverlayManager.OverlayItem(
            state: .loading,
            view: nil,
            animation: .none,
            zIndex: 30
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}

#Preview ("Live Launch") {
    let currentUserService: CurrentUserService = CurrentUserTestService.sharedSignedIn
    let modelContainerManager = ModelContainerManager(currentUserService: currentUserService)

    LaunchView(
        currentUserService: currentUserService,
        modelContainerManager: modelContainerManager
    )
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + ViewConfig.loadingOverlayDelay+0.5) {
            let container = modelContainerManager.makePreviewContainer()
            modelContainerManager.injectPreviewContainer(container)
        }
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
