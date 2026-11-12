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
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    var body: some View {
        NavigationSplitView {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    DigitPadView(input: $input)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .top) {
                            topBar
                        }
                    CategoryGrid { category in
                        addTransaction(with: category)
                    }

                    TransactionsList(transactions: transactions)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.appMain)
            .navigationDestination(isPresented: $showStatistics) {
                StatisticsView()
            }
        } detail: {
            Text(L10n.startviewEnterExpense)
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

    private func addTransaction(with category: TransactionCategory) {
        guard input.amount != 0 else { return }

        let transaction = Transaction(amount: input.amount, category: category, date: Date())

        modelContext.insert(transaction)
        input.reset()
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
