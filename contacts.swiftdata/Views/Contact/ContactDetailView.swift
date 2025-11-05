//
//  ContactDetailView.swift
//
//  Template file created by Pete Maiser, Fast Five Products LLC, on 7/12/25.
//      Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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

struct ContactDetailView: View {
    @Bindable var contact: Contact
    var createMode: Bool = false
    
    @FocusState private var focusedFieldIndex: Int?
    private func nextField() {
        let nextIndex = (focusedFieldIndex ?? -1) + 1
        if nextIndex < 3 {
            focusedFieldIndex = nextIndex
        } else {
            focusedFieldIndex = nil
        }
    }

    var body: some View {
        Form {
            LabeledContent {
                TextField(text: $contact.firstName, prompt: Text("First Name")) {}
                    .autocapitalization(.words)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .focused($focusedFieldIndex, equals: 0)
                    .onTapGesture { focusedFieldIndex = 0 }
                    .onSubmit { nextField() }
            } label: { Text("First Name:") }
                .labeledContentStyle(TopLabeledContentStyle())
            
            LabeledContent {
                TextField(text: $contact.lastName, prompt: Text("Last Name")) {}
                    .autocapitalization(.words)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .focused($focusedFieldIndex, equals: 1)
                    .onTapGesture { focusedFieldIndex = 1 }
                    .onSubmit { nextField() }
            } label: { Text("Last Name:") }
                .labeledContentStyle(TopLabeledContentStyle())

            LabeledContent {
                TextField(text: $contact.contact, prompt: Text("Contact Information")) {}
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .focused($focusedFieldIndex, equals: 2)
                    .onTapGesture { focusedFieldIndex = 2 }
                    .onSubmit { nextField() }
            } label: { Text("Contact:") }
                .labeledContentStyle(TopLabeledContentStyle())
            
            HStack {
                Text("Is a Dog:")
                Spacer()
                Button {
                    contact.isDog.toggle()
                } label: {
                    Image(systemName: contact.isDog ? "checkmark.circle.fill" : "circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel(contact.isDog ? "Dog selected" : "Dog not selected")
            }
            
            if !createMode {
                Text("Created: \(contact.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        }
        .onAppear {
            if createMode {
                focusedFieldIndex = 0
            }
        }
    }
}

#if DEBUG
#Preview ("Existing Contact"){
    ContactDetailView(contact: Contact.testObjects.randomElement()!)
}
#Preview ("Create Contact"){
    ContactDetailView(contact: Contact.empty, createMode: true)
}
#endif
