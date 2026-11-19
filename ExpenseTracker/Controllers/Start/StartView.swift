//
//  StartView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import RealmSwift
import SwiftUI

struct StartView: View {
    var resetToken: Int = .zero

    @Environment(\.realm) private var realm
    @Environment(\.scenePhase) private var scenePhase

    @State private var input = AmountInput()
    @State private var showHistory = false
    @State private var note = String()
    @State private var showNoteInput = false
    @State private var transactionDay: Date?
    @State private var showDatePopup = false
    @State private var amountAttentionTrigger: Int = .zero
    @State private var showAccounts = false
    @State private var selectedOperationType: OperationType = .outcome
    @AppStorage(UDKey.selectedAccount.rawValue, store: UserDefaults.shared) private var selectedAccountId = String()
    @ObservedResults(Account.self, where: Account.available, sortDescriptor: RealmSwift.SortDescriptor(keyPath: "sortIndex")) private var accounts
    @StoredSettings private var appSettings

    private var operationType: OperationType {
        appSettings.accounting.incomeEnabled ? selectedOperationType : .outcome
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if appSettings.accounting.multipleAccountsEnabled {
                        StartBalanceCard(accounts: Array(accounts), selected: selectedAccount, onSelect: selectAccount, action: openAccounts)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        // .border(.red)
                    }

                    DigitPadView(input: $input, placeholder: operationType.enterAmountTitle, attentionTrigger: amountAttentionTrigger)
                        .frame(maxWidth: .infinity)
                        // .padding(.top, 12)
                        // .border(.red)
                        .overlay(alignment: .bottomTrailing) {
                            VStack(spacing: 8) {
                                if appSettings.accounting.incomeEnabled {
                                    operationTypeButton
                                }
                                dateButton
                                noteButton
                            }
                            // .padding(.bottom, 12)
                        }
                    if showCategories {
                        CategoryGrid(operationType: operationType) { category in
                            addTransaction(with: category)
                        }
                        // .border(.red)
                        .padding(.top, 16)
                        .id(operationType)
                        .transition(.opacity)
                    }

                    RecentTransactionsList(operationType: operationType)
                        // .border(.green)
                        .padding(.top, showCategories ? 4 : 20)

                    historyButton
                        .padding(.top, 8)
                }
                // .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
                .animation(.appStandard, value: showCategories)
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
            } else if showDatePopup {
                TransactionDatePopup(date: transactionDay ?? Date(), onCancel: closeDatePopup) { date in
                    transactionDay = Calendar.current.isDateInToday(date) ? nil : date
                    closeDatePopup()
                }
                .transition(.opacity)
            }
        }
        .onAppear(perform: FeedbackManager.shared.prepare)
        .onChange(of: resetToken) {
            withAnimation(.appStandard) {
                selectedOperationType = .outcome
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                input.reset()
            }
        }
        .animation(.appStandard, value: showNoteInput)
        .animation(.appStandard, value: showDatePopup)
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
                    tint: note.isBlank ? nil : .appLabel.opacity(0.25),
                    isInteractive: true,
                    fallback: .appLabel.opacity(note.isBlank ? 0.1 : 0.25)
                )
        }
    }

    private var dateButton: some View {
        let isSet = transactionDay != nil

        return Button(action: openDatePopup) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundColor(isSet ? .appWhite : .appLabel)
                .frame(width: 48, height: 50)
                .glassSurface(
                    in: UnevenRoundedRectangle(topLeadingRadius: 25, bottomLeadingRadius: 25),
                    tint: isSet ? .appPrimary.opacity(0.25) : nil,
                    isInteractive: true,
                    fallback: isSet ? Color.appPrimary.opacity(0.25) : Color.appLabel.opacity(0.1)
                )
        }
        .accessibilityLabel(L10n.transactionEditDate)
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
                    tint: isIncome ? .green.opacity(0.25) : nil,
                    isInteractive: true,
                    fallback: isIncome ? Color.green.opacity(0.25) : Color.appLabel.opacity(0.1)
                )
        }
        .accessibilityLabel(operationType.title)
    }

    private var historyButton: some View {
        RoundIconButton(systemImage: "chevron.down", action: openHistory)
            .accessibilityLabel(L10n.historyTitle)
    }

    private func openHistory() {
        FeedbackManager.shared.buttonTapped()
        showHistory = true
    }

    private func openNoteInput() {
        FeedbackManager.shared.buttonTapped()
        showNoteInput = true
    }

    private func openDatePopup() {
        FeedbackManager.shared.buttonTapped()
        showDatePopup = true
    }

    private func closeDatePopup() {
        showDatePopup = false
    }

    private func transactionDate() -> Date {
        let now = Date()
        guard let transactionDay else { return now }

        let calendar = Calendar.current
        let time = calendar.dateComponents([.hour, .minute, .second], from: now)
        return calendar.date(bySettingHour: time.hour ?? .zero, minute: time.minute ?? .zero, second: time.second ?? .zero, of: transactionDay) ?? transactionDay
    }

    private func toggleOperationType() {
        FeedbackManager.shared.buttonTapped()
        withAnimation(.appStandard) {
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
            date: transactionDate(),
            note: note.isBlank ? nil : note,
            account: selectedAccount
        )

        let previousInput = input
        let previousNote = note

        let realm = realm
        realm.update { realm.add(transaction) }
        FeedbackManager.shared.transactionAdded()
        input.reset()
        note = String()

        UndoToastCenter.shared.show(L10n.transactionsListTransactionAdded) {
            realm.deletePermanently(transaction)
            if input.isEmpty, note.isBlank {
                input = previousInput
                note = previousNote
            }
        }
        return true
    }
}

struct StartBalanceCard: View {
    let accounts: [Account]
    let selected: Account?
    let onSelect: (Account) -> Void
    let action: () -> Void

    @ObservedResults(Transaction.self, where: Transaction.visible) private var transactions

    var body: some View {
        let transactions = Array(transactions)

        BalanceCard(accounts: accounts, selected: selected, balance: selected?.current(in: transactions), amountFor: { $0.current(in: transactions) }, onSelect: onSelect, action: action)
    }
}

extension StartBalanceCard: Equatable {
    nonisolated static func == (lhs: StartBalanceCard, rhs: StartBalanceCard) -> Bool { lhs.accounts == rhs.accounts && lhs.selected == rhs.selected }
}

#Preview {
    StartView()
        .undoToast()
        .environment(\.realmConfiguration, makePreviewRealm().configuration)
}

@MainActor private var previewRealms: [Realm] = []

@MainActor
func makePreviewRealm() -> Realm {
    let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: UUID().uuidString))
    DataSeeder.seedDefaultCategories(in: realm)
    previewRealms.append(realm)
    return realm
}
