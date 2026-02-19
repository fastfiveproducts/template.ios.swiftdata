//
//  PollingViewModifier.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 2/7/26.
//      Template v0.2.5 — Fast Five Products LLC's public AGPL template.
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

extension View {
    func polling(_ action: @escaping () -> Void, interval: TimeInterval = 30, fetchOnAppear: Bool = true) -> some View {
        modifier(PollingViewModifier(action: action, interval: interval, fetchOnAppear: fetchOnAppear))
    }
}

private struct PollingViewModifier: ViewModifier {
    let action: () -> Void
    let interval: TimeInterval
    let fetchOnAppear: Bool

    func body(content: Content) -> some View {
        content
            .task {
                if fetchOnAppear { action() }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(interval))
                    action()
                }
            }
    }
}
