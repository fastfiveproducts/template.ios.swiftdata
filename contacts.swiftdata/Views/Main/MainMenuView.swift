//
//  MainMenuView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Renamed from HomeView by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.9 (updated) — Fast Five Products LLC's public AGPL template.
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
                        .onAppear{ OverlayManager.shared.show(.brand, animation: .fast) }
                } else {
                    self.destinationView
                }
            }
            .navigationTitle(selectedMenuItem?.label ?? "")
            .toolbar { mainToolbar }
        }
//        .onChange(of: scenePhase) {
//            if scenePhase == .active {
//                VideoBackgroundPlayer.shared.queuePlayer.play()
//            } else {
//                VideoBackgroundPlayer.shared.queuePlayer.pause()
//            }
//        }
        .styledView()
    }
}

extension MainMenuView {
    @ToolbarContentBuilder
    var mainToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            self.menuView
        }

        if currentUserService.isSignedIn
          ,FeatureFlagStore.shared.isEnabled("publicComments")
//          ,publicCommentStore.list.count > 0    // uncomment this to have comments display only if there already is one
          ,self.selectedMenuItem != .comments
        {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination:
                    CommentsMainView(
                        currentUserService: currentUserService,
                        store: publicCommentStore
                    ).onAppear { OverlayManager.shared.hide(.brand) })
                {
                    Label("Comments", systemImage: "exclamationmark.bubble")
                        .foregroundStyle(.primary)
                }
                .buttonStyle(BorderlessButtonStyle())

            }
        }

        if currentUserService.isRealUser
          ,FeatureFlagStore.shared.isEnabled("privateMessages")
//          ,privateMessageStore.list.count > 0   // uncomment this to have messages display only if there already is one
          ,self.selectedMenuItem != .messages
        {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination:
                    MessagesMainView(
                        currentUserService: currentUserService,
                        store: privateMessageStore
                    ).onAppear { OverlayManager.shared.hide(.brand) })
                {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right")
                        .foregroundStyle(.primary)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }

        if self.selectedMenuItem != .profile {
            ToolbarItem(placement: .navigationBarTrailing) {
                SignUpInLinkView(
                    currentUserService: currentUserService,
                    inToolbar: true,
                    onNavigate: { OverlayManager.shared.hide(.brand) }
                )
            }
        }
    }
}

extension MainMenuView {
    @ViewBuilder
    var menuView: some View {
        Menu {
            // group NavigationItems by their first sortOrder component, then sort them
            let groupedItems = Dictionary(grouping: NavigationItem.allCases.filter { $0.isVisible }) {
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
            Label(item.label, systemImage: currentUserService.isRealUser ? "\(item.systemImage).fill" : item.systemImage)
        } else {
            Label(item.label, systemImage: item.systemImage)
        }
    }

    @ViewBuilder
    var destinationView: some View {
        switch self.selectedMenuItem {
        case .home:
            HomeView(currentUserService: currentUserService, announcementStore: announcementStore)
                .onAppear{ OverlayManager.shared.show(.brand, animation: .fast) }

        case .contacts:
            RequiresSignInView(currentUserService: currentUserService, requiresRealUser: true) {
                ContactListView(currentUserService: currentUserService)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear { OverlayManager.shared.hide(.brand) }

        case .announcements:
            VStackBox {
                StoreListView(store: announcementStore)
                if !currentUserService.isRealUser {
                    SignUpInLinkView(currentUserService: currentUserService)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear { OverlayManager.shared.hide(.brand) }

        case .profile:
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService
            )
            .onAppear { OverlayManager.shared.hide(.brand) }

        case .messages:
            RequiresSignInView(currentUserService: currentUserService, requiresRealUser: true) {
                MessagesMainView(
                    currentUserService: currentUserService,
                    store: privateMessageStore
                )
            }
            .onAppear { OverlayManager.shared.hide(.brand) }

        case .comments:
            CommentsMainView(
                currentUserService: currentUserService,
                store: publicCommentStore
            )
            .onAppear { OverlayManager.shared.hide(.brand) }

        case .activity:
            ActivityLogView()
                .onAppear { OverlayManager.shared.hide(.brand) }

        case .support:
            SupportView()
                .onAppear { OverlayManager.shared.hide(.brand) }

        case .settings:
            SettingsView()
                .onAppear { OverlayManager.shared.hide(.brand) }

        case .none:
            EmptyView()
                .onAppear { OverlayManager.shared.hide(.brand) }
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    return ZStack {
        MainMenuView(
            currentUserService: CurrentUserTestService.sharedSignedIn,
            announcementStore: AnnouncementStore.testLoaded(),
//            announcementStore: AnnouncementStore.testTiny(),
            publicCommentStore: PublicCommentStore.testLoaded(),
            privateMessageStore: PrivateMessageStore.testLoaded()
        )
        OverlayView()
    }
}
#Preview ("no-data and signed-in") {
    return ZStack {
        MainMenuView(
            currentUserService: CurrentUserTestService.sharedSignedIn,
            announcementStore: AnnouncementStore(),
            publicCommentStore: PublicCommentStore(),
            privateMessageStore: PrivateMessageStore()
        )
        OverlayView()
    }
}
#Preview ("no-data and signed-out") {
    return ZStack {
        MainMenuView(
            currentUserService: CurrentUserTestService.sharedSignedOut,
            announcementStore: AnnouncementStore(),
            publicCommentStore: PublicCommentStore(),
            privateMessageStore: PrivateMessageStore()
        )
        OverlayView()
    }
}
#endif
