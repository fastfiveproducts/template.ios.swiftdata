//
//  UserAccountView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      Template v0.1.1 Fast Five Products LLC's public AGPL template.
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

struct UserAccountView: View {
    @StateObject var viewModel: UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService

    @Namespace var createUserViewId
          
    var body: some View {
        VStack {
            Form {
                SignUpInOutView(viewModel: viewModel, currentUserService: currentUserService)
                if currentUserService.isSignedIn && !viewModel.showStatusMode {
                    UserAccountProfileView()
                    UserAssociationView()
                    UserDemographicsView()
                }
            }
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
        .alert("Error", error: $viewModel.error)
    
        Text(viewModel.statusText)
    }
}


#if DEBUG
#Preview ("test-data signed-in") {
    let currentUserService = CurrentUserTestService.sharedSignedIn
    UserAccountView(
        viewModel: UserAccountViewModel(),
        currentUserService: currentUserService
    )
}
#Preview ("test-data signed-out") {
    let currentUserService = CurrentUserTestService.sharedSignedOut
    UserAccountView(
        viewModel: UserAccountViewModel(),
        currentUserService: currentUserService
    )
}
#endif
