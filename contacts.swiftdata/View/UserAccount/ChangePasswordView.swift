//
//  ChangePasswordView.swift
//  contacts.swiftdata.swiftdata
//
//  Created by Pete Maiser on 8/20/25.
//

import SwiftUI

struct ChangePasswordView: View, DebugPrintable {
    @ObservedObject var viewModel : UserAccountViewModel
    @ObservedObject var currentUserService: CurrentUserService
    
    @FocusState private var focusedField: Field?
    private func nextField() {
        switch focusedField {
            case .passwordOld:
                focusedField = .passwordNew
            case .passwordNew:
                focusedField = .passwordOld
            case .passwordAgain:
                focusedField = .none
            case .none:
                focusedField = .none
        }
    }
    private enum Field: Hashable { case passwordOld, passwordNew, passwordAgain }

    var body: some View {
        Section(header: Text("Change Password")) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}


#if DEBUG
#Preview {
    let currentUserService = CurrentUserTestService.sharedCreatingUser
    let viewModel = UserAccountViewModel(createAccountMode: true, showStatusMode: true)
    ScrollViewReader { proxy in
        Form {
            ChangePasswordView(
                viewModel: viewModel,
                currentUserService: currentUserService
            )
        }
        .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
        .environment(\.font, Font.body)
    }
}
#endif
