//
//  LaunchView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.8 (updated) — Fast Five Products LLC's public AGPL template.
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

struct LaunchView: View {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var modelContainerManager: ModelContainerManager

    @State private var showMain = false

    var body: some View {
        ZStack {
            // Brand Color behind
            ViewConfig.brandColor.ignoresSafeArea()
                .zIndex(10)

            // Main App
            if showMain {
                MainMenuView(
//                MainTabView(
                    currentUserService: currentUserService,
                    announcementStore: AnnouncementStore.shared,
                    publicCommentStore: PublicCommentStore.shared,
                    privateMessageStore: PrivateMessageStore.shared,

                )
                .modelContainer(modelContainerManager.container ?? ModelContainerManager.emptyContainer)
                .transition(.opacity)
                .zIndex(20)
            }

            // Global Overlays
            OverlayView()
                .zIndex(30)
        }
        .styledView()

        // Initialize Repositories
        // Note: stores with requiresSignIn (PublicCommentStore, PrivateMessageStore)
        // are initialized via postSignInSetup() when the user signs in
        .task {
            FeatureFlagStore.shared.initialize()                        // Load from server (bundled fallback)
            // FeatureFlagStore.shared.initializeWithBundledFlags()     // Load from bundle
            RestrictedWordStore.shared.enableRestrictedWordCheck()      // Load from server (bundled fallback)
            // RestrictedWordStore.shared.enableRestrictedWordCheckWithBundledWords()  // Load from bundle
            HelpTextStore.shared.initialize()
            AnnouncementStore.shared.initialize()
        }

        .onAppear {
            // Show Splash overlay on Appear
            OverlayManager.shared.show(.splash)

            // Fade-out Splash after splashDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + ViewConfig.splashDuration) {
                OverlayManager.shared.hide(.splash,
                    animation: .custom(.easeInOut(duration: ViewConfig.splashFadeDuration)))
            }

            // If still loading after some time has passed, show Loading overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + ViewConfig.loadingOverlayDelay) {
                if modelContainerManager.container == nil {
                    OverlayManager.shared.show(.loading)
                }
            }
        }

        // Fade-in Main when Loaded
        .onChange(of: modelContainerManager.container) { _, newValue in
            if newValue != nil {
                OverlayManager.shared.hide(.loading)
                withAnimation(.easeIn(duration: ViewConfig.mainFadeDuration)) {
                    showMain = true
                }
            }
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
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
#endif
