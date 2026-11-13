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
                .foregroundColor(input.isEmpty ? .appLabel : .appWhite)
                .frame(height: 64)

            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(action: {
                            FeedbackManager.keyTapped(key)
                            input.tap(key)
                        }) {
                            label(for: key)
                                .frame(width: 75, height: 75)
                                .background(.appLabel.opacity(0.1))
                                .foregroundColor(.appWhite)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func label(for key: AmountInput.Key) -> some View {
        switch key {
        case let .digit(digit):
            Text(String(digit))
                .font(.appMedium(36))
        case .decimalSeparator:
            Text(".")
                .font(.appMedium(36))
        case .backspace:
            Image(systemName: "delete.backward.fill")
                .font(.system(size: 20, weight: .medium))
        }
    }
}

#Preview {
    @Previewable @State var input = AmountInput()

    DigitPadView(input: $input)
        .padding()
        .background(.appMain)
}
