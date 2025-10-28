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
    
    @State private var heroBottomY: CGFloat = 0     // Tracks hero text bottom position
  
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // MARK: Video Background
                VideoBackgroundView()

                // MARK: Hero Message
                VStack {
                    Spacer(minLength: geo.size.height * 0.12)
                    HeroView()
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        let y = proxy.frame(in: .named("content")).maxY
                                        heroBottomY = (y > 0 ? y : geo.size.height * 0.4)
                                    }
                                    .onChange(of: proxy.frame(in: .named("content")).maxY) { _, newValue in
                                        heroBottomY = (newValue > 0 ? newValue : geo.size.height * 0.4)
                                    }
                            }
                        )
                    Spacer()
                }

                // MARK: Announcements
                if announcementStore.list.count > 0 {
                    VStack {
                        Spacer()
                            .frame(height: heroBottomY + 16)

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
                        .frame(maxHeight: geo.size.height - heroBottomY - 48)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .coordinateSpace(name: "content")
        }
        .padding(.vertical)
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let cuts = CurrentUserTestService.sharedSignedIn
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore.testLoaded()
        )
}
#Preview ("tiny announcement signed-out") {
    let cuts = CurrentUserTestService.sharedSignedOut
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore.testTiny()
        )
}
#Preview ("no announcements") {
    let cuts = CurrentUserTestService.sharedSignedIn
        HomeView(
            currentUserService: cuts,
            announcementStore: AnnouncementStore()
        )
}
#endif
