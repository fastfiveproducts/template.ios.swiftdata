//
//  UserAccountView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
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
