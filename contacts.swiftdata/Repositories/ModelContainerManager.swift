//
//  ModelContainerManager.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, in October 2025.
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
//  Purpose:
//  Make the SwiftData ModelContainer user-specific and attached to authentication
//  by observing CurrentUserService sign-in/out events and dynamically swapping
//  the active SwiftData ModelContainer so each user has their
//  own local store.
//


import Foundation
import SwiftData
import Combine

@MainActor
final class ModelContainerManager: ObservableObject, DebugPrintable {

    // The currently active container (per user or guest)
    @Published private(set) var container: ModelContainer?

    private var cancellables = Set<AnyCancellable>()

    init(currentUserService: CurrentUserService) {
        // Observe sign-in notification from CurrentUserService
        currentUserService.signInPublisher
            .sink { [weak self, weak currentUserService] in
                guard let self,
                      let uid = currentUserService?.user.auth.uid,
                      !uid.isEmpty else { return }
                self.loadContainer(for: uid)
            }
            .store(in: &cancellables)

        // Observe sign-out notification from CurrentUserService
        currentUserService.signOutPublisher
            .sink { [weak self] in
                self?.loadContainer(for: nil) // switch to guest mode
            }
            .store(in: &cancellables)
    }
    

    // Open (or rebuild) the container for the given user ID
    func loadContainer(for userId: String?) {
        do {
            // Define schema for the container from the static value set in configuration
            let schema = RepositoryConfig.modelContainerSchema
            let config = ModelConfiguration(
                "LocalModelContainer",
                schema: schema,
                url: makeURL(for: userId),
                allowsSave: true
            )
            container = try ModelContainer(for: schema, configurations: [config])
            debugprint("loaded container for \(userId ?? "guest") ✅.")
        } catch {
            fatalError("Error:  🛑 Could not create ModelContainer: \(error)")
        }
    }
       
    // Erase the on-device SQLite file for the given user, deleting all container data
    // - Parameter userId: Firebase UID or `nil` for guest mode.
    func eraseContainer(for userId: String?) {
        try? FileManager.default.removeItem(at: makeURL(for: userId))
    }
        
    // MARK: - Helpers
    private var baseDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    private func makeURL(for userId: String?) -> URL {
        let owner = userId.map { "user_\($0)" } ?? "guest"
        return baseDirectory.appending(path: "\(owner)_streems.sqlite")
    }
    static var emptyContainer: ModelContainer {
        let schema = Schema([])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}

// MARK: - Cloud Sync
// ***** WARNING - placeholder only - not fully implemented - not tested *****
extension ModelContainerManager {

    // Pulls the latest user data from Cloud
    // and writes it into the local SwiftData container.
    //
    // - Parameter userId: The signed-in user’s UID.
    // - Important:  Call this after `loadContainer(for:)` completes.
    @MainActor
    func syncFromCloud(for userId: String) async {
        // TODO:
        // 1. Use the Cloud connectors to fetch
        //    the current user's Streems (and any other synced models).
        // 2. Compare with local SwiftData records (by id or timestamp).
        // 3. Insert or update changed objects in container.mainContext.
        // 4. Save the context.
        //
        // Example (pseudocode):
        //   let cloudStreems = try await StreemConnector.shared.fetch(for: userId)
        //   for cloud in cloudStreems {
        //       if let local = try? context.fetch(byID: cloud.id) {
        //           local.update(from: cloud)
        //       } else {
        //           context.insert(Streem(fromCloud: cloud))
        //       }
        //   }
        //   try? context.save()
        //
        debugprint("⚠️ WARNING:  [TODO] syncFromCloud(for: \(userId)) not yet implemented.")
    }

    // Pushes local changes from SwiftData container up to Cloud.
    //
    // - Parameter userId: The signed-in user’s UID.
    // - Important:  Call this on sign-out or periodically if you
    //               want background syncing.
    @MainActor
    func syncToCloud(for userId: String) async {
        // TODO:
        // 1. Fetch locally changed / new Streem records from container.mainContext.
        // 2. Use the Cloud connectors to update the cloud.
        // 3. Optionally mark records as "synced" via a local flag or timestamp.
        //
        // Example (pseudocode):
        //   let unsynced = try context.fetch(FetchDescriptor<Streem>(
        //       predicate: #Predicate { !$0.isSynced }
        //   ))
        //   for streem in unsynced {
        //       try await DataConnect.defaultConnector.upsertStreemMutation.execute(...)
        //       streem.isSynced = true
        //   }
        //   try? context.save()
        //
        debugprint("🟡 [TODO] syncToCloud(for: \(userId)) not yet implemented.")
    }
}


#if DEBUG
extension ModelContainerManager {
    func makePreviewContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: RepositoryConfig.modelContainerSchema, configurations: config)
        RepositoryConfig.injectPreviewData(into: container)
        return container
    }
    func injectPreviewContainer(_ container: ModelContainer) {
        self.container = container
    }
}
#endif
