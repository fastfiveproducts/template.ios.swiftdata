//
//  SupportView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 10/30/25.
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

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Getting Started with \(ViewConfig.brandName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(ViewConfig.fgColor)

                    Text("A quick guide to help you explore and get comfortable with the app.")
                        .font(.subheadline)
                        .foregroundStyle(ViewConfig.fgColor)
                }
                .padding(.horizontal)
                .padding(.top)

                Divider().opacity(0.3)

                // MARK: - Overview
                VStackBox(titleView: {
                    Label("What This App Does", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(ViewConfig.brandColor)
                }) {
                    Text("""
                    This is a template app for building SwiftUI apps backed by Firebase. \
                    It includes user accounts, messaging, announcements, contacts, and more \
                    — all wired up and ready to customize.
                    """)
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Features
                VStackBox(titleView: {
                    Label("Template Features", systemImage: "square.grid.2x2")
                        .font(.headline)
                        .foregroundStyle(ViewConfig.brandColor)
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**User Accounts** — Sign in, sign up, email verification, and profile management.")
                        Text("**Announcements** — View announcements published for all users.")
                        Text("**Contacts** — Browse and manage a list of contacts (included as a SwiftData sample).")
                        Text("**Private Messages** — Send and receive messages between users.")
                        Text("**Public Comments** — Post and read comments visible to all users.")
                        Text("**Activity Log** — Review a log of your recent actions.")
                        Text("**Settings** — Adjust app preferences.")
                        Text("**Feature Flags** — Some features above are controlled by server-driven feature flags, so they can be enabled or disabled without an app update.")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Configuration
                VStackBox(titleView: {
                    Label("Configuration", systemImage: "gearshape.fill")
                        .font(.headline)
                        .foregroundStyle(ViewConfig.brandColor)
                }) {
                    Text("""
                    App-wide appearance and constants live in `ViewConfig` — brand name, \
                    colors, URLs, and timing. Menu items and their visibility are defined \
                    in `NavigationItem`. The template supports two navigation patterns \
                    (side menu and tab bar); switch between them in `LaunchView`.
                    """)
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                // MARK: - FAQ
                VStackBox(titleView: {
                    Label("Frequently Asked Questions", systemImage: "questionmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(ViewConfig.brandColor)
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Group {
                            Text("**Q:** Where do I start customizing?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("""
                            **A:** Begin with `ViewConfig` to set your app's name, theme \
                            color, and links. Then review `NavigationItem` to choose which \
                            menu items appear and in what order.
                            """)
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }

                        Group {
                            Text("**Q:** Why are some features not showing up?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("""
                            **A:** Several features (messages, comments, activity log, \
                            settings) are controlled by feature flags. Check your Firebase \
                            configuration or `ViewConfig.bundledFeatureFlags` to enable them.
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
                        .foregroundStyle(ViewConfig.fgColor)

                    HStack(spacing: 4) {
                        Text("Visit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Link(destination: ViewConfig.supportURL) {
                            Text(ViewConfig.supportText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
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
}
#endif
