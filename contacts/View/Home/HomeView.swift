//
//  HomeView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1 Fast Five Products LLC's public AGPL template.
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

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var showMenu = false
    @State private var selectedMenuItem: MenuItem? = .contacts
    
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var announcementStore: AnnouncementStore
    @ObservedObject var publicCommentStore: PublicCommentStore
    @ObservedObject var privateMessageStore: PrivateMessageStore

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                self.destinationView
            }
            .navigationTitle(selectedMenuItem?.label ?? "Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    self.menuView
                }
                
                if !currentUserService.isSignedIn && self.selectedMenuItem != .profile {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SignUpInLinkView(currentUserService: currentUserService, inToolbar: true)
                    }
                }
            }
            .padding(.vertical)
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self.selectedMenuItem {
        case .announcements:
            VStackBox {
                ListableStoreView(
                    store: announcementStore,
                    showSectionHeader: false,
                    showDividers: true)
                
                if !currentUserService.isSignedIn {
                    SignUpInLinkView(currentUserService: currentUserService)
                }
            }
            Spacer()
            
        case .contacts:
            ContactListView(currentUserService: currentUserService)
                        
        case .profile:
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService)
            
        case .messages:
            if currentUserService.isSignedIn {
                UserMessagePostsStackView(
                    viewModel: UserPostViewModel<PrivateMessage>(),
                    currentUserService: currentUserService,
                    store: privateMessageStore)
            } else {
                VStackBox {
                    Text("Not Signed In!")
                    SignUpInLinkView(currentUserService: currentUserService)
                }
                Spacer()
            }
            
        case .comments:
            if currentUserService.isSignedIn {
                CommentPostsStackView(
                    currentUserService: currentUserService,
                    store: publicCommentStore)
            } else {
                VStackBox {
                    Text("Not Signed In!")
                    SignUpInLinkView(currentUserService: currentUserService)
                }
                Spacer()
            }
            
        case .activity:
            ActivityLogView()
            
        case .settings:
            SettingsView()
            
        case .none:
            EmptyView()
        }
        
    }

    @ViewBuilder
    var menuView: some View {
        Menu {
            ForEach(MenuItem.allCases
                .filter { $0.sortOrder.0 == 0 }
                .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                    Button {
                        selectedMenuItem = item
                    } label: {
                        menuLabel(item)
                    }
            }
            Divider()
            ForEach(MenuItem.allCases
                .filter { $0.sortOrder.0 == 1 }
                .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                    Button {
                        selectedMenuItem = item
                    } label: {
                        menuLabel(item)
                    }
            }
        } label: {
            Label("Menu", systemImage: "line.3.horizontal")
        }
    }
    
    @ViewBuilder
    func menuLabel(_ item: MenuItem) -> some View {
        if item == .profile {
            Label(item.label, systemImage: currentUserService.isSignedIn ? "\(item.systemImage).fill" : item.systemImage)
        } else {
            Label(item.label, systemImage: item.systemImage)
        }
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let schema = Schema([
        Contact.self,
        ActivityLogEntry.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])

    for object in ActivityLogEntry.testObjects {
        container.mainContext.insert(object)
    }
    
    for object in Contact.testObjects {
        container.mainContext.insert(object)
    }

    let currentUserService = CurrentUserTestService.sharedSignedIn
    return HomeView(
        viewModel: HomeViewModel(),
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore()              // loading empty because private messages not used yet
    )
    .modelContainer(container)
}
#Preview ("no-data and signed-out") {
    let container = try! ModelContainer()
    let currentUserService = CurrentUserTestService.sharedSignedOut
    return HomeView(
        viewModel: HomeViewModel(),
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore.testLoaded()
    )
    .modelContainer(container)
}
#endif
