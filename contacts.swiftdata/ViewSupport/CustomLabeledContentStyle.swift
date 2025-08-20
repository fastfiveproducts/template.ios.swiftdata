//
//  CustomLabeledContentStyle.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.2 (updated) Fast Five Products LLC's public AGPL template.
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

// MARK: - Top Labeled style, with trailing content support

struct TopLabeledContentStyle: LabeledContentStyle {
    @Environment(\.labeledContentTrailing) private var trailing

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.label
                .font(.caption)
                .foregroundStyle(.secondary)

            if let trailing {
                // Put the field and trailing accessory on the same row.
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    configuration.content
                    Spacer(minLength: 0)
                    trailing
                }
            } else {
                configuration.content
            }
        }
    }
}


// MARK: - Environment plumbing for the trailing accessory

private struct LabeledContentTrailingKey: EnvironmentKey {
    static let defaultValue: AnyView? = nil
}

extension EnvironmentValues {
    var labeledContentTrailing: AnyView? {
        get { self[LabeledContentTrailingKey.self] }
        set { self[LabeledContentTrailingKey.self] = newValue }
    }
}

extension View {
    // Provide an optional trailing accessory for use by a `LabeledContentStyle`.
    func labeledContentTrailing<Accessory: View>(
        @ViewBuilder _ accessory: () -> Accessory
    ) -> some View {
        environment(\.labeledContentTrailing, AnyView(accessory()))
    }
}


// MARK: - Preview / Examples

#if DEBUG
private struct TopLabelLabeledContentStylePreview: View {
    var labelText: String
    var promptText: String
    @State var text: String = ""
    @FocusState private var focusedFieldIndex: Int?

    var body: some View {
        LabeledContent {
            TextField(promptText, text: $text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .focused($focusedFieldIndex, equals: 0)
        } label: {
            Text(labelText)
        }
        // Example trailing accessory (Clear button)
        .labeledContentTrailing {
            if !text.isEmpty {
                Button("Clear") { text = "" }
                    .buttonStyle(.borderless)
            }
        }
        .labeledContentStyle(TopLabeledContentStyle())
    }
}

#Preview("TopLabelLabeledContentStyle") {
    Form {
        Section {
            TopLabelLabeledContentStylePreview(
                labelText: "Your Name",
                promptText: "Name or Initials"
            )
            TopLabelLabeledContentStylePreview(
                labelText: "More Stuff",
                promptText: "Stuff we want to know"
            )
            // Another example showing you can place any view in the trailing content
            LabeledContent {
                TextField("Email", text: .constant(""))
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } label: {
                Text("Email")
            }
            .labeledContentTrailing {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
            }
            .labeledContentStyle(TopLabeledContentStyle())
        }
    }
    .formStyle(.grouped)
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
}
#endif
