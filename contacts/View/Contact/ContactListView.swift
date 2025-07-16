//
//  ContactListView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/13/25.
//
//  Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    @ObservedObject var currentUserService: CurrentUserService
    
    @State private var showAddSheet = false
    @State private var newContact = Contact.empty
    @State private var selectedContact: Contact?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List {
                ForEach(contacts) { contact in
                    Button {
                        selectedContact = contact
                    } label: {
                        HStack {
                            Text("\(contact.firstName) \(contact.lastName)")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                    }
                }
                .onDelete(perform: deleteContact)
            }
            .listStyle(.plain)
            
            if currentUserService.isSignedIn {
                Divider()
                Button {
                    showAddSheet = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Add Contact", systemImage: "plus")
                        Spacer()
                    }
                }
            } else {
                SignUpInLinkView(currentUserService: currentUserService)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                ContactDetailView(contact: newContact, createMode: true)
                    .navigationTitle("New Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newContact = Contact.empty
                                showAddSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if newContact.isValid {
                                    modelContext.insert(newContact)
                                    newContact = Contact.empty
                                    showAddSheet = false
                                }
                            }
                            .disabled(!newContact.isValid)
                        }
                    }
            }
        }
        .sheet(item: $selectedContact) { contact in
            NavigationStack {
                ContactDetailView(contact: contact)
                    .navigationTitle("Edit Contact")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                selectedContact = nil
                            }
                        }
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func deleteContact(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(contacts[index])
            }
        }
    }
}

#if DEBUG
#Preview ("test-data signed-in") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)

    for task in Contact.testObjects {
        container.mainContext.insert(task)
    }

    let currentUserService = CurrentUserTestService.sharedSignedIn
    return ContactListView(currentUserService: currentUserService)
        .modelContainer(container)
}
#Preview ("no-data and signed-out") {
    let container = try! ModelContainer()
    let currentUserService = CurrentUserTestService.sharedSignedOut
    return ContactListView(currentUserService: currentUserService)
        .modelContainer(container)
}
#endif
