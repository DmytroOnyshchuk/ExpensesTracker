//
//  DigitPadView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct DigitPadView: View {
    @Binding var input: AmountInput

    private let buttons: [[AmountInput.Key]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.decimalSeparator, .digit(0), .backspace],
    ]

    var body: some View {
        VStack(spacing: 12) {
            Text(input.text ?? L10n.startviewEnterExpense)
                .font(input.isEmpty ? .appLight(24) : .appLight(32))
                .foregroundColor(input.isEmpty ? .appLabel : .white)
                .frame(height: 64)

            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            input.tap(key)
                        }) {
                            Text(symbol(for: key))
                                .font(.appMedium(36))
                                .frame(width: 75, height: 75)
                                .background(Color.appLabel.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }

    private func symbol(for key: AmountInput.Key) -> String {
        switch key {
        case let .digit(digit):
            String(digit)
        case .decimalSeparator:
            "."
        case .backspace:
            "⌫"
        }
    }
}
