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
            // Main app behind
            if let container = modelContainerManager.container {
                MainMenuView(
                    currentUserService: currentUserService,
                    announcementStore: AnnouncementStore.shared,
                    publicCommentStore: PublicCommentStore.shared,
                    privateMessageStore: PrivateMessageStore.shared,
                )
                .modelContainer(container)
            } else {
                // Fallback while container loads
                ViewConfig.brandColor
                    .ignoresSafeArea()
            }

            // Global Overlays
            OverlayView()
                .zIndex(10)
            
            // Launch Screen Curtain Overlay (fades away)
            ViewConfig.brandColor
                .ignoresSafeArea()
                .opacity(showMain ? 0 : 1)
                .animation(.easeInOut(duration: 1.0), value: showMain)
                .zIndex(20)
        }
        .onAppear {
            if modelContainerManager.container == nil {
                OverlayManager.shared.show(.loading)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                withAnimation(.easeIn(duration: 1.25)) {
                    showMain = true
                }
            }
        }
        .onChange(of: modelContainerManager.container) { _, newValue in
            if newValue != nil {
                OverlayManager.shared.hide(.loading)
            }
        }
        .task {
            AnnouncementStore.shared.initialize()
            PublicCommentStore.shared.initialize()
            PrivateMessageStore.shared.initialize()
            HelpTextStore.shared.initialize()
            RestrictedWordStore.shared.enableRestrictedWordCheck()
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
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
