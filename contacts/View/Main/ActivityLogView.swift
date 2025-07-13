//
//  ActivityLogView.swift
//
//  Created by Elizabeth Maiser on 7/5/25.
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

struct ActivityLogView: View, DebugPrintable {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ActivityLogEntry.timestamp) var logEntries: [ActivityLogEntry]
    
    var body: some View {
        VStack {
            HStack {
                Text("Activity Log")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom)
            List {
                if logEntries.isEmpty {
                    Text("No activity logged yet.")
                } else {
                    ForEach(logEntries) { entry in
                        HStack {
                            Text(entry.event)
                            Spacer()
                            Text(entry.timestamp, style: .time)
                        }
                    }
                    .onDelete(perform: deleteLogEntry)
                }
            }
            .listStyle(.plain)
            Spacer()
            Button("Clear All Logs") {
                                clearAllLogs()
                            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    private func deleteLogEntry(at offsets: IndexSet) {
        for index in offsets {
            let entryToDelete = logEntries[index]
            modelContext.delete(entryToDelete)
        }
    }
    
    private func clearAllLogs() {
            do {
                try modelContext.delete(model: ActivityLogEntry.self)
            } catch {
            }
        }
}

#Preview {
    ActivityLogView()
        .modelContainer(for: ActivityLogEntry.self, inMemory: true)
}
