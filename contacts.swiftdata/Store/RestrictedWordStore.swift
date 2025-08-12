//
//  RestrictedWordStore.swift
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


import Foundation

@MainActor
final class RestrictedWordStore: ObservableObject, DebugPrintable {
    
    // primary data available from the store
    private var list: Loadable<[String]> = .none
    
    // initiate this store as a Swift Singleton
    // this is also how to 'get' the singleton store
    static let shared = RestrictedWordStore()
    
    // set how to fetch data into the store
    private let fetchFromService = RestrictedWordConnector().fetchRestrictedWords
    
    // function to fetch data, will only fetch one time
    func enableRestrictedWordCheck() {
        if case .loaded(_) = list { return }
        
        Task {
            list = .loading
            do {
                let result = try await fetchFromService()
                if result.isEmpty {
                    debugprint("WARNING Restricted Word functionality enabled but no Restricted Words found!!! Exceution will continue with reduced functionality.")
                    deviceLog("Restricted Word functionality enabled but no Restricted Words found.", category: "RestrictedWords")
                }
                list = .loaded(result)
                debugprint ("fetched \(list.count) Restricted Text Keywords")
            }
            catch {
                list = .error(error)
                debugprint("Error fetching Restricted Word List: \(error)")
                deviceLog("Error fetching Restricted Word List: %@", category: "RestrictedWords", error: error)
            }
        }
    }
    
    // function to check a string for restricted text per the rules below (case doesn't matter)
    func containsRestrictedWords(_ input: String) -> Bool {
        
        // What should happen - return true if:
        // a) there is an exact match of course, e.g. string == badword
        // b) user appears to be getting around badword by imbedding it in other chars,
        //      e.g. string == badword1, string == 1badword, string == 1badword1
        //
        // What should happen - return false if:
        // c) string doesn't match any bad words at all, of course, e.g. string = goodword
        // d) string is a subset of bad word, e.g. string = badw
        // e) there is system error; app-user likely has bigger problems in this case
        
        if case let .loaded(keywords) = list {
            for word in keywords {
                if input.lowercased().contains(word.lowercased()) {
                    debugprint("Restricted Text found.")
                    return true
                }
            }
        } else if case .loading = list {
            debugprint("WARNING Restricted Word functionality requested but Restricted Words are still loading. Exceution will continue with reduced functionality.")
            deviceLog("Restricted Word functionality requested but Restricted Words still loading.", category: "RestrictedWords")
        } else {
            debugprint("*****FIXME***** Restricted Word functionality requested but was never enabled!!! Exceution will continue.")
            deviceLog("System Error:  Restricted Word functionality requsted but was never enabled by the application.", category: "RestrictedWords")
        }
        return false
        
    }
}

#if DEBUG
extension RestrictedWordStore {
    static func testLoaded() -> RestrictedWordStore {
        let store = RestrictedWordStore()
        store.list = .loaded(["badword", "worseword"])
        store.debugprint("loaded \(store.list.count) test Restricted Text Keywords")
        return store
    }
}
#endif
