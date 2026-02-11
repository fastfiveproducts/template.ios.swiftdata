//
//  OverlayView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 10/29/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/11/26.
//      Template v0.2.6 (updated) — Fast Five Products LLC's public AGPL template.
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

enum OverlayState: Equatable {
    case splash
    case brand
    case loading
    case custom
    case hidden
}

enum OverlayAnimation: Equatable {
    case none
    case fast
    case slow
    case slideUp
    case custom(Animation)
}

struct OverlayView: View {
    @ObservedObject var overlayManager = OverlayManager.shared

    var body: some View {
        ZStack {
            ForEach(overlayManager.overlays) { overlay in
                Color.clear
                    .ignoresSafeArea()
                    .overlay(overlayContent(for: overlay))
                    .transition(.opacity)
                    .zIndex(overlay.zIndex)
            }
        }
        .styledView()
    }

    @ViewBuilder
    func overlayContent(for overlay: OverlayManager.OverlayItem) -> some View {
        switch overlay.state {
        case .splash:
            GeometryReader { geo in
                SplashView()
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(ViewConfig.fgColor)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea()
                    .id(geo.size)   // forces rebuild when size changes (e.g. iPad rotation)
            }
        case .brand:
            GeometryReader { geo in
                BrandTextView()
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(ViewConfig.fgColor)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea()
                    .id(geo.size)   // forces rebuild when size changes (e.g. iPad rotation)
            }
        case .loading:
            VStack {
                BrandTextView()
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.clear)     // invisible; preserves layout so loading indicator sits below brand center
                Text("\n")
                    .font(.title)
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ViewConfig.fgColor))
                    Text("loading data…")
                        .foregroundStyle(ViewConfig.fgColor)
                }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        case .custom:
            if let custom = overlay.view { custom }
        case .hidden:
            EmptyView()
        }
    }
}

@MainActor
final class OverlayManager: ObservableObject {
    static let shared = OverlayManager()
    private init() {}

    @Published var overlays: [OverlayItem] = []

    struct OverlayItem: Identifiable {
        let id = UUID()
        let state: OverlayState
        let view: AnyView?
        let animation: OverlayAnimation
        let zIndex: Double
    }

    func show(_ state: OverlayState,
              animation: OverlayAnimation? = nil,
              view: AnyView? = nil,
              zIndex: Double = 10
    ) {
        let anim = animation ?? state.defaultAnimation
        let newOverlay = OverlayItem(state: state,
                                     view: view,
                                     animation: anim,
                                     zIndex: zIndex)
        withAnimation(anim.swiftUIAnimation) {
            overlays.append(newOverlay)
        }
    }

    func hide(_ state: OverlayState? = nil,
              animation: OverlayAnimation? = nil
    ) {
        if let state = state {
            let anim = animation ?? state.defaultAnimation
            withAnimation(anim.swiftUIAnimation) {
                overlays.removeAll { $0.state == state }
            }
        } else {
            overlays.removeAll()
        }
    }
}


#if DEBUG
#Preview("Splash") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .splash,
            view: nil,
            animation: .slow,
            zIndex: 10
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}
#Preview("Brand") {
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
#Preview("Loading") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .loading,
            view: nil,
            animation: .none,
            zIndex: 15
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}
#Preview("Brand + Loading") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .brand,
            view: nil,
            animation: .none,
            zIndex: 10
        ),
        OverlayManager.OverlayItem(
            state: .loading,
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
#Preview("Splash + Brand + Loading") {
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
#Preview("Custom") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .custom,
            view: AnyView(
                VStackBox(widthMode: .fitContent) {
                    Text("Hello World!")
                }
            ),
            animation: .slideUp,
            zIndex: 25
        )
    ]
    return ZStack {
        ViewConfig.brandColor.ignoresSafeArea()
        OverlayView()
    }
}
#Preview("Hidden") {
    let manager = OverlayManager.shared
    manager.overlays = []
    return OverlayView()
}
#endif
