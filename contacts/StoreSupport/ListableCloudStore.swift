//
//  ListableCloudStore.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.2 (renamed) Fast Five Products LLC's public AGPL template.
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
class ListableCloudStore<T: Listable>: SignInOutObserver, ListableStore {
        
    // primary data available from the store
    @Published var list: Loadable<[T]> = .none
        
    // enable generic access to the type
    let storeType: T.Type

    init(type: T.Type = T.self) {
        self.storeType = type
    }
    
    // enable generic access to typeDescription
    var storeTypeDescription: String { T.typeDescription }
    
    // set how to fetch data into the store
    var fetchFromService: (() async throws -> [T]) {
        debugprint("fetchFromService() called but no override present in \(storeTypeDescription) store subclass.")
        fatalError("Subclasses must override fetchFromService")
    }
    
    // fire-and-forget fetch
    func fetch() {
        Task {
            list = .loading
            do {
                let result = try await fetchFromService()
                debugprint("Fetched \(result.count) \(storeTypeDescription)s")
                list = .loaded(result)
                if result.isEmpty && storeType.usePlaceholder {
                    list = .loaded([storeType.placeholder])
                    debugprint("\(storeTypeDescription) placeholder used; now we have \(list.count) \(storeTypeDescription)s")
                }
            } catch {
                list = .error(error)
                debugprint("Error fetching \(storeTypeDescription)s: \(error)")
            }
        }
    }
    
    // async/await fetch with a callback return
    func fetchAndReturn() async -> Loadable<[T]> {
        list = .loading
        do {
            let result = try await fetchFromService()
            debugprint("Fetched \(result.count) \(storeTypeDescription)s")
            list = .loaded(result)
            if result.isEmpty && storeType.usePlaceholder {
                list = .loaded([storeType.placeholder])
                debugprint("\(storeTypeDescription) placeholder used; now we have \(list.count) \(storeTypeDescription)s")
            }
            return list
        } catch {
            debugprint("Error fetching \(storeTypeDescription)s: \(error)")
            list = .error(error)
            return list
        }
    }
    
    // add new data to local store
    func add(_ item: T) {
        switch list {
        case .loaded(let currentItems):
            list = .loaded([item] + currentItems)
        case .none, .loading:
            list = .loaded([item])
        case .error:
            list = .loaded([item])
        }
    }
    
}

#if DEBUG
extension ListableCloudStore {
    static func testLoaded(with objects: [T]) -> ListableCloudStore<T> {
        let store = ListableCloudStore<T>()
        store.list = .loaded(objects)
        return store
    }

    static func testEmpty() -> ListableCloudStore<T> {
        let store = ListableCloudStore<T>()
        store.list = .loaded([])
        return store
    }

    static func testLoading() -> ListableCloudStore<T> {
        let store = ListableCloudStore<T>()
        store.list = .loading
        return store
    }

    static func testError(_ error: Error = NSError(domain: "Preview", code: 1, userInfo: nil)) -> ListableCloudStore<T> {
        let store = ListableCloudStore<T>()
        store.list = .error(error)
        return store
    }
}
#endif
