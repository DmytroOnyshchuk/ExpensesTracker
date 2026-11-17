//
//  StartView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct StartView: View {
    var resetToken: Int = .zero

    @Environment(\.modelContext) private var modelContext

    @State private var input = AmountInput()
    @State private var showHistory = false
    @State private var note = String()
    @State private var showNoteInput = false
    @State private var amountAttentionTrigger: Int = .zero
    @State private var showAccounts = false
    @State private var selectedOperationType: OperationType = .outcome
    @AppStorage(UDKey.selectedAccount.rawValue, store: UserDefaults.shared) private var selectedAccountId = String()
    @Query(sort: \Account.sortIndex) private var storedAccounts: [Account]
    @StoredSettings private var appSettings
    @Query(sort: \Transaction.date, order: .reverse, animation: .default) private var storedTransactions: [Transaction]

    private var accounts: [Account] { storedAccounts.notDeleted.enabled }
    private var transactions: [Transaction] { storedTransactions.visible }

    private var operationType: OperationType {
        appSettings.accounting.incomeEnabled ? selectedOperationType : .outcome
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    if appSettings.accounting.multipleAccountsEnabled {
                        BalanceCard(
                            accounts: accounts,
                            selected: selectedAccount,
                            balance: selectedAccount?.current(in: transactions),
                            amountFor: { $0.current(in: transactions) },
                            onSelect: selectAccount,
                            action: openAccounts
                        )
                        .padding(.horizontal, 8)
                    }

                    DigitPadView(input: $input, placeholder: operationType.enterAmountTitle, attentionTrigger: amountAttentionTrigger)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .bottomTrailing) {
                            VStack(spacing: 8) {
                                if appSettings.accounting.incomeEnabled {
                                    operationTypeButton
                                }
                                noteButton
                            }
                            .padding(.bottom, 12)
                        }
                    if showCategories {
                        CategoryGrid(operationType: operationType) { category in
                            addTransaction(with: category)
                        }
                        .id(operationType)
                        .transition(.opacity)
                    }

                    TransactionsList(transactions: transactions.of(operationType), operationType: operationType)

                    historyButton
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
                .animation(.easeInOut(duration: 0.25), value: showCategories)
            }
            .appBackground()
            .navigationDestination(isPresented: $showHistory) {
                HistoryView()
            }
            .navigationDestination(isPresented: $showAccounts) {
                AccountsView()
            }
        }
        .overlay {
            if showNoteInput {
                NoteInputView(note: $note, isPresented: $showNoteInput)
                    .transition(.opacity)
            }
        }
        .onChange(of: resetToken) {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedOperationType = .outcome
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showNoteInput)
    }

    private var isAmountEntered: Bool {
        input.amount != .zero
    }

    private var showCategories: Bool {
        !appSettings.hideCategories || isAmountEntered
    }

    private var selectedAccount: Account? {
        accounts.first { $0.uuid.uuidString == selectedAccountId } ?? accounts.first
    }

    private var noteButton: some View {
        Button(action: openNoteInput) {
            Image(systemName: "bubble.fill")
                .font(.system(size: 20))
                .foregroundColor(note.isBlank ? .appLabel : .appWhite)
                .frame(width: 48, height: 50)
                .glassSurface(
                    in: UnevenRoundedRectangle(topLeadingRadius: 25, bottomLeadingRadius: 25),
                    tint: note.isBlank ? nil : .appLabel.opacity(0.3),
                    isInteractive: true,
                    fallback: .appLabel.opacity(note.isBlank ? 0.1 : 0.3)
                )
        }
    }

    private var operationTypeButton: some View {
        let isIncome = operationType == .income

        return Button(action: toggleOperationType) {
            Image(systemName: operationType.systemImage)
                .font(.system(size: 20, weight: .semibold))
                .contentTransition(.symbolEffect(.replace))
                .foregroundColor(isIncome ? .appWhite : .appLabel)
                .frame(width: 48, height: 50)
                .glassSurface(
                    in: UnevenRoundedRectangle(topLeadingRadius: 25, bottomLeadingRadius: 25),
                    tint: isIncome ? .green.opacity(0.3) : nil,
                    isInteractive: true,
                    fallback: isIncome ? Color.green.opacity(0.3) : Color.appLabel.opacity(0.1)
                )
        }
        .accessibilityLabel(operationType.title)
    }

    private var historyButton: some View {
        Button(action: openHistory) {
            Image(systemName: "chevron.down")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.appPrimary)
                .frame(width: 60, height: 60)
                .glassSurface(
                    in: Circle(),
                    tint: .appPrimary.opacity(0.15),
                    isInteractive: true,
                    fallback: .appPrimary.opacity(0.15)
                )
        }
        .accessibilityLabel(L10n.historyTitle)
    }

    private func openHistory() {
        showHistory = true
    }

    private func openNoteInput() {
        FeedbackManager.shared.buttonTapped()
        showNoteInput = true
    }

    private func toggleOperationType() {
        FeedbackManager.shared.buttonTapped()
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedOperationType = operationType.toggled
        }
    }

    private func openAccounts() {
        FeedbackManager.shared.buttonTapped()
        showAccounts = true
    }

    private func selectAccount(_ account: Account) {
        FeedbackManager.shared.buttonTapped()
        selectedAccountId = account.uuid.uuidString
    }

    private func addTransaction(with category: TransactionCategory) -> Bool {
        guard input.amount != .zero else {
            amountAttentionTrigger += 1
            FeedbackManager.shared.amountMissing()
            return false
        }

        let transaction = Transaction(
            amount: input.amount,
            category: category,
            date: Date(),
            note: note.isBlank ? nil : note,
            account: selectedAccount
        )

        let previousInput = input
        let previousNote = note

        modelContext.insert(transaction)
        FeedbackManager.shared.transactionAdded()
        input.reset()
        note = String()

        UndoToastCenter.shared.show(L10n.transactionsListTransactionAdded) {
            modelContext.delete(transaction)
            try? modelContext.save()
            if input.isEmpty, note.isBlank {
                input = previousInput
                note = previousNote
            }
        }
        return true
    }
}

#Preview {
    StartView()
        .undoToast()
        .modelContainer(makePreviewModelContainer())
}

@MainActor
func makePreviewModelContainer() -> ModelContainer {
    let container = try! ModelContainer(
        for: Transaction.self, TransactionCategory.self, Account.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    DataSeeder.seedDefaultCategories(container: container)
    return container
}
