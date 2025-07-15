//  SettingsView.swift
//
//  Created by Elizabeth Maiser on 7/4/25.
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

struct SettingsView: View {
    @StateObject private var settings = SettingsStore()
    
    var showTitle: Bool = false
    
    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom)
            }
            
            List {
                Toggle("Dark Mode", isOn: $settings.darkMode)
                Toggle("Sound effects", isOn: $settings.soundEffects)
            }
            .listStyle(.plain)
            
            Spacer()
            Button("Reset All Settings") {
                withAnimation {
                    settings.resetAllSettings()
                }
            }
        }
        .padding()
    }
}


#if DEBUG
#Preview {
    SettingsView(showTitle: true)
}
#endif
