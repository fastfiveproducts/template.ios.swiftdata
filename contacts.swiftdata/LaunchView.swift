//
//  LaunchView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
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
            MainMenuView(
//            MainTabView(
                currentUserService: currentUserService,
                announcementStore: AnnouncementStore.shared,
                publicCommentStore: PublicCommentStore.shared,
                privateMessageStore: PrivateMessageStore.shared,
                
            )
            .modelContainer(modelContainerManager.container ?? ModelContainerManager.emptyContainer)
            .opacity(showMain ? 1 : 0)
            .zIndex(20)

            // Global Overlays
            OverlayView()
                .zIndex(30)
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
        
        // Initialize Cloud Repositories
        .task {
            RestrictedWordStore.shared.enableRestrictedWordCheck()
            HelpTextStore.shared.initialize()
            AnnouncementStore.shared.initialize()
            PublicCommentStore.shared.initialize()
            PrivateMessageStore.shared.initialize()
        }
        
        // Show Splash on Appear; set clock for loading-check
        .onAppear {
            OverlayManager.shared.show(.splash)

            // if still loading after some time has passed, tell the user about it
            DispatchQueue.main.asyncAfter(deadline: .now() + ViewConfig.delayLoadingMessageInterval) {
                if modelContainerManager.container == nil {
                    OverlayManager.shared.show(.loading)
                }
            }
        }
        
        // Fade-in Main when Loaded
        .onChange(of: modelContainerManager.container) { _, newValue in
            if newValue != nil {
                OverlayManager.shared.hide(.loading)
                withAnimation(.easeIn(duration: ViewConfig.fadeMainViewInterval)) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + ViewConfig.delayLoadingMessageInterval*2) {
            let container = modelContainerManager.makePreviewContainer()
            modelContainerManager.injectPreviewContainer(container)
        }
    }
}
#endif
