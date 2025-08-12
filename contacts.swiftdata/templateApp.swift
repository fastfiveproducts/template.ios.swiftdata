//
//  templateApp.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.4 (updated) Fast Five Products LLC's public AGPL template.
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
import Firebase
import FirebaseAppCheck

@main
struct templateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Create a shared Model Container for SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            ActivityLogEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
        
    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeViewModel(),
                currentUserService: CurrentUserService.shared,      // will setup its own listener upon initialziation
                announcementStore: AnnouncementStore.shared,        // call fetch immediately below as fire-and-forget
                publicCommentStore: PublicCommentStore.shared,      // will observe user sign-in and fetch at that point
                privateMessageStore: PrivateMessageStore.shared     // will observe user sign-in and fetch at that point
            )
                .task {AnnouncementStore.shared.fetch()}
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        FirebaseConfiguration.shared.setLoggerLevel(.error)         // Trying:  to reduce log 'spam'
        FirebaseApp.configure()                                     // Needed:  configure Firebase
        FirebaseConfiguration.shared.setLoggerLevel(.error)         // Trying:  to reduce log 'spam'
        
        return true
    }
}
