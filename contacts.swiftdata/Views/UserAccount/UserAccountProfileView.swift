//
//  UserAccountProfileView.swift
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


import SwiftUI

struct UserAccountProfileView: View {
    var body: some View {
        Section {
            Text("User Account Profile goes here, when the user is signed-in!  And when it is implemented.")
        }
        .styledView()
    }
}

#if DEBUG
#Preview {
    Form {
        UserAccountProfileView()
    }
}
#endif
