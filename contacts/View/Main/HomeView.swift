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
    let sharedModelContainer: ModelContainer
    
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
                        ForEach(MenuItem.allCases
                            .filter { $0.sortOrder.0 == 0 }
                            .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                                Button {
                                    selectedMenuItem = item
                                } label: {
                                    Label(item.label, systemImage: item.systemImage)
                                }
                        }

                        Divider()

                        ForEach(MenuItem.allCases
                            .filter { $0.sortOrder.0 == 1 }
                            .sorted(by: { $0.sortOrder.1 < $1.sortOrder.1 })) { item in
                                Button {
                                    selectedMenuItem = item
                                } label: {
                                    Label(item.label, systemImage: item.systemImage)
                                }
                        }
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
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
            Form {
                ListableStoreView(store: announcementStore, showSectionHeader: true, showDividers: false)
                
                if !currentUserService.isSignedIn {
                    NavigationLink {
                        UserAccountView(
                            viewModel: UserAccountViewModel(),
                            currentUserService: currentUserService)
                    } label: {
                        HStack {
                            Text("Tap Here or Menu -> ") + Text("User Profile") + Text(" to Sign In!")
                        }
                        .foregroundColor(.accentColor)
                        .padding(.horizontal)
                    }
                }
            }
            
        case .contacts:
            ContactListView()
                .modelContainer(sharedModelContainer)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            
        case .locations:
            VStackBox {
                HStack {
                    Text ("Capture Form Example")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    NavigationLink {
                        Form() {
                            ListableStoreView(store: templateStructStore, showSectionHeader: true, showDividers: false)
                        }
                    } label: {
                        Text("Records")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
            } content: {
                CaptureFormView(
                    viewModel: TemplateStruct.makeCaptureFormViewModel(store: templateStructStore),
                    showHeader: false
                )
                .padding(.horizontal)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(6)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
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
            VStackBox {
                HStack {
                    Text("Testing Talk")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    if currentUserService.isSignedIn {
                        NavigationLink {
                            UserCommentPostsStackView(
                                currentUserService: currentUserService,
                                viewModel: UserPostViewModel<PublicComment>(),
                                store: publicCommentStore
                            )
                        } label: {
                            Text("Write a Comment")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            } content: {
                if currentUserService.isSignedIn {
                    PostsScrollView(
                        store: publicCommentStore,
                        currentUserId: currentUserService.userKey.uid,
                        showFromUser: true,
                        hideWhenEmpty: true
                    )
                } else {
                    HStack {
                        Text("Not Signed In!")
                        Spacer()
                        Text("...tap ") + Text(Image(systemName: "person")) + Text(" above")
                    }
                    .padding(.horizontal)
                }
            }
            
        case .activity:
            ActivityLogView()
                .modelContainer(sharedModelContainer)
            
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
    let container = try! ModelContainer(for: Contact.self, configurations: modelConfiguration)

    for task in Contact.testObjects {
        container.mainContext.insert(task)
    }
    
    let currentUserService = CurrentUserTestService.sharedSignedIn
    return HomeView(
        viewModel: HomeViewModel(),
        sharedModelContainer: container,
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore(),             // loading empty because private messages not used yet
        templateStructStore: ListableFileStore<TemplateStruct>()
    )
}

#Preview ("test-data signed-out") {
    let container = try! ModelContainer()
    let currentUserService = CurrentUserTestService.sharedSignedOut
    return HomeView(
        viewModel: HomeViewModel(),
        sharedModelContainer: container,
        currentUserService: currentUserService,
        announcementStore: AnnouncementStore.testLoaded(),
        publicCommentStore: PublicCommentStore.testLoaded(),
        privateMessageStore: PrivateMessageStore.testLoaded(),
        templateStructStore: ListableFileStore<TemplateStruct>()
    )
}
#endif
