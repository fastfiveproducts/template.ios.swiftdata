//
//  HomeView.swift
//
//  Template by Pete Maiser, July 2024 through May 2025
//      made availble here:
//      https://github.com/fastfiveproducts/template.ios
//      provided via, and used per, terms of the MIT License
//
//  This particular implementation is for:
//      APP_NAME
//      DATE
//      YOUR_NAME
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
    @ObservedObject var templateStructStore = ListableFileStore<TemplateStruct>()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                self.destinationView
            }
            .navigationTitle(selectedMenuItem?.label ?? "Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        self.menuView
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
                
                if !currentUserService.isSignedIn && self.selectedMenuItem != .profile {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            UserAccountView(
                                viewModel: UserAccountViewModel(),
                                currentUserService: currentUserService)
                        } label: {
                            HStack {
                                Text("Sign In →")
                                Label(MenuItem.profile.label, systemImage: currentUserService.isSignedIn ? "\(MenuItem.profile.systemImage).fill" : MenuItem.profile.systemImage)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .padding(.vertical)
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
    }

    @ViewBuilder
    var menuView: some View {
        ForEach(MenuItem.allCases
            .filter { $0.sortOrder.0 == 0 }
            .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                Button {
                    selectedMenuItem = item
                } label: {
                    if item == .profile {
                        Label(item.label, systemImage: currentUserService.isSignedIn ? "\(item.systemImage).fill" : item.systemImage)
                    } else {
                        Label(item.label, systemImage: item.systemImage)
                    }
                }
        }

        Divider()

        ForEach(MenuItem.allCases
            .filter { $0.sortOrder.0 == 1 }
            .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                Button {
                    selectedMenuItem = item
                } label: {
                    if item == .profile {
                        Label(item.label, systemImage: currentUserService.isSignedIn ? "\(item.systemImage).fill" : item.systemImage)
                    } else {
                        Label(item.label, systemImage: item.systemImage)
                    }
                }
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self.selectedMenuItem {
        case .announcements:
            VStackBox {
                ListableStoreView(store: announcementStore, showSectionHeader: false, showDividers: true)
                
                if !currentUserService.isSignedIn {
                    Divider()
                    NavigationLink {
                        UserAccountView(
                            viewModel: UserAccountViewModel(),
                            currentUserService: currentUserService)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Tap Here or ") + Text(Image(systemName: "\(MenuItem.profile.systemImage)")) + Text(" to Sign In!")
                            Spacer()
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
            Spacer()
            
        case .contacts:
            ContactListView()
            
        case .locations:
            VStackBox {
                ListableStoreView(store: templateStructStore, showSectionHeader: false, showDividers: true)
            }
            VStackBox(title: "Add New Spot") {
                CaptureFormView(
                    viewModel: TemplateStruct.makeCaptureFormViewModel(store: templateStructStore),
                    showHeader: false)
            }
            Spacer()
            
        case .profile:
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService)
            
        case .messages:
            UserMessagePostsStackView(
                currentUserService: currentUserService,
                viewModel: UserPostViewModel<PrivateMessage>(),
                store: privateMessageStore)
            
        case .comments:
            CommentPostsStackView(
                currentUserService: currentUserService,
                store: publicCommentStore)
            
        case .activity:
            ActivityLogView()
            
        case .settings:
            SettingsView()
            
        case .none:
            EmptyView()
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

    for task in Contact.testObjects {
        container.mainContext.insert(task)
    }
    
    for task in ActivityLogEntry.testObjects {
        container.mainContext.insert(task)
    }
    
    let currentUserService = CurrentUserTestService.sharedSignedIn
    return HomeView(
        viewModel: HomeViewModel(),
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore(),             // loading empty because private messages not used yet
        templateStructStore: ListableFileStore<TemplateStruct>()
    )
    .modelContainer(container)
}

#Preview ("test-data signed-out") {
    let container = try! ModelContainer()
    let currentUserService = CurrentUserTestService.sharedSignedOut
    return HomeView(
        viewModel: HomeViewModel(),
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore.testLoaded(),
        templateStructStore: ListableFileStore<TemplateStruct>()
    )
    .modelContainer(container)
}
#endif
