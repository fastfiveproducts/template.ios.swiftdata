//
//  CommentPostsStackView.swift
//
//  Created by Pete Maiser on 7/14/25.
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.4
//

import SwiftUI

struct CommentPostsStackView: View, DebugPrintable {
    @ObservedObject var currentUserService: CurrentUserService
    @ObservedObject var store: PublicCommentStore
    
    var body: some View {
        if currentUserService.isSignedIn {
            VStackBox {
                PostsScrollView(
                    store: store,
                    currentUserId: currentUserService.userKey.uid,
                    showFromUser: true,
                    hideWhenEmpty: true
                )
                Divider()
                NavigationLink {
                    UserCommentPostsStackView(
                        currentUserService: currentUserService,
                        viewModel: UserPostViewModel<PublicComment>(),
                        store: store
                    )
                } label: {
                    HStack {
                        Spacer()
                        Text("Write a Comment")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                }
            }
        } else {
            VStackBox {
                Text("Not Signed In!")
                Divider()
                NavigationLink {
                    UserAccountView(
                        viewModel: UserAccountViewModel(),
                        currentUserService: currentUserService)
                } label: {
                    HStack {
                        Spacer()
                        Text("Tap Here or ") + Text(Image(systemName: "\(MenuItem.profile.systemImage)")) + Text(" to Sign In!")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                }
            }
            Spacer()
        }
    }
}


#if DEBUG
#Preview  {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    let store = PublicCommentStore.testLoaded()
    CommentPostsStackView(
        currentUserService: currentUserService,
        store: store
    )
}
#endif
