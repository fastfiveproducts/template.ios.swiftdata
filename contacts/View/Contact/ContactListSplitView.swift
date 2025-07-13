//
//  ContactListSplitView.swift
//
//  Created by Pete Maiser on 7/12/25.
//

import SwiftUI
import SwiftData


struct ContactListSplitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var showAddSheet = false
    @State private var newContact = Contact.empty

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(contacts) { contact in
                    NavigationLink {
                        ContactDetailView(contact: contact)
                    } label: {
                        Text("\(contact.firstName) \(contact.lastName)")

                    }
                }
                .onDelete(perform: deleteContact)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .navigationTitle("My Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Label("Add Contact", systemImage: "plus")
                    }
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
        } detail: {
            Text("Select an item")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)

    for task in Contact.testObjects {
        container.mainContext.insert(task)
    }

    return ContactListSplitView()
        .modelContainer(container)
}
#endif
