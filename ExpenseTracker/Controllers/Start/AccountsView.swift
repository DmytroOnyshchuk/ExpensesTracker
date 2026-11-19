//
//  AccountsView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: Account.notDeleted, sort: \Account.sortIndex) private var accounts: [Account]
    @Query(filter: Transaction.notDeleted) private var transactions: [Transaction]

    @State private var editingAccount: Account?
    @State private var showNewAccount = false

    var body: some View {
        let transactions = transactions

        List {
            ForEach(accounts, id: \.uuid) { account in
                AccountRow(name: account.name, amount: account.current(in: transactions), isDisabled: account.isDisabled) {
                    FeedbackManager.shared.buttonTapped()
                    editingAccount = account
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparatorTint(.appSecond)
                .listRowSeparator(.hidden, edges: .top)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if canTurnOff(account) {
                        Button(role: .destructive) {
                            modelContext.deleteWithUndo(account)
                        } label: {
                            Label(L10n.remove, systemImage: "trash")
                        }
                        .tint(.appRed)
                    }
                }
            }

            HStack(spacing: 12) {
                Spacer(minLength: 8)

                Text(L10n.accountsTotal)
                    .font(.appMedium(18))
                    .foregroundColor(.appLabel)

                Text(accounts.enabled.total(in: transactions).getAmount())
                    .font(.appMedium(22))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.appStandard, value: accounts.count)
        .appBackground()
        .navigationTitle(L10n.accountsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    FeedbackManager.shared.buttonTapped()
                    showNewAccount = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.appWhite)
                }
            }
        }
        .overlay {
            if let editingAccount {
                AccountEditPopup(
                    title: L10n.accountsEdit,
                    name: editingAccount.name,
                    amount: editingAccount.current(in: transactions),
                    isDisabled: editingAccount.isDisabled,
                    canDisable: canTurnOff(editingAccount),
                    onCancel: { self.editingAccount = nil }
                ) { name, amount, isDisabled in
                    update(editingAccount, name: name, amount: amount, currentAmount: editingAccount.current(in: transactions), isDisabled: isDisabled)
                    self.editingAccount = nil
                }
                .transition(.opacity)
            } else if showNewAccount {
                AccountEditPopup(
                    title: L10n.accountsNew,
                    name: "",
                    amount: .zero,
                    onCancel: { showNewAccount = false }
                ) { name, amount, _ in
                    create(name: name, amount: amount)
                    showNewAccount = false
                }
                .transition(.opacity)
            }
        }
        .animation(.appStandard, value: editingAccount?.uuid)
        .animation(.appStandard, value: showNewAccount)
    }

    private func canTurnOff(_ account: Account) -> Bool {
        account.isDisabled || accounts.enabled.count > 1
    }

    private func update(_ account: Account, name: String, amount: Int, currentAmount: Int, isDisabled: Bool) {
        account.name = name
        account.isDisabled = isDisabled
        if amount != currentAmount {
            account.setAmount(amount)
        }
        try? modelContext.save()
    }

    private func create(name: String, amount: Int) {
        let account = Account(name: name, amount: amount, sortIndex: accounts.nextSortIndex)
        modelContext.insert(account)
        try? modelContext.save()
    }
}

extension AccountsView: Equatable {
    nonisolated static func == (lhs: AccountsView, rhs: AccountsView) -> Bool { true }
}

struct AccountRow: View {
    let name: String
    let amount: Int
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(name)
                    .font(.appLight(18))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(amount.getAmount())
                    .font(.appRegular(20))
                    .foregroundColor(amount < .zero ? .appRed : .appWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .opacity(isDisabled ? 0.4 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AccountEditPopup: View {
    let title: String
    let onCancel: () -> Void
    let onConfirm: (String, Int, Bool) -> Void

    private let showsDisableOption: Bool
    private let canDisable: Bool

    @State private var name: String
    @State private var amountText: String
    @State private var isDisabled: Bool
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case amount
    }

    init(title: String, name: String, amount: Int, isDisabled: Bool? = nil, canDisable: Bool = true, onCancel: @escaping () -> Void, onConfirm: @escaping (String, Int, Bool) -> Void) {
        self.title = title
        self.showsDisableOption = isDisabled != nil
        self.canDisable = canDisable
        _isDisabled = State(initialValue: isDisabled ?? false)
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _name = State(initialValue: name)
        _amountText = State(initialValue: AmountInput.text(from: amount))
    }

    var body: some View {
        TransactionEditPopup(canConfirm: canConfirm, onCancel: cancel, onConfirm: confirm) {
            VStack(spacing: 16) {
                header

                VStack(spacing: 12) {
                    field(L10n.accountsName, systemImage: "pencil", isFocused: focusedField == .name) {
                        TextField("", text: $name, prompt: Text(L10n.accountsNew).foregroundColor(.appLabel.opacity(0.6)))
                            .font(.appRegular(18))
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .amount }
                    }
                    .onTapGesture { focusedField = .name }

                    field(L10n.startviewBalance, systemImage: "banknote", isFocused: focusedField == .amount) {
                        TextField("", text: $amountText, prompt: Text("0").foregroundColor(.appLabel.opacity(0.6)))
                            .font(.appMedium(22))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                    }
                    .onTapGesture { focusedField = .amount }
                }

                if showsDisableOption {
                    disableOption
                }
            }
            .padding(.horizontal, 16)
            .animation(.appStandard, value: focusedField)
        }
        .onAppear {
            focusedField = name.isBlank ? .name : .amount
        }
    }

    private var canConfirm: Bool {
        !name.isBlank
    }

    private var disableOption: some View {
        Toggle(isOn: $isDisabled) {
            Text(L10n.accountsDisable)
                .font(.appLight(16))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .tint(.appPrimary)
        .padding(.horizontal, 16)
        .disabled(!canDisable)
        .opacity(canDisable ? 1 : 0.4)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 24))
                .foregroundColor(.appPrimary)
                .frame(width: 56, height: 56)
                .background(.appPrimary.opacity(0.15), in: Circle())

            Text(title)
                .font(.appMedium(18))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func field(_ title: String, systemImage: String, isFocused: Bool, @ViewBuilder content: () -> some View) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundColor(isFocused ? .appPrimary : .appLabel)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appLight(12))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)

                content()
                    .foregroundColor(.appWhite)
                    .tint(.appPrimary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.appPrimary.opacity(isFocused ? 1 : 0), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func cancel() {
        focusedField = nil
        onCancel()
    }

    private func confirm() {
        focusedField = nil
        onConfirm(name.trimmingCharacters(in: .whitespacesAndNewlines), AmountInput.amount(from: amountText), isDisabled)
    }
}

#Preview {
    NavigationStack {
        AccountsView()
    }
    .modelContainer(makePreviewModelContainer())
}
