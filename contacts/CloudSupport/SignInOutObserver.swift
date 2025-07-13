//
//  SignInOutObserver.swift
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


import Foundation
import Combine

@MainActor
class SignInOutObserver: ObservableObject, DebugPrintable {

    // Subscribe to the sign-in publisher so we can refresh
    // data when a user signs-in
    private var signInPublisher: AnyCancellable?
    
    // Subscribe to the sign-out publisher so we can reset
    // data when a user signs-out
    private var signOutPublisher: AnyCancellable?
    
    init() {
        let currentUser = CurrentUserService.shared
        signInPublisher = currentUser.signInPublisher.sink { [weak self] in
            self?.postSignInSetup()
        }
        signOutPublisher = currentUser.signOutPublisher.sink { [weak self] in
             self?.postSignOutCleanup()
         }
    }
    
    deinit {
        signInPublisher?.cancel()
        signOutPublisher?.cancel()
    }
    
    // conforming classes override this to perform functions immediatey after sign-in
    func postSignInSetup() { }
    
    // conforming classes override user-session dependent data after user sign-out
    func postSignOutCleanup() { }
}
