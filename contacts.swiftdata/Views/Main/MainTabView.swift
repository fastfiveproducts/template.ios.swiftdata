//
//  MainTabView.swift
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

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var announcementStore: AnnouncementStore
    @ObservedObject var publicCommentStore: PublicCommentStore
    @ObservedObject var privateMessageStore: PrivateMessageStore


    @State private var selectedTabItem: NavigationItem = .home

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTabItem) {
                HomeView(
                    currentUserService: currentUserService,
                    announcementStore: announcementStore
                )
                .onAppear{ OverlayManager.shared.show(.brand, animation: .fast) }
                .tabItem { NavigationItem.home.labelView }
                .tag(NavigationItem.home)

                RequiresSignInView(currentUserService: currentUserService, requiresRealUser: true) {
                    ContactListView(currentUserService: currentUserService)
                }
                .tabItem { NavigationItem.contacts.labelView }
                .tag(NavigationItem.contacts)

                ActivityLogView()
                    .tabItem { NavigationItem.activity.labelView }
                    .tag(NavigationItem.activity)

                SettingsView()
                    .tabItem { NavigationItem.settings.labelView }
                    .tag(NavigationItem.settings)
            }
            .onChange(of: selectedTabItem) {
                if selectedTabItem != .home {
                    OverlayManager.shared.hide(.brand)
                }
            }
            .environment(\.tabSafeAreaBackground, true)
            .navigationTitle(ViewConfig.brandName)
            .navigationBarTitleDisplayMode(.inline)
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

extension MainTabView {
    @ToolbarContentBuilder
    var mainToolbar: some ToolbarContent {
        if currentUserService.isSignedIn
//          ,publicCommentStore.list.count > 0    // uncomment this to have comments display only if there already is one
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
//          ,privateMessageStore.list.count > 0   // uncomment this to have messages display only if there already is one
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

        ToolbarItem(placement: .navigationBarTrailing) {
            SignUpInLinkView(
                currentUserService: currentUserService,
                inToolbar: true,
                onNavigate: { OverlayManager.shared.hide(.brand) }
            )
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    return ZStack {
        MainTabView(
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
        MainTabView(
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
        MainTabView(
            currentUserService: CurrentUserTestService.sharedSignedOut,
            announcementStore: AnnouncementStore(),
            publicCommentStore: PublicCommentStore(),
            privateMessageStore: PrivateMessageStore()
        )
        OverlayView()
    }
}
#endif
