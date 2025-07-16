//
//  FirestoreConnector.swift
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
import FirebaseFirestore

struct FirestoreConnector: DebugPrintable {

    func fetchAnnouncements() async throws -> [Announcement] {
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding:.day, value: 1, to: startOfDay)!

        let query = Firestore.firestore().collection("announcements_v01")
          .whereField("displayStartDate", isLessThanOrEqualTo: Timestamp(date: endOfDay))
          .whereField("displayEndDate", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))

        let snapshot = try await query.getDocuments()
        debugprint("Fetched \(snapshot.documents.count) raw docs from the announcements_v01 collection")

        let data = snapshot.documents.compactMap { document -> Announcement? in
            do {
                let decoded = try document.data(as: Announcement.self)
                return decoded
            } catch {
                debugprint("WARNING Failed to decode a raw doc from the announcements_v01 collection. Exceution will continue with reduced functionality.")
                return nil
            }
        }
        return data
    }

}

// Extend Firebase Firestore DocumentReference to wrap it with async/await functionality
private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Throws an encoding error if there's a problem with our model
            // All other errors are passed to the completion handle
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}
