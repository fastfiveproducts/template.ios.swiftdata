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
    
    let topRatio: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                if announcementStore.list.count > 0 {
                    VStack {
                        Spacer()
                            .frame(height: geo.size.height * topRatio + 24)
                        
                        VStackBox {
                            ViewThatFits(in: .vertical) {
                                VStack(alignment: .leading, spacing: 8) {
                                    StoreListView(store: announcementStore)
                                    SupportLinkView(currentUserService: currentUserService,
                                                    onNavigate: { OverlayManager.shared.hide(.splash) }
                                   )
                                    SignUpInLinkView(currentUserService: currentUserService,
                                                     onNavigate: { OverlayManager.shared.hide(.splash) }
                                    )
                                }
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 8) {
                                        StoreListView(store: announcementStore)
                                        SupportLinkView(currentUserService: currentUserService,
                                                        onNavigate: { OverlayManager.shared.hide(.splash) }
                                       )
                                        SignUpInLinkView(currentUserService: currentUserService,
                                                         onNavigate: { OverlayManager.shared.hide(.splash) }
                                        )
                                    }
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                        .frame(maxHeight: geo.size.height * (1 - topRatio))
                        .padding(.horizontal)
                        .padding(.bottom, geo.safeAreaInsets.bottom)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .padding(.vertical)
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
    .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
    .environment(\.font, Font.body)
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
