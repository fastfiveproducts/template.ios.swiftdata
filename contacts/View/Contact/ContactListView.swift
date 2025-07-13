//
//  ContactListView.swift
//  contacts
//
//  Created by Pete Maiser on 7/13/25.
//


import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    
    @State private var showAddSheet = false
    @State private var newContact = Contact.empty
    @State private var selectedContact: Contact?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contacts - My Contacts")
                .font(.title2)
                .fontWeight(.semibold)
        
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
                        .contentShape(Rectangle()) // ensures tap area fills row
                    }
                }
                .onDelete(perform: deleteContact)
            }
            .listStyle(.plain)
            .frame(maxHeight: 150) // Optional: constrain list height in the panel
            
            Button {
                showAddSheet = true
            } label: {
                Label("Add Contact", systemImage: "plus")
            }
            .padding(.top)
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
    
    private func deleteContact(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(contacts[index])
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

    return ContactListView()
        .modelContainer(container)
}
#endif
