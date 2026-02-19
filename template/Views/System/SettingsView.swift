//
//  SettingsView.swift
//
//  Template file created by Elizabeth Maiser, Fast Five Products LLC, on 7/4/25.
//  Modified by Claude, Fast Five Products LLC, on 2/19/26.
//      Template v0.3.0 (updated) — Fast Five Products LLC's public AGPL template.
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


import SwiftUI

struct SettingsView: View {
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("defaultToDog") private var defaultToDog = false

    var showTitle: Bool = false

    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom)
            }

            List {
                Toggle("Dark Mode", isOn: $darkMode)
                Toggle("Default to Dog", isOn: $defaultToDog)
            }
            .listStyle(.plain)

            Spacer()
            Button("Reset All Settings") {
                withAnimation {
                    darkMode = false
                    defaultToDog = false
                }
            }
        }
        .padding()
    }
}


#if DEBUG
#Preview {
    SettingsView(showTitle: true)
}
#endif
