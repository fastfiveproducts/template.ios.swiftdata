//
//  ListableStore.swift
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


import Foundation

@MainActor
class ListableStore<T: Listable>: SignInOutObserver  {
        
    // primary data available from the store
    @Published var list: Loadable<[T]> = .none {
        didSet {
            switch list {
            case .loaded(let items):
                hasData = !items.isEmpty
            default:
                hasData = false
            }
        }
    }

    // reactive convenience flag (requires a didSet on list above)
    @Published private(set) var hasData: Bool = false

    // enable generic access to the type
    let storeType: T.Type

    init(type: T.Type = T.self) {
        self.storeType = type
    }
    
    // enable generic access to typeDescription
    var storeTypeDescription: String { T.typeDescription }
    
    // required override, to set how to fetch data into the store
    var fetchFromService: (() async throws -> [T]) {
        debugprint("🛑 ERROR:  fetchFromService() called but no override present in \(storeTypeDescription) store subclass.")
        fatalError("Subclasses must override fetchFromService")
    }
    
    // optionally override this with a filename to enable caching
    var cacheFilename: String? { nil }
    
    // Startup
    func initialize() {
        // Skip if already loaded or already loading
        if case .loaded = list { return }
        if case .loading = list { return }

        // 1️⃣ Try cache first
        if let cacheFilename,
           let cached = loadFromCache(named: cacheFilename),
           !cached.isEmpty {
            list = .loaded(cached)
            debugprint("loaded \(cached.count) \(storeTypeDescription)(s) from cache ✅.")
        }

        // 2️⃣ If nothing cached, use placeholder if available
        else if T.usePlaceholder {
            list = .loaded(T.placeholder)
            debugprint("loaded \(T.placeholder.count) \(storeTypeDescription) placeholder(s) 🪣.")
        }

        // 3️⃣ Fallback to .loading
        else {
            list = .loading
            debugprint("no cache or placeholder \(storeTypeDescription)s available ⚠️.")
        }

        // 4️⃣ Always kick off a background fetch to refresh
        Task { fetch() }
    }

    // fetch, check cache and refresh it if appropriate
    func fetch() {
        Task {
            do {
                let result = try await fetchFromService()
                
                // if result is empty but list already loaded (e.g. from cache or placeholders) then continue with only a warning message
                if result.isEmpty {
                    if case .loaded = list {
                        debugprint("⚠️ WARNING: fetched zero \(storeTypeDescription)(s) from service; will use current data.")
                        return
                    }
                }
                    
                // otherwise update list and cache normally
                debugprint("fetched \(result.count) \(storeTypeDescription)(s) from service ☁️.")
                list = .loaded(result)
                if let cacheFilename {
                    saveToCache(result, named: cacheFilename)
                }
                
            } catch {
                // if already loaded (e.g. from cache or placeholders) then continue with only a warning message
                if case .loaded = list {
                    debugprint("⚠️ WARNING: error fetching \(storeTypeDescription) from service; will use current data.  Error: \(error.localizedDescription)")
                } else {
                    list = .error(error)
                    debugprint("🛑 ERROR: fetching \(storeTypeDescription) from service: \(error.localizedDescription)")
                }
            }
        }
    }

    // async/await fetch with a callback return, list cleared and set to "loading" to indicate we are waiting
    func fetchAndReturn() async -> Loadable<[T]> {
        list = .loading
        do {
            let result = try await fetchFromService()
            debugprint("callback-fetched \(result.count) \(storeTypeDescription)(s) from service ☁️.")
            list = .loaded(result)
            if let cacheFilename { saveToCache(result, named: cacheFilename) }
            return list
        } catch {
            debugprint("🛑 ERROR: fetching \(storeTypeDescription) from service: \(error.localizedDescription)")
            list = .error(error)
            return list
        }
    }
        
    
    // insert new data into local store
    func insert(_ item: T) {
        switch list {
        case .loaded(let currentItems):
            let updated = [item] + currentItems
            list = .loaded(updated)
            if let cacheFilename {
                saveToCache(updated, named: cacheFilename)
                debugprint("cached \(T.typeDescription)s after insert; now \(updated.count) items 💾 .")
            }

        case .none, .loading, .error:
            let updated = [item]
            list = .loaded(updated)
            if let cacheFilename {
                saveToCache(updated, named: cacheFilename)
                debugprint("cached \(T.typeDescription) after insert; 1 item in cache 💾.")
            }
        }
    }
    
    // local cache helpers
    fileprivate func cacheURL(named filename: String) -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appending(path: filename)
    }

    fileprivate func saveToCache(_ objects: [T], named filename: String) {
        do {
            let data = try JSONEncoder().encode(objects)
            try data.write(to: cacheURL(named: filename), options: .atomic)
            debugprint("saved \(objects.count) \(storeTypeDescription)s to cache (\(filename)) 💾.")
        } catch {
            debugprint("WARNING ⚠️:  Failed to save \(storeTypeDescription)s to cache: \(error)")
        }
    }

    fileprivate func loadFromCache(named filename: String) -> [T]? {
        do {
            let data = try Data(contentsOf: cacheURL(named: filename))
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            return nil
        }
    }

    func clearCache() {
        if let cacheFilename {
            try? FileManager.default.removeItem(at: cacheURL(named: cacheFilename))
        }
    }
    
}

#if DEBUG
extension ListableStore {
    static func testLoaded(with objects: [T]) -> ListableStore<T> {
        let store = ListableStore<T>()
        store.list = .loaded(objects)
        return store
    }

    static func testEmpty() -> ListableStore<T> {
        let store = ListableStore<T>()
        store.list = .loaded([])
        return store
    }

    static func testLoading() -> ListableStore<T> {
        let store = ListableStore<T>()
        store.list = .loading
        return store
    }

    static func testError(_ error: Error = NSError(domain: "Preview", code: 1, userInfo: nil)) -> ListableStore<T> {
        let store = ListableStore<T>()
        store.list = .error(error)
        return store
    }
}
#endif
