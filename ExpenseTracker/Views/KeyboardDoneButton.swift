//
//  KeyboardDoneButton.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct KeyboardDoneButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(L10n.done)
                .font(.appMedium(17))
                .foregroundColor(.appWhite)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .glassSurface(in: Capsule(), isInteractive: true, fallback: .appSecond)
                .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
