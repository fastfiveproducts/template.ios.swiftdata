//
//  ListableStoreView.swift (renamed from StoreListView)
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

struct ListableStoreView<Store: ListableStore>: View {
    @ObservedObject var store: Store

    var showSectionHeader: Bool = false
    var showDividers: Bool = true
    var hideWhenEmpty: Bool = false

    var body: some View {
        switch store.list {
        case .loading:
            HStack {
                Text("\(Store.T.typeDescription)s: ")
                ProgressView()
            }
        case let .loaded(objects):
            if hideWhenEmpty && objects.isEmpty {
                EmptyView()
            } else {
                content(for: objects)
            }
        case .error(let error):
            Text("Error loading \(Store.T.typeDescription)s: \(error.localizedDescription)")
            
        case .none:
            Text("\(Store.T.typeDescription)s: nothing here")
        }
    }
    
    @ViewBuilder
    private func content(for objects: [Store.T]) -> some View {
        let sectionHeader = Text("\(Store.T.typeDescription)s")
        if showSectionHeader && !objects.isEmpty {
            Section(header: sectionHeader) {
                contentList(objects)
            }
        } else if !objects.isEmpty{
            Section {
                contentList(objects)
            }
        } else {
            contentList(objects)
        }
    }

    private func contentList(_ objects: [Store.T]) -> some View {
        ForEach(objects.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 4) {
                let object = objects[index]
                Text(object.objectDescription)
                if showDividers && index < objects.count - 1 {
                    Divider()
                        .padding(.top, 6)
                }
            }
        }
    }
}


#if DEBUG
#Preview ("Form: Loaded") {
    Form {
        Section(header: Text("Announcements")) {
            ListableStoreView(store: ListableCloudStore<Announcement>.testLoaded(with: Announcement.testObjects), showDividers: false)
        }
        
        // this will show the same way:
        ListableStoreView(store: ListableCloudStore<Announcement>.testLoaded(with: Announcement.testObjects), showSectionHeader: true, showDividers: false)
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("VStackBox: Loaded") {
    VStackBox(title: "Announcements") {
        ListableStoreView(store: ListableCloudStore<Announcement>.testLoaded(with: Announcement.testObjects))
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("Form: Loading, Error") {
    Form {
        Section {
            ListableStoreView(store: ListableCloudStore<Announcement>.testLoading(), showDividers: false)
            ListableStoreView(store: ListableCloudStore<Announcement>.testError(), showDividers: false)
        }
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#Preview ("Empty") {
    Form {
        Section {
            ListableStoreView(store: ListableCloudStore<Announcement>.testEmpty(), showDividers: false)
        }
        
        // this will show the same way, including hiding the header it would show if there was content
        ListableStoreView(store: ListableCloudStore<Announcement>.testEmpty(), showSectionHeader: true, showDividers: false)
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
    .environment(\.font, Font.body)
}
#endif
