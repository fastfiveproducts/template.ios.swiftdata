//
//  MainMenuView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Renamed from HomeView by Pete Maiser, Fast Five Products LLC, on 10/23/25.
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
import SwiftData

struct MainMenuView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var announcementStore: AnnouncementStore
    @ObservedObject var publicCommentStore: PublicCommentStore
    @ObservedObject var privateMessageStore: PrivateMessageStore
    
    @State private var showMenu = false
    @State private var selectedMenuItem: NavigationItem?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                if selectedMenuItem == nil {
                    HomeView(currentUserService: currentUserService, announcementStore: announcementStore)
                        .onAppear{ OverlayManager.shared.show(.splash, animation: OverlayAnimation.fast) }
                } else {
                    self.destinationView
                }
            }
            .navigationTitle(selectedMenuItem?.label ?? "")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    self.menuView
                }
                if self.selectedMenuItem != .profile {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SignUpInLinkView(
                            currentUserService: currentUserService,
                            inToolbar: true,
                            onNavigate: { OverlayManager.shared.hide(.splash) }
                        )
                    }
                }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                VideoBackgroundPlayer.shared.queuePlayer.play()
            } else {
                VideoBackgroundPlayer.shared.queuePlayer.pause()
            }
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
}

extension MainMenuView {
    @ViewBuilder
    var destinationView: some View {
        switch self.selectedMenuItem {
        case .home:
            HomeView(currentUserService: currentUserService, announcementStore: announcementStore)
                .onAppear{ OverlayManager.shared.show(.splash, animation: OverlayAnimation.fast) }
            
        case .contacts:
            RequiresSignInView(currentUserService: currentUserService) {
                ContactListView(currentUserService: currentUserService)
            }
            .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .announcements:
            VStackBox {
                StoreListView(store: announcementStore)
                if !currentUserService.isSignedIn {
                    SignUpInLinkView(currentUserService: currentUserService)
                }
            }
            Spacer()
                .onAppear { OverlayManager.shared.hide(.splash) }
                        
        case .profile:
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService
            )
            .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .messages:
            RequiresSignInView(currentUserService: currentUserService) {
                UserMessagePostsStackView(
                    viewModel: UserPostViewModel<PrivateMessage>(),
                    currentUserService: currentUserService,
                    store: privateMessageStore)
            }
            .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .comments:
            RequiresSignInView(currentUserService: currentUserService) {
                CommentPostsStackView(
                    currentUserService: currentUserService,
                    store: publicCommentStore)
            }
            .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .activity:
            ActivityLogView()
                .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .support:
            SupportView()
                .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .settings:
            SettingsView()
                .onAppear { OverlayManager.shared.hide(.splash) }
            
        case .none:
            EmptyView()
                .onAppear { OverlayManager.shared.hide(.splash) }
        }
    }

    @ViewBuilder
    var menuView: some View {
        Menu {
            // group NavigationItems by their first sortOrder component, then sort them
            let groupedItems = Dictionary(grouping: NavigationItem.allCases.filter { $0.sortOrder.0 >= 0 }) {
                $0.sortOrder.0
            }
            let sortedGroupKeys = groupedItems.keys.sorted()

            // iterate through each group
            ForEach(Array(sortedGroupKeys.enumerated()), id: \.element) { index, groupKey in
                let items = groupedItems[groupKey]!.sorted { $0.sortOrder.1 < $1.sortOrder.1 }

                // then iterate through item in the group
                ForEach(items) { item in
                    Button {
                        selectedMenuItem = item
                    } label: {
                        menuLabel(item)
                    }
                }

                if index < sortedGroupKeys.count - 1 {
                    Divider()
                }
            }
        } label: {
            Label("Menu", systemImage: "line.3.horizontal")
        }
    }
    
    @ViewBuilder
    func menuLabel(_ item: NavigationItem) -> some View {
        if item == .profile {
            Label(item.label, systemImage: currentUserService.isSignedIn ? "\(item.systemImage).fill" : item.systemImage)
        } else {
            Label(item.label, systemImage: item.systemImage)
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService: CurrentUserService = CurrentUserTestService.sharedSignedIn
    let modelContainerManager = ModelContainerManager(currentUserService: currentUserService)
    let container = modelContainerManager.makePreviewContainer()
    modelContainerManager.injectPreviewContainer(container)

    return MainMenuView(
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
//        announcementStore: AnnouncementStore.testTiny(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore()             // loading empty because private messages not used yet
    )
    .modelContainer(container)
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("no-data and signed-out") {
    return MainMenuView(
        currentUserService: CurrentUserTestService.sharedSignedOut,
        announcementStore: AnnouncementStore(),
        publicCommentStore: PublicCommentStore(),
        privateMessageStore: PrivateMessageStore()
    )
    .modelContainer(ModelContainerManager.emptyContainer)
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}

// this helper is for child view previews
struct MainViewPreviewWrapper<Content: View>: View {
    let currentUserService: CurrentUserService
    let content: Content

    init(currentUserService: CurrentUserService,
         @ViewBuilder content: () -> Content) {
        self.currentUserService = currentUserService
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Other Menu Items") { }
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
            }
            .padding(.vertical)
        }
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
}
#endif
