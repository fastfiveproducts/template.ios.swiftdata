//
//  RestrictedWordStore.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//  This store contains a list of naughty words
//  and a function that can be used to check if a string contains one of those words
//
//  Keywords: bad words, objectional words, swear words, blocked words, restricted text
//
//      Template v0.1.1
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
