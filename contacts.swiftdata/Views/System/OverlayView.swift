//
//  OverlayView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 10/29/25.
//      Template v0.2.4 Fast Five Products LLC's public AGPL template.
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

struct OverlayView: View {
    @ObservedObject var overlayManager = OverlayManager.shared

    var body: some View {
        ZStack {
            ForEach(overlayManager.overlays) { overlay in
                Color.clear
                    .ignoresSafeArea()
                    .overlay(overlayContent(for: overlay))
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .zIndex(overlay.zIndex)
            }
        }
    }
    
    @ViewBuilder
    func overlayContent(for overlay: OverlayManager.OverlayItem) -> some View {
        switch overlay.state {
        case .splash:
            VStack {
                Text(ViewConfig.brandName)
                    .foregroundColor(ViewConfig.brandColor)
            }
            .minimumScaleFactor(0.6)
            .lineLimit(1)
        case .loading:
            VStack {
                Text(ViewConfig.brandName)      // preserve layout between splash and loading with clear text
                    .foregroundColor(.clear)
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ViewConfig.fgColor))
                    Text("Loading local data…")
                        .foregroundColor(ViewConfig.fgColor)
                }
            }
            .minimumScaleFactor(0.6)
            .lineLimit(1)
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

    enum OverlayState: Equatable {
        case splash
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

        var swiftUIAnimation: Animation? {
            switch self {
            case .none: return nil
            case .fast: return .easeInOut(duration: 0.5)
            case .slow: return .easeInOut(duration: 1.0)
            case .slideUp: return .spring(response: 0.6, dampingFraction: 0.8)
            case .custom(let anim): return anim
            }
        }
    }

    func show(_ state: OverlayState,
              animation: OverlayAnimation? = nil,
              view: AnyView? = nil,
              zIndex: Double = 10) {
        let anim = animation ?? state.defaultAnimation
        let newOverlay = OverlayItem(state: state,
                                     view: view,
                                     animation: anim,
                                     zIndex: zIndex)
        withAnimation(anim.swiftUIAnimation) {
            overlays.append(newOverlay)
        }
    }

    func hide(_ state: OverlayState? = nil) {
        withAnimation(.easeOut(duration: 0.3)) {
            if let state = state {
                overlays.removeAll { $0.state == state }
            } else {
                overlays.removeAll()
            }
        }
    }
}

private extension OverlayManager.OverlayState {
    var defaultAnimation: OverlayManager.OverlayAnimation {
        switch self {
        case .splash: return .slow
        case .loading: return .none
        case .custom: return .fast
        case .hidden: return .none
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
    return OverlayView()
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
    return OverlayView()
}
#Preview("Multiple") {
    let manager = OverlayManager.shared
    manager.overlays = [
        OverlayManager.OverlayItem(
            state: .splash,
            view: nil,
            animation: .slow,
            zIndex: 10
        ),
        OverlayManager.OverlayItem(
            state: .loading,
            view: nil,
            animation: .none,
            zIndex: 20
        )
    ]
    return OverlayView()
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
    return OverlayView()
}
#Preview("Hidden") {
    let manager = OverlayManager.shared
    manager.overlays = []
    return OverlayView()
}
#endif
