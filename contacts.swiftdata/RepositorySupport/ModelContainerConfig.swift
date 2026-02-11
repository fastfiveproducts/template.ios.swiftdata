//
//  ModelContainerConfig.swift
//
//  Template file created as RepositoryConfig.swift by Pete Maiser, Fast Five Products LLC, on 11/2/25.
//  Renamed to ModelContainerConfig.swift by Pete Maiser, Fast Five Products LLC, on 2/9/26.
//  Updated by Pete Maiser, Fast Five Products LLC, on 2/9/26.
//      Template v0.2.6 (updated) — Fast Five Products LLC's public AGPL template.
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
import SwiftData

struct ModelContainerConfig {

    // Name used for the per-user SQLite file on disk (e.g. "user_<uid>_contacts.sqlite").
    // Change this when seeding a new project from the template:
    static let modelContainerName = "contacts"

    // Define schema for the container.
    // Other SwiftData-compatible models can be added here:
    static let modelContainerSchema = Schema(
        [Contact.self,      // template sample as template is based on 'contacts'
         ActivityLogEntry.self,
//         otherLocalData.self, draftData.self
        ]
    )
}


#if DEBUG
extension ModelContainerConfig {
    // Enable Test Data
    @MainActor static func injectPreviewData(into container: ModelContainer) {
        let context = container.mainContext

        // template sample as template is based on 'contacts'
        for contact in Contact.testObjects  {
            context.insert(contact)
        }
        
        for object in ActivityLogEntry.testObjects {
            context.insert(object)
        }
        
        try? context.save()
    }
}
#endif
