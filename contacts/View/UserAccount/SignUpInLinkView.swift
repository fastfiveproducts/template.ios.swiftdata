//
//  SignUpInLinkView.swift
//  contacts
//
//  Created by Pete Maiser on 7/15/25.
//

import SwiftUI

struct SignUpInLinkView: View {
    @ObservedObject var currentUserService: CurrentUserService
    
    var inToolbar: Bool = false
    var asPage: Bool = false
    var leadingText: String {
        if inToolbar { return "Sign In →" }
        else { return "Tap Here or" }
    }
    
    var body: some View {
        if !inToolbar { Divider() }
        
        NavigationLink {
            UserAccountView(
                viewModel: UserAccountViewModel(),
                currentUserService: currentUserService)
        } label: {
            HStack {
                Spacer()
                Text(leadingText)
                Label("to Sign-Up or Sign-In!", systemImage: currentUserService.isSignedIn ? "\(MenuItem.profile.systemImage).fill" : MenuItem.profile.systemImage)
                Spacer()
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}


#Preview {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    NavigationStack {
        VStack(alignment: .leading, spacing: 24) {
            VStackBox(title: "Greeting") {
                Text("Hello World!")
                SignUpInLinkView(currentUserService: currentUserService)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SignUpInLinkView(currentUserService: currentUserService, inToolbar: true)
            }
        }
        Spacer()
    }
}
