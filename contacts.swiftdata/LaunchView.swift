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
    let fadeInterval: TimeInterval = 1.25
    let delayLoadingMessageInterval: TimeInterval = 1.25
    
    var body: some View {
        ZStack {
            // Brand Color behind
            ViewConfig.brandColor.ignoresSafeArea()
                .zIndex(10)
                        
            // Main App
            MainMenuView(
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
        
        // Show Splash on Appear; set Clocks
        .onAppear {
            OverlayManager.shared.show(.splash)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayLoadingMessageInterval) {
                // if still loading at this time...tell the user about it
                if modelContainerManager.container == nil {
                    OverlayManager.shared.show(.loading)
                }
            }

            // Setup a timing sequence for Previews
            #if DEBUG
            if isPreview {
                DispatchQueue.main.asyncAfter(deadline: .now() + delayLoadingMessageInterval) {
                    OverlayManager.shared.show(.loading)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delayLoadingMessageInterval*2) {
                    OverlayManager.shared.hide(.loading)
                    withAnimation(.easeIn(duration: fadeInterval)) {
                        showMain = true
                    }
                }
            }
            #endif
        }
        
        // Fade-in Main when Loaded
        .onChange(of: modelContainerManager.container) { _, newValue in
            if newValue != nil {
                OverlayManager.shared.hide(.loading)
                withAnimation(.easeIn(duration: fadeInterval)) {
                    showMain = true
                }
            }
        }
    }
}


#if DEBUG
import SwiftData
#Preview ("test-data max") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    
    let schema = RepositoryConfig.modelContainerSchema
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    for object in ActivityLogEntry.testObjects {
        container.mainContext.insert(object)
    }
    
    for object in Contact.testObjects {
        container.mainContext.insert(object)
    }

    let modelContainerManager = ModelContainerManager(currentUserService: currentUserService)
    modelContainerManager.injectPreviewContainer(container)

    return LaunchView(
        currentUserService: currentUserService,
        modelContainerManager: modelContainerManager
    )
    .modelContainer(container)
}
#endif
