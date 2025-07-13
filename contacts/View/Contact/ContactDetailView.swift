//
//  ContactDetailView.swift
//
//  Created by Pete Maiser on 7/12/25.
//      Template v0.1.3
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      used here per terms of template.ios License file
//
//  This particular implementation is for:
//      APP_NAME
//      started from template 20YY-MM-DD
//      modifications cannot be used or copied without permission
//      from YOUR_NAME
//


import SwiftUI
import SwiftData

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
