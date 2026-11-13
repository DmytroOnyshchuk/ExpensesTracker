//
//  BalanceView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct BalanceCard: View {
    let balance: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(L10n.startviewBalance)
                    .font(.appLight(18))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)

                Text(balance?.getAmount() ?? "—")
                    .font(.appRegular(22))
                    .foregroundColor(amountColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(.appLabel.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.default, value: balance)
    }

    private var amountColor: Color {
        guard let balance else { return .appLabel }
        return balance < 0 ? .appRed : .appWhite.opacity(0.75)
    }
}

struct BalanceInputPopup: View {
    let onCancel: () -> Void
    let onConfirm: (Int) -> Void

    @State private var text: String
    @FocusState private var isFocused: Bool

    init(balance: Int?, onCancel: @escaping () -> Void, onConfirm: @escaping (Int) -> Void) {
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _text = State(initialValue: AmountInput.text(from: balance ?? 0))
    }

    var body: some View {
        TransactionEditPopup(canConfirm: !text.isBlank, onCancel: cancel, onConfirm: confirm) {
            VStack(spacing: 16) {
                Text(L10n.startviewBalance)
                    .font(.appMedium(16))
                    .foregroundColor(.appLabel)

                TextField("", text: $text, prompt: Text("0").foregroundColor(.appLabel.opacity(0.6)))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.appLight(32))
                    .foregroundColor(.appWhite)
                    .tint(.appBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(height: 60)
                    .background(.appMain)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 16)
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private func cancel() {
        isFocused = false
        onCancel()
    }

    private func confirm() {
        isFocused = false
        onConfirm(AmountInput.amount(from: text))
    }
}

#Preview("Balance card") {
    VStack(spacing: 16) {
        BalanceCard(balance: 1250000, action: {})
        BalanceCard(balance: -36050, action: {})
        BalanceCard(balance: nil, action: {})
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}

#Preview("Balance popup") {
    BalanceInputPopup(balance: 1250000, onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}
