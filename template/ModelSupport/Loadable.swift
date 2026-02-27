//
//  Loadable.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/26/26.
//      Template v0.3.4 (updated) — Fast Five Products LLC's public AGPL template.
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


import Foundation

enum Loadable<Value> {
    case none
    case loading
    case error(Error)
    case loaded(Value)
    
    // this computed property enables access to the Value associated value
    var value: Value? {
        get {
            if case let .loaded(value) = self {
                return value
            }
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            self = .loaded(newValue)
        }
    }
    
    // state helpers
    var isNone: Bool {
        if case .none = self { return true }
        return false
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
    
}

// another helper for counting values
extension Loadable where Value: RangeReplaceableCollection {
    var count: Int {
        if case let .loaded(value) = self {
            return value.count
        }
        else {
            return 0
        }
    }
}

// make Loadable conform to Equatable by adding a compare function
extension Loadable: Equatable where Value: Equatable {
    static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.loading, .loading):
                return true
            case let (.error(error1), .error(error2)):
                // Error doesn't conform to Equatable either; comparing localizedDescription
                // is a pragmatic tradeoff - preventing unnecessary SwiftUI re-renders at the
                // risk of treating different errors with identical localizedDescription as equal.
                return error1.localizedDescription == error2.localizedDescription
            case let (.loaded(value1), .loaded(value2)):
                return value1 == value2
            default:
                return false
        }
    }
}

#if DEBUG
// 'simulate' function will enable state in View Previews
extension Loadable {
    func simulate() async throws -> Value {
        switch self {
            case .loading:
                try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                fatalError("Expected Error: timeout exceeded for “loading” case preview")
            case let .error(error):
                throw error
            case let .loaded(value):
                return value
            case .none:
                fatalError("case not handled: .none")
        }
    }
    
    // override-create a placeholder-error for View Previews
    static var error: Loadable<Value> { .error(PreviewError()) }
    private struct PreviewError: LocalizedError {
        let errorDescription: String? = "This is a preview of the error broadcast system."
    }
}
#endif
