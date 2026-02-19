//
//  VerifyEmailView.swift
//
//  Created by Claude, Fast Five Products LLC, on 2/18/26.
//      Template v0.2.9 — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
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

struct VerifyEmailView: View {
    @ObservedObject var currentUserService: CurrentUserService
    @State private var statusText = ""
    @State private var showVerifiedAlert = false

    var body: some View {
        Section(header: Text("Email Verification")) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your email address needs to be verified:")
                    .font(.subheadline)
                Text(currentUserService.user.auth.email)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Some features are unavailable until your email is verified.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            Button {
                resendVerificationEmail()
            } label: {
                HStack {
                    Text("Resend Verification Email")
                    if currentUserService.isSendingVerificationEmail {
                        ProgressView()
                    }
                }
            }
            .disabled(currentUserService.isSendingVerificationEmail)

            Button {
                checkStatus()
            } label: {
                HStack {
                    Text("Check Verification Status")
                    if currentUserService.isCheckingVerificationStatus {
                        ProgressView()
                    }
                }
            }
            .disabled(currentUserService.isCheckingVerificationStatus)

            if !statusText.isEmpty {
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .alert("Email Verified", isPresented: $showVerifiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your email has been verified. All features are now available.")
        }
    }

    private func resendVerificationEmail() {
        statusText = ""
        Task {
            do {
                try await currentUserService.sendVerificationEmail()
                statusText = "Verification email sent. Check your inbox.\nIf you don't see the email, check your Junk folder."
            } catch {
                statusText = "Failed to send verification email. Please try again."
            }
        }
    }

    private func checkStatus() {
        statusText = ""
        Task {
            do {
                let verified = try await currentUserService.checkEmailVerificationStatus()
                if verified {
                    showVerifiedAlert = true
                } else {
                    statusText = "Email not yet verified. Check your inbox and try again.\nIf you don't see the email, check your Junk folder."
                }
            } catch {
                statusText = "Unable to check status. Please try again."
            }
        }
    }
}


#if DEBUG
#Preview ("test-data unverified user") {
    let currentUserService = CurrentUserTestService.sharedUnverifiedUser
    Form {
        VerifyEmailView(currentUserService: currentUserService)
    }
}
#endif
