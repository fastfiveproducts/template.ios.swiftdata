//
//  HomeView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Split from MenuView ~restored by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//      Template v0.2.3 (updated) Fast Five Products LLC's public AGPL template.
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

struct HomeView: View {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var announcementStore: AnnouncementStore
    
    var body: some View {
        ZStack(alignment: .top) {
            if announcementStore.list.count > 0 {
                VStack {
                    Spacer()
                    VStackBox() {
                        ViewThatFits(in: .vertical) {
                            VStack(alignment: .leading, spacing: 8) {
                                StoreListView(store: announcementStore)
                                SignUpInLinkView(currentUserService: currentUserService)
                            }
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    StoreListView(store: announcementStore)
                                    SignUpInLinkView(currentUserService: currentUserService)
                                }
                                .padding(.bottom, 8)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}


#if DEBUG
#Preview ("View Only") {
    let cuts = CurrentUserTestService.sharedSignedIn
    HomeView(
        currentUserService: cuts,
        announcementStore: AnnouncementStore.testLoaded()
    )
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("test-data signed-in") {
    let cuts = CurrentUserTestService.sharedSignedIn
    MainViewPreviewWrapper(currentUserService: cuts) {
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore.testLoaded()
        )
    }
}
#Preview ("tiny announcement signed-out") {
    let cuts = CurrentUserTestService.sharedSignedOut
    MainViewPreviewWrapper(currentUserService: cuts) {
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore.testTiny()
        )
    }
}
#Preview ("no announcements") {
    let cuts = CurrentUserTestService.sharedSignedIn
    MainViewPreviewWrapper(currentUserService: cuts) {
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore()
        )
    }
}
#endif
