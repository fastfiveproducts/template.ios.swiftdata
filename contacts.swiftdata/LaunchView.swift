//
//  LaunchView.swift
//
//  Template created by Pete Maiser, July 2024 through October 2025
//      Template v0.2.3 Fast Five Products LLC's public AGPL template.
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

    @State private var showLoading = false
    @State private var showOverlay = false
    @State private var showMain = false
    
    var body: some View {
        ZStack {
            // Main app behind
            if let container = modelContainerManager.container {
                HomeView(
                    currentUserService: currentUserService,
                    announcementStore: AnnouncementStore.shared,
                    publicCommentStore: PublicCommentStore.shared,
                    privateMessageStore: PrivateMessageStore.shared
                )
                .modelContainer(container)
                .onAppear { showLoading = false }
            } else {
                // Fallback while container loads
                ViewConfig.bgColor
                    .ignoresSafeArea()
                    .onAppear { showLoading = true }
            }

            // Launch layer Overlay on top
            ViewConfig.bgColor
                .ignoresSafeArea()
                .opacity(showMain ? 0 : 1)
                .animation(.easeInOut(duration: 1.0), value: showMain)

            // Text overlay (lingers a bit longer)
            VStack(spacing: 40) {
                Text("Template App")
                    .font(.title)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundColor(ViewConfig.fgColor)
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)
                    .opacity(showOverlay ? 1 : 0)
                    .animation(.easeInOut(duration: 1.0), value: showOverlay)
                Text("")
            }

            // Insert the Loading Indicator on top, over-the-top if needed,
            // but only when doing showing the Overlay and showing the Main app
            if showLoading, showMain {
                VStack(spacing: 40) {
                    Text("")
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ViewConfig.fgColor))
                        Text("Loading local data…")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(ViewConfig.fgColor)
                    }
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.horizontal)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: showLoading)
            }
        }
        .onAppear {
            showOverlay = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showMain = true
                }
                withAnimation(.easeOut(duration: 1.0)) {
                    showOverlay = false
                }
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
    
    let schema = Schema([
        Contact.self,
        ActivityLogEntry.self
    ])
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
