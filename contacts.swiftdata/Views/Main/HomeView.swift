//
//  HomeView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Split from MenuView ~restored by Pete Maiser, Fast Five Products LLC, on 10/23/25.
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

struct HomeView: View {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var announcementStore: AnnouncementStore
      
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: Background
            ConditionalVideoBackgroundView()
            
            // MARK: Announcements
            GeometryReader { geo in
                VStack {
                    Spacer()
                        .frame(height: geo.size.height * ViewConfig.topHalfSpaceRatio + 20)
                    
                    VStackBox(
                        fitIn: .vertical,
//                        maxHeight: geo.size.height * (1 - ViewConfig.topHalfSpaceRatio) - ViewConfig.bottomTabBarSpace
                    ) {
                        announcementStore.list.count > 0 ? StoreListView(store: announcementStore) : nil
                        SupportLinkView(currentUserService: currentUserService,
                                        showDivider: announcementStore.list.count > 0 ? true : false,
                                        onNavigate: { OverlayManager.shared.hide(.splash) }
                        )
                        SignUpInLinkView(currentUserService: currentUserService,
                                         onNavigate: { OverlayManager.shared.hide(.splash) }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geo.safeAreaInsets.bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical)
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
    
}


#if DEBUG
#Preview ("View Only") {
    let cuts = CurrentUserTestService.sharedSignedIn
    ZStack {
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore.testLoaded()
        )
        .onAppear{ OverlayManager.shared.show(.splash) }
        OverlayView()
    }
}
#Preview ("test-data signed-in") {
    let cuts = CurrentUserTestService.sharedSignedIn
    ZStack {
        MainViewPreviewWrapper(currentUserService: cuts) {
            HomeView(
                currentUserService: cuts,
                announcementStore: AnnouncementStore.testLoaded()
            )
            .onAppear{ OverlayManager.shared.show(.splash) }
        }
        OverlayView()
    }
}
#Preview ("tiny announcement signed-out") {
    let cuts = CurrentUserTestService.sharedSignedOut
    ZStack {
        MainViewPreviewWrapper(currentUserService: cuts) {
            HomeView(
                currentUserService: cuts,
                announcementStore: AnnouncementStore.testTiny()
            )
            .onAppear{ OverlayManager.shared.show(.splash) }
        }
        OverlayView()
    }
}
#Preview ("no announcements") {
    let cuts = CurrentUserTestService.sharedSignedIn
    ZStack {
        MainViewPreviewWrapper(currentUserService: cuts) {
            HomeView(
                currentUserService: cuts,
                announcementStore: AnnouncementStore()
            )
            .onAppear{ OverlayManager.shared.show(.splash) }
        }
        OverlayView()
    }
}
#endif
