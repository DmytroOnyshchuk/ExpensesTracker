//
//  BalanceView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct BalanceCard: View {
    let accounts: [Account]
    let selected: Account?
    let balance: Int?
    let amountFor: (Account) -> Int
    let onSelect: (Account) -> Void
    let action: () -> Void

    @State private var showAccountList = false

    var body: some View {
        HStack(spacing: 12) {
            if usesAccountPopover {
                accountPopoverButton
            } else {
                accountMenu
            }

            Button(action: action) {
                Text(balance?.getAmount() ?? "—")
                    .font(.appRegular(22))
                    .foregroundColor(amountColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        .animation(.appStandard, value: balance)
    }

    private var amountColor: Color {
        guard let balance else { return .appLabel }
        return balance < .zero ? .appRed : .appWhite.opacity(0.75)
    }

    private var usesAccountPopover: Bool {
        if #available(iOS 27.0, *) {
            return false
        }
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    private var accountLabel: some View {
        HStack(spacing: 4) {
            Text(selected?.name ?? L10n.startviewBalance)
                .font(.appLight(18))
                .foregroundColor(.appLabel)
                .lineLimit(1)

            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.appLabel)
        }
        .contentShape(Rectangle())
    }

    private var accountMenu: some View {
        Menu {
            ForEach(accounts, id: \.uuid) { account in
                Button {
                    onSelect(account)
                } label: {
                    if account.uuid == selected?.uuid {
                        Label("\(account.name) · \(amountFor(account).getAmount())", systemImage: "checkmark")
                    } else {
                        Text("\(account.name) · \(amountFor(account).getAmount())")
                    }
                }
            }
        } label: {
            accountLabel
        }
    }

    private var accountPopoverButton: some View {
        Button {
            showAccountList = !accounts.isEmpty
        } label: {
            accountLabel
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showAccountList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            BalanceAccountList(accounts: accounts, selected: selected, amountFor: amountFor) { account in
                showAccountList = false
                onSelect(account)
            }
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct BalanceAccountList: View {
    let accounts: [Account]
    let selected: Account?
    let amountFor: (Account) -> Int
    var onSelect: (Account) -> Void

    private static let rowHeight: CGFloat = 48
    private static let maxHeight: CGFloat = 432

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(accounts, id: \.uuid) { account in
                        Button {
                            onSelect(account)
                        } label: {
                            HStack(spacing: 12) {
                                Text("\(account.name) · \(amountFor(account).getAmount())")
                                    .font(.appLight(18))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Spacer(minLength: 0)

                                if account.uuid == selected?.uuid {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(.appWhite)
                            .padding(.horizontal, 16)
                            .frame(height: Self.rowHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .id(account.uuid)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(selected?.uuid, anchor: .center)
            }
        }
        .frame(width: 280, height: min(accounts.count.cgFloat * Self.rowHeight, Self.maxHeight))
    }
}

struct BalanceInputPopup: View {
    let onCancel: () -> Void
    let onConfirm: (Int) -> Void
    var onRemove: (() -> Void)?

    private let title: String
    private let allowsEmpty: Bool

    @State private var text: String
    @FocusState private var isFocused: Bool

    init(
        title: String = L10n.startviewBalance,
        balance: Int?,
        allowsEmpty: Bool = false,
        onRemove: (() -> Void)? = nil,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (Int) -> Void
    ) {
        self.onRemove = onRemove
        self.title = title
        self.allowsEmpty = allowsEmpty
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _text = State(initialValue: AmountInput.text(from: balance ?? .zero))
    }

    var body: some View {
        TransactionEditPopup(
            canConfirm: allowsEmpty || !text.isBlank,
            onRemove: onRemove.map { action in { remove(action) } },
            onCancel: cancel,
            onConfirm: confirm
        ) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.appMedium(14))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)

                TextField("", text: $text, prompt: Text("0").foregroundColor(.appLabel.opacity(0.6)))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.appRegular(22))
                    .foregroundColor(.appWhite)
                    .tint(.appPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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

    private func remove(_ action: () -> Void) {
        isFocused = false
        action()
    }

    private func confirm() {
        isFocused = false
        onConfirm(AmountInput.amount(from: text))
    }
}

#Preview("Balance card") {
    let cash = Account(name: "Cash", amount: 1250000)
    let bank = Account(name: "Bank", amount: -36050)
    return VStack(spacing: 16) {
        BalanceCard(accounts: [cash, bank], selected: cash, balance: 1250000, amountFor: \.amount, onSelect: { _ in }, action: {})
        BalanceCard(accounts: [cash, bank], selected: bank, balance: -36050, amountFor: \.amount, onSelect: { _ in }, action: {})
        BalanceCard(accounts: [], selected: nil, balance: nil, amountFor: \.amount, onSelect: { _ in }, action: {})
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}

#Preview("Balance popup") {
    BalanceInputPopup(balance: 1250000, onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}
