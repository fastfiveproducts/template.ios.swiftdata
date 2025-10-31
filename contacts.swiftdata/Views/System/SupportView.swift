//
//  SupportView.swift
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

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Getting Started with \(ViewConfig.brandName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ViewConfig.fgColor)

                    Text("A quick guide to help you explore and get comfortable with the app.")
                        .font(.subheadline)
                        .foregroundColor(ViewConfig.fgColor)
                }
                .padding(.horizontal)
                .padding(.top)

                Divider().opacity(0.3)

                // MARK: - Overview
                VStackBox(titleView: {
                    Label("What This App Does", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(ViewConfig.brandColor)
                }) {
                    Text("""
                    The Template App provides a clean starting point for building SwiftUI apps with shared services, data stores, and visual components.
                    """)
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Layout
                VStackBox(titleView: {
                    Label("Layout Overview", systemImage: "square.grid.2x2")
                        .font(.headline)
                        .foregroundColor(ViewConfig.brandColor)
                }) {
                    Text("""
                    Most screens use a VStack-based layout for clarity and flexibility. You’ll see consistent section headers and spacing throughout.
                    """)
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Configuration
                VStackBox(titleView: {
                    Label("Configuration", systemImage: "gearshape.fill")
                        .font(.headline)
                        .foregroundColor(ViewConfig.brandColor)
                }) {
                    Text("""
                    App-wide appearance and constants live in `ViewConfig`. You can easily customize brand colors, fonts, and layout sizes there. You can also define dynamic colors, links, and branding for your app’s environment.
                    """)
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - FAQ
                VStackBox(titleView: {
                    Label("Frequently Asked Questions", systemImage: "questionmark.circle.fill")
                        .font(.headline)
                        .foregroundColor(ViewConfig.brandColor)
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Group {
                            Text("**Q:** Where do I start customizing?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("""
                            **A:** Begin with `ViewConfig`. It defines your app’s name, theme color, background, and link information. From there, you can explore other example views to understand the structure.
                            """)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }

                        Group {
                            Text("**Q:** Is there example code I can safely modify?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("""
                            **A:** Yes. Every view in this template is written to be self-contained and easy to modify. You can duplicate any view or component (like `VStackBox`) and rename it for your own use.
                            """)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }

                        Group {
                            Text("**Q:** Sample - what is your privacy policy?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("**A:** Visit our:")
                                    .font(.body)
                                    .foregroundStyle(.secondary)

                                Link(ViewConfig.privacyText, destination: ViewConfig.privacyURL)
                                    .font(.body)
                                    .underline()
                                    .padding(.bottom, 6)
                            }
                        }
                    }
                }

                Spacer(minLength: 40)

                // MARK: - Footer
                VStack(alignment: .center, spacing: 8) {
                    Text("Need more help?")
                        .font(.headline)
                        .foregroundColor(ViewConfig.fgColor)

                    HStack(spacing: 4) {
                        Text("Visit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Link(destination: ViewConfig.supportURL) {
                            Text(ViewConfig.supportText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemBackground).opacity(0.9))
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            }
            .padding(.vertical)
        }
        .background(ViewConfig.bgColor)
        .navigationTitle(NavigationItem.support.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
#Preview {
    SupportView()
        .dynamicTypeSize(...ViewConfig.dynamicSizeMax)
        .environment(\.font, Font.body)
}
#endif
