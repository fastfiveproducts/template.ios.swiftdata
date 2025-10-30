//
//  HelpView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 10/30/25.
//      Template v0.2.4 Fast Five Products LLC's public AGPL template.
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

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Getting Started with \(ViewConfig.brandName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("A quick guide to help you explore and get comfortable with the app.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                
                // MARK: - Sections
                VStack(spacing: 16) {
                    HelpSection(
                        icon: "sparkles",
                        title: "What This App Does",
                        text: """
                        The Template App provides a clean starting point for building SwiftUI apps with shared services, data stores, and visual components.
                        """
                    )
                    
                    HelpSection(
                        icon: "square.grid.2x2",
                        title: "Layout Overview",
                        text: """
                        Most screens use a VStack-based layout for clarity and flexibility. You’ll see consistent section headers and spacing throughout.
                        """
                    )
                    
                    HelpSection(
                        icon: "gearshape",
                        title: "Configuration",
                        text: """
                        App-wide appearance and constants live in `ViewConfig`. You can easily customize brand colors, fonts, and sizes there.
                        """
                    )
                    
                    HelpSection(
                        icon: "questionmark.circle",
                        title: "Next Steps",
                        text: """
                        Try editing text, colors, or structure in one of the example views — changes update live in SwiftUI Previews. This makes it simple to learn and experiment.
                        """
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                // MARK: - Footer
                VStack(alignment: .center, spacing: 8) {
                    Text("Need more help?")
                        .font(.headline)
                    Text("Visit the documentation or reach out to your development team.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .padding(.vertical)
        }
        .background(ViewConfig.bgColor)
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subview
fileprivate struct HelpSection: View {
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.headline)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(ViewConfig.brandColor)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


#if DEBUG
#Preview {
    HelpView()
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
}
#endif
