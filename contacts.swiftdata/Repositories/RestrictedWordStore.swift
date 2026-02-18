//
//  RestrictedWordStore.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/5/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
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
//  This store contains a list of naughty words
//  and a function that can be used to check if a string contains one of those words
//
//  Keywords: bad words, objectional words, swear words, blocked words, restricted text
//
//      Template v0.2.1
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
    private let fetchFromService: () async throws -> [String] = {
        try await RestrictedWordConnector().fetch()
    }
    
    // character substitution cipher for obfuscating restricted words
    // words are stored ciphered in the database; user input is ciphered before matching
    // the same map must be used by all clients and by SQL inserts (via PostgreSQL translate())
    private static let cipherFrom: [Character] = Array("abcdefghijklmnopqrstuvwxyz")
    // private static let cipherTo:   [Character] = Array("abcdefghijklmnopqrstuvwxyz")     // No cipher
    private static let cipherTo:   [Character] = Array("qmjztgfkpwlsboxncryevhiadu")        // random-generated FFP.LLC v2026-02-05 cipher
    private static let cipherMap: [Character: Character] = Dictionary(
        uniqueKeysWithValues: zip(cipherFrom, cipherTo)
    )

    // bundled restricted words (already ciphered) for local-only apps without a backend
    // call enableRestrictedWordCheckWithBundledWords() instead of enableRestrictedWordCheck()
    private static let bundledRestrictedWords: [String] = [
        "qoqs stqlqft", "qyy gvjl", "qyygvjl", "qyygvjltr", "qyy-gvjltr", "qyyspjl",
        "qyyopfftr", "mpf msqjl", "msqjl jxjl", "msxi dxvr sxqz", "mrxektrgvjltr",
        "mrxio ykxitry", "mveensvf", "jqrnte bvojktr", "jqrntebvojktr",
        "jkpjl ipek q zpjl", "jkpsz-gvjltr", "jxxooqyy", "j-v-o-e", "jvoe kqpr",
        "jvoekxst", "jvoespjl", "jvoespjltr", "jvoespjlpof", "jvoerqf", "jvoey",
        "jvoeypjst", "zqet rqnt", "zqetrqnt", "zplt", "zpofstmtrrpty", "zpofstmtrrd",
        "zvbmjvoe", "zdlty", "tqe kqpr npt", "tqe bd qyy", "tqenvyyd", "gqfmqf",
        "gqfgvjltr", "gqfftz", "gqffpof", "gqffpee", "gqffxejxjl", "gqffxey", "gqfxey",
        "gqfeqrz", "gtbqst ycvprepof", "gpye gvjl", "gpyetz", "gpyegvjl", "gpyegvjltz",
        "gpyegvjltr", "gpyegvjltry", "gpyegvjlpof", "gpyegvjlpofy", "gpyegvjly",
        "gpyepof", "gvjleqrz", "gvjl-eqrz", "gvjleqrzy", "gvzft nqjltr", "gvzftnqjltr",
        "gvzft-nqjltr", "fqdeqrz", "fxzqbo", "fxzqbope", "fxzzqbbpe", "fxzzqbo",
        "fxzzqbotz", "fxz-zqbotz", "fxzzqbope", "fxzzqbobvekqgvjltr", "fxzyzqbo",
        "fxszto ykxitr", "fxsztoykxitr", "fxxly", "kxenvyyd", "lplty", "lvoe", "ldlt",
        "bqlt bt jxbt", "bqst ycvprepof", "bjgqffte", "bxstye", "opffqk", "opffqy",
        "opffqu", "opfftry", "xsz mqf", "nxsqjl", "nxxoqop", "nxxoqod", "nxxoeqof",
        "nxxn jkvet", "nxxnjkvet", "nxxnvojktr", "nvoqood", "nvoqod", "nvolqyy",
        "nvyypty", "nvyyd gqre", "nvyyd nqsqjt", "nvyydnxvoztr", "nvyydy", "rqnpof",
        "rteqrz", "reqrz", "r-eqrz", "yqoz opfftr", "yqozopfftr", "ykqhtz mtqhtr",
        "ykqhtz nvyyd", "yktbqst", "ykpejvoe", "ykpezpjl", "ykpetqetr", "ykpekxst",
        "ysve mvjlte", "ysvemqf", "ysvey", "ynply", "ynrtqz stfy", "eiqey", "vnylpre",
        "ipfftr", "dtssxi ykxitry"
    ]

    // function to fetch data from the server, will only fetch one time
    func enableRestrictedWordCheck() {
        if case .loaded(_) = list { return }

        Task {
            list = .loading
            do {
                let result = try await fetchFromService()
                if result.isEmpty {
                    debugprint("⚠️ WARNING:  Restricted Word functionality enabled but no Restricted Words found!!! Execution will continue with reduced functionality.")
                    deviceLog("Restricted Word functionality enabled but no Restricted Words found.", category: "RestrictedWords")
                }
                list = .loaded(result)
                debugprint ("fetched \(list.count) Restricted Text Keywords from server")
            }
            catch {
                list = .error(error)
                debugprint("🛑 ERROR:  fetching Restricted Word List: \(error)")
                deviceLog("🛑 ERROR:  fetching Restricted Word List: %@", category: "RestrictedWords", error: error)
            }
        }
    }

    // function to use bundled words for local-only apps (no server fetch)
    func enableRestrictedWordCheckWithBundledWords() {
        if case .loaded(_) = list { return }
        list = .loaded(Self.bundledRestrictedWords)
        debugprint("loaded \(list.count) Restricted Text Keywords from app bundle")
    }
    
    // apply character substitution cipher to a string (only lowercase a-z is substituted)
    private func cipher(_ input: String) -> String {
        String(input.map { Self.cipherMap[$0] ?? $0 })
    }

    // function to check a string for restricted text per the rules below (case doesn't matter)
    // note: stored words are already ciphered; user input is ciphered before matching
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
            let cipheredInput = cipher(input.lowercased())
            for word in keywords {
                if cipheredInput.contains(word) {
                    debugprint("Restricted Text found.")
                    return true
                }
            }
        } else if case .loading = list {
            debugprint("⚠️ WARNING:  Restricted Word functionality requested but Restricted Words are still loading. Execution will continue with reduced functionality.")
            deviceLog("Restricted Word functionality requested but Restricted Words still loading.", category: "RestrictedWords")
        } else {
            debugprint("🛑 ERROR:  *****FIXME*****  Restricted Word functionality requested but was never enabled!!! Execution will continue.")
            deviceLog("System Error:  Restricted Word functionality requsted but was never enabled by the application.", category: "RestrictedWords")
        }
        return false
        
    }
}

#if DEBUG
extension RestrictedWordStore {
    static func testLoaded() -> RestrictedWordStore {
        let store = RestrictedWordStore()      
        store.list = .loaded(["badword", "worseword"].map { store.cipher($0) })
        store.debugprint("loaded \(store.list.count) test Restricted Text Keywords")
        return store
    }
}
#endif
