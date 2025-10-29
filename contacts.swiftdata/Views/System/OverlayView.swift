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
            switch overlayManager.state {
                
            case .hidden:
                EmptyView()
                
            case .splash:
                ViewConfig.bgColor
                    .ignoresSafeArea()
                    .overlay(
                        HeroView()
                            .transition(.opacity)
                    )
                    .zIndex(10)
                
            case .custom:
                if let custom = overlayManager.customView {
                    ViewConfig.bgColor
                        .ignoresSafeArea()
                        .overlay(
                            custom.transition(.opacity)
                        )
                        .zIndex(10)
                }
            }
        }
        .animation(overlayManager.animation.swiftUIAnimation, value: overlayManager.state)
    }
}

@MainActor
final class OverlayManager: ObservableObject {
    static let shared = OverlayManager()
    
    private init() {}

    @Published var state: OverlayState = .hidden
    @Published var animation: OverlayAnimation = .none
    
    // Optional dynamic overlay content
    @Published var customView: AnyView? = nil

    enum OverlayState: Equatable {
        case splash
        case hidden
        case custom
        
        var defaultAnimation: OverlayAnimation {
            switch self {
            case .splash: return .slow
            case .hidden: return .none
            case .custom: return .none
            }
        }
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


    func show(_ newState: OverlayState,
              animation: OverlayAnimation? = nil,
              view: AnyView? = nil)
    {
        withAnimation(animation?.swiftUIAnimation ?? newState.defaultAnimation.swiftUIAnimation) {
            self.state = newState
            self.animation = animation ?? newState.defaultAnimation
            self.customView = view
        }
    }

    func hide(animation: OverlayAnimation? = nil)
    {
        withAnimation(animation?.swiftUIAnimation ?? OverlayState.hidden.defaultAnimation.swiftUIAnimation) {
            state = .hidden
            customView = nil
        }
    }
}


#if DEBUG
#Preview("Splash") {
    let manager = OverlayManager.shared
    manager.state = .splash
    return OverlayView()
}
#Preview("Custom") {
    let manager = OverlayManager.shared
    manager.state = .custom
    manager.customView = AnyView(Text("Hello World"))
    return OverlayView()
}
#Preview("Hidden") {
    let manager = OverlayManager.shared
    manager.state = .hidden
    return OverlayView()
}
#endif
