//
//  ActivityLogView.swift
//
//  Created by Elizabeth Maiser on 7/5/25.
//      Template v0.1.4 (updated)
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
    
    var showTitle: Bool = false
    
    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Activity Log")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom)
            }
            
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
                }
            }
            .listStyle(.plain)
            
            Spacer()
            Button("Clear All Logs") {
                clearAllLogs()
            }
        }
        .padding()
    }
    
    private func clearAllLogs() {
        withAnimation {
            for entry in logEntries {
                modelContext.delete(entry)
            }
        }
    }
}


#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ActivityLogEntry.self, configurations: config)
    
    for task in ActivityLogEntry.testObjects {
        container.mainContext.insert(task)
    }
    
    return ActivityLogView()
        .modelContainer(container)
}
#endif
