//
//  ColorSwatch.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct ColorSwatch: View {
    let color: Color
    var isSelected: Bool = false

    private let cornerRadius: CGFloat = 8
    private let borderGap: CGFloat = 0.5

    private var borderWidth: CGFloat {
        isSelected ? 2 : 0.5
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius - borderWidth - borderGap)
            .fill(color)
            .padding(borderWidth + borderGap)
            .frame(height: 28)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.appWhite, lineWidth: borderWidth)
            )
    }
}

#Preview {
    HStack(spacing: 12) {
        ColorSwatch(color: .green)
            .frame(width: 56)
        ColorSwatch(color: .orange, isSelected: true)
            .frame(width: 56)
    }
    .padding()
    .background(.appMain)
}
