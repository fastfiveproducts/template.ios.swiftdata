//
//  StoreListView.swift
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

struct StoreListView<T: Listable, Content: View>: View {
    @ObservedObject var store: ListableStore<T>
    var filter: ((T) -> Bool)? = nil
    var showBullets: Bool = false
    var showDividers: Bool = true
    let rowContent: ((T) -> Content)?

    // MARK: - Default initializer (no custom layout)
    init(
        store: ListableStore<T>,
        filter: ((T) -> Bool)? = nil,
        showBullets: Bool = false,
        showDividers: Bool = true
    ) where Content == EmptyView {
        self.store = store
        self.filter = filter
        self.showBullets = showBullets
        self.showDividers = showDividers
        self.rowContent = nil
    }

    // MARK: - Custom layout initializer
    init(
        store: ListableStore<T>,
        filter: ((T) -> Bool)? = nil,
        showBullets: Bool = false,
        showDividers: Bool = true,
        @ViewBuilder rowContent: @escaping (T) -> Content
    ) {
        self.store = store
        self.filter = filter
        self.showBullets = showBullets
        self.showDividers = showDividers
        self.rowContent = rowContent
    }

    // MARK: - Body
    var body: some View {
        switch store.list {
        case .loading:
            HStack {
                Text("\(T.typeDescription)s: ")
                ProgressView()
            }

        case let .loaded(objects):
            if objects.isEmpty {
                Text("\(T.typeDescription)s: not found, try relaunching the app")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                
                // Apply filter if provided
                let filteredObjects = filter.map { objects.filter($0) } ?? objects
                
                if filteredObjects.isEmpty {
                    Text("No \(T.typeDescription)s match the filter.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredObjects.indices, id: \.self) { index in
                        let object = filteredObjects[index]
                        
                        HStack(alignment: .top, spacing: 8) {
                            if showBullets {
                                Text("•")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Group {
                                if let rowContent = rowContent {
                                    rowContent(object)
                                } else {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(object.content)
                                            .foregroundStyle(.primary)
                                        if showDividers && index < filteredObjects.count - 1 {
                                            Divider().padding(.top, 6)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        case .error(let error):
            Text("Cloud Error loading \(T.typeDescription)s: \(error.localizedDescription)")

        case .none:
            Text("\(T.typeDescription)s: nothing here")
                .foregroundStyle(.secondary)
        }
    }
}


#if DEBUG
#Preview ("Form: Loading, Error, Loaded") {
    Form {
        Section(header: Text("Announcements (Loading)")) {
            StoreListView(store: ListableStore<Announcement>.testLoading(), showDividers: false)
        }
        Section(header: Text("Announcements (Error)")) {
            StoreListView(store: ListableStore<Announcement>.testError(), showDividers: false)
        }
        Section(header: Text("Announcements")) {
            StoreListView(store: ListableStore<Announcement>.testLoaded(with: Announcement.testObjects), showDividers: false)
        }

    }
}
#Preview ("Form: Empty") {
    Form {
        Section {
            StoreListView(store: ListableStore<Announcement>.testEmpty(), showDividers: false)
        }
    }
}
#Preview ("Bullets") {
    StoreListView(store: ListableStore<Announcement>.testLoaded(with: Announcement.testObjects),
                  showBullets: true,
                  showDividers: false
    )
}
#Preview ("Custom Content: simple") {
    StoreListView(store: ListableStore<Announcement>.testLoaded(with: Announcement.testObjects)) { object in
        VStackBox(title: object.title) {
            Text(object.content)
        }
    }
}
#Preview ("Custom Content: complex") {
    StoreListView(store: ListableStore<Announcement>.testLoaded(with: Announcement.testObjects)) {announcement in
        VStackBox(titleView: {
            VStack {
                HStack {
                    Text(announcement.title)
                        .font(.title3).fontWeight(.semibold)
                    Spacer()
                }
                HStack {
                    Text("display unti: \(announcement.displayEndDate)")
                        .font(.caption)
                    Spacer()
                }
            }
        }) {
            Text(announcement.content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
#endif
