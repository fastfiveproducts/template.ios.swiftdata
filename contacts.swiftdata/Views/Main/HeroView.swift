//
//  HeroView.swift
//
//  Template created by Pete Maiser, July 2024 through October 2025
//      Template v0.2.3 Fast Five Products LLC's public AGPL template.
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

struct HeroView: View {
        
    var body: some View {
        VStack(spacing: 40) {
            Text("Template App")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(ViewConfig.fgColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)
            Text("")
        }
    }
}


#if DEBUG
#Preview {
    ZStack {
        ViewConfig.bgColor
            .ignoresSafeArea(.container, edges: .all)
        HeroView()
    }
}
#endif
