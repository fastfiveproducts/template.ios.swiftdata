//
//  templateApp.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 10/23/25.
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
import SwiftData
import Firebase
import FirebaseAppCheck

@main
struct templateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Shared Services
    @StateObject private var currentUserService = CurrentUserService.shared
    @StateObject private var modelContainerManager: ModelContainerManager

    init() {
        // Firebase Configuration
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FirebaseApp.configure()

        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        // Startup remaining App Services and Managers
        _modelContainerManager = StateObject(
            wrappedValue: ModelContainerManager(currentUserService: CurrentUserService.shared)
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(
                currentUserService: currentUserService,
                modelContainerManager: modelContainerManager,
                announcementStore: AnnouncementStore.shared,
                publicCommentStore: PublicCommentStore.shared,
                privateMessageStore: PrivateMessageStore.shared
            )
            .task {
                AnnouncementStore.shared.fetch()
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
