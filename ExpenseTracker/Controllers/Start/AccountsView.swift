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
    @Query(sort: \Account.sortIndex) private var storedAccounts: [Account]
    @Query private var storedTransactions: [Transaction]

    @State private var editingAccount: Account?
    @State private var showNewAccount = false

    private var accounts: [Account] { storedAccounts.notDeleted }
    private var transactions: [Transaction] { storedTransactions.notDeleted }

    var body: some View {
        let transactions = transactions

        List {
            ForEach(accounts, id: \.uuid) { account in
                AccountRow(name: account.name, amount: account.current(in: transactions)) {
                    editingAccount = account
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparatorTint(.appSecond)
                .listRowSeparator(.hidden, edges: .top)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if accounts.count > 1 {
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

                Text(accounts.total(in: transactions).getAmount())
                    .font(.appMedium(22))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.default, value: accounts.count)
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
                    onCancel: { self.editingAccount = nil }
                ) { name, amount in
                    update(editingAccount, name: name, amount: amount, currentAmount: editingAccount.current(in: transactions))
                    self.editingAccount = nil
                }
                .transition(.opacity)
            } else if showNewAccount {
                AccountEditPopup(
                    title: L10n.accountsNew,
                    name: "",
                    amount: .zero,
                    onCancel: { showNewAccount = false }
                ) { name, amount in
                    create(name: name, amount: amount)
                    showNewAccount = false
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: editingAccount?.uuid)
        .animation(.easeInOut(duration: 0.2), value: showNewAccount)
    }

    private func update(_ account: Account, name: String, amount: Int, currentAmount: Int) {
        account.name = name
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

struct InsetDivider: View {
    var body: some View {
        Rectangle()
            .fill(.appLabel.opacity(0.25))
            .frame(height: 0.5)
            .padding(.horizontal, 20)
    }
}

struct AccountRow: View {
    let name: String
    let amount: Int
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
            .padding(.horizontal, 20)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AccountEditPopup: View {
    let title: String
    let onCancel: () -> Void
    let onConfirm: (String, Int) -> Void

    @State private var name: String
    @State private var amountText: String
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case amount
    }

    init(
        title: String,
        name: String,
        amount: Int,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (String, Int) -> Void
    ) {
        self.title = title
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _name = State(initialValue: name)
        _amountText = State(initialValue: AmountInput.text(from: amount))
    }

    var body: some View {
        TransactionEditPopup(
            canConfirm: !name.isBlank,
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

                field(
                    TextField("", text: $name, prompt: Text(L10n.accountsName).foregroundColor(.appLabel.opacity(0.6)))
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .amount }
                )

                field(
                    TextField("", text: $amountText, prompt: Text("0").foregroundColor(.appLabel.opacity(0.6)))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                )
            }
        }
        .onAppear {
            focusedField = name.isBlank ? .name : .amount
        }
    }

    private func field(_ content: some View) -> some View {
        content
            .font(.appRegular(20))
            .foregroundColor(.appWhite)
            .tint(.appPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
    }

    private func cancel() {
        focusedField = nil
        onCancel()
    }

    private func confirm() {
        focusedField = nil
        onConfirm(name.trimmingCharacters(in: .whitespacesAndNewlines), AmountInput.amount(from: amountText))
    }
}

#Preview {
    NavigationStack {
        AccountsView()
    }
    .modelContainer(makePreviewModelContainer())
}
