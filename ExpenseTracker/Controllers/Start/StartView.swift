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
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    var body: some View {
        NavigationSplitView {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    DigitPadView(input: $input)
                    CategoryGrid { category in
                        addTransaction(with: category)
                    }

                    TransactionsList(transactions: transactions)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.appMain)
        } detail: {
            Text(L10n.startviewEnterExpense)
        }
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
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
