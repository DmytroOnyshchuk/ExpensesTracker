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
    @Environment(\.modelContext) private var modelContext

    @State private var input = AmountInput()
    @State private var showStatistics = false
    @State private var showHistory = false
    @State private var comment = ""
    @State private var showCommentInput = false
    @State private var amountAttentionTrigger = 0
    @State private var showBalanceInput = false
    @AppStorage(UDKey.balanceAmount.rawValue) private var balanceAmount = 0
    @AppStorage(UDKey.balanceDate.rawValue) private var balanceTimestamp = 0.0
    @Query(sort: \Transaction.date, order: .reverse, animation: .default) private var transactions: [Transaction]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    BalanceCard(balance: balance, action: openBalanceInput)

                    DigitPadView(input: $input, attentionTrigger: amountAttentionTrigger)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .top) {
                            topBar
                        }
                        .overlay(alignment: .bottomTrailing) {
                            commentButton
                        }
                    CategoryGrid { category in
                        addTransaction(with: category)
                    }

                    TransactionsList(transactions: transactions)

                    historyButton
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.appMain)
            .navigationDestination(isPresented: $showStatistics) {
                StatisticsView()
            }
            .navigationDestination(isPresented: $showHistory) {
                HistoryView()
            }
        }
        .overlay {
            if showCommentInput {
                CommentInputView(comment: $comment, isPresented: $showCommentInput)
                    .transition(.opacity)
            }
        }
        .overlay {
            if showBalanceInput {
                BalanceInputPopup(balance: balance, onCancel: closeBalanceInput) { amount in
                    setBalance(amount)
                    closeBalanceInput()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCommentInput)
        .animation(.easeInOut(duration: 0.2), value: showBalanceInput)
        .undoToast()
    }

    private var balance: Int? {
        guard balanceTimestamp > 0 else { return nil }

        let balanceDate = Date(timeIntervalSinceReferenceDate: balanceTimestamp)
        let spent = transactions
            .filter { $0.date > balanceDate }
            .reduce(0) { $0 + $1.amount }
        return balanceAmount - spent
    }

    private var commentButton: some View {
        Button(action: openCommentInput) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 20))
                .foregroundColor(comment.isBlank ? .appLabel : .appWhite)
                .frame(width: 48, height: 50)
                .background(.appLabel.opacity(comment.isBlank ? 0.1 : 0.3))
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, bottomLeadingRadius: 25))
        }
        .padding(.bottom, 12)
    }

    private var historyButton: some View {
        Button(action: openHistory) {
            Image(systemName: "chevron.down")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.appBlue)
                .frame(width: 60, height: 60)
                .background(.appBlue.opacity(0.15))
                .clipShape(Circle())
        }
        .accessibilityLabel(L10n.historyTitle)
    }

    private var topBar: some View {
        HStack {
            topBarButton(systemImage: "list.bullet", action: openMenu)
            Spacer()
            topBarButton(systemImage: "chart.pie", action: openStatistics)
        }
        .padding(.horizontal, 8)
        .frame(height: 64)
    }

    private func topBarButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(.appLabel)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }

    private func openMenu() {}

    private func openStatistics() {
        showStatistics = true
    }

    private func openHistory() {
        showHistory = true
    }

    private func openCommentInput() {
        FeedbackManager.buttonTapped()
        showCommentInput = true
    }

    private func openBalanceInput() {
        FeedbackManager.buttonTapped()
        showBalanceInput = true
    }

    private func closeBalanceInput() {
        showBalanceInput = false
    }

    private func setBalance(_ amount: Int) {
        balanceAmount = amount
        balanceTimestamp = Date().timeIntervalSinceReferenceDate
    }

    private func addTransaction(with category: TransactionCategory) -> Bool {
        guard input.amount != 0 else {
            amountAttentionTrigger += 1
            FeedbackManager.amountMissing()
            return false
        }

        let transaction = Transaction(
            amount: input.amount,
            category: category,
            date: Date(),
            note: comment.isBlank ? nil : comment
        )

        let previousInput = input
        let previousComment = comment

        modelContext.insert(transaction)
        FeedbackManager.transactionAdded()
        input.reset()
        comment = ""

        UndoToastCenter.shared.show(L10n.transactionsListTransactionAdded) {
            modelContext.delete(transaction)
            try? modelContext.save()
            if input.isEmpty, comment.isBlank {
                input = previousInput
                comment = previousComment
            }
        }
        return true
    }
}

#Preview {
    StartView()
        .modelContainer(makePreviewModelContainer())
}

@MainActor
func makePreviewModelContainer() -> ModelContainer {
    let container = try! ModelContainer(
        for: Transaction.self, TransactionCategory.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    DataSeeder.seedDefaultCategories(container: container)
    return container
}
