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
    @Query(sort: \Transaction.date, order: .reverse, animation: .default) private var transactions: [Transaction]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
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
        .animation(.easeInOut(duration: 0.2), value: showCommentInput)
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
            Text(L10n.historyTitle)
                .font(.appLight(22))
                .foregroundColor(.appBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
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

    private func addTransaction(with category: TransactionCategory) {
        guard input.amount != 0 else {
            amountAttentionTrigger += 1
            FeedbackManager.amountMissing()
            return
        }

        let transaction = Transaction(
            amount: input.amount,
            category: category,
            date: Date(),
            note: comment.isBlank ? nil : comment
        )

        modelContext.insert(transaction)
        FeedbackManager.transactionAdded()
        input.reset()
        comment = ""
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
