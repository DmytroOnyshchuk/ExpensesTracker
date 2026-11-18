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
    var placeholder: String = L10n.startviewEnterExpense
    var attentionTrigger: Int = .zero

    private let buttons: [[AmountInput.Key]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.decimalSeparator, .digit(0), .backspace],
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text(input.text ?? placeholder)
                .font(input.isEmpty ? .appLight(18) : .appLight(30))
                .foregroundColor(input.isEmpty ? .appLabel : .appWhite)
                .keyframeAnimator(initialValue: 1.0, trigger: attentionTrigger) { content, scale in
                    content.scaleEffect(scale)
                } keyframes: { _ in
                    CubicKeyframe(1.5, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.3)
                }
                .frame(height: 58)

            GlassContainer(spacing: 0) {
                VStack(spacing: 10) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { key in
                                Button(action: {
                                    FeedbackManager.shared.keyTapped(key)
                                    input.tap(key)
                                }) {
                                    label(for: key)
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(
                                            ThemeManager.shared.theme.colorScheme == .light
                                                ? .appWhite.mix(with: .appMain, by: 0.12)
                                                : .appWhite
                                        )
                                        .glassSurface(in: Circle(), isInteractive: true, fallback: .appLabel.opacity(0.1))
                                }
                            }
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
            Text(digit.string)
                .font(.appLight(38))
        case .decimalSeparator:
            Text(".")
                .font(.appLight(38))
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
