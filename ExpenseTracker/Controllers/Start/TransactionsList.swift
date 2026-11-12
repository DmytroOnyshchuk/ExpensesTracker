//
//  TransactionsList.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct TransactionsList: View {
    /// Операции в том порядке, в котором их нужно показать.
    var transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.6))

                    Text(L10n.transactionsListNoTransactions)
                        .font(.appLight(18))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 200)
            } else {
                List {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                            .listRowBackground(Color.appMain)
                            .listRowSeparatorTint(Color.appSecond)
                    }
                }
                .scrollDisabled(true)
                .listStyle(.plain)
                .background(Color.appMain)
                .scrollContentBackground(.hidden)
                .background(.appMain)
                .frame(height: (transactions.count * (64 + 8)).asCgFloat, alignment: .top)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 16) {
            transaction.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .foregroundColor(transaction.category.categoryIcon.color)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading) {
                Text(transaction.category.name.localized)
                    .font(.appLight(18))
            }

            Spacer()

            Text(transaction.amount.getAmount())
                .font(.appLight(22))
        }
        .frame(height: 48)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                modelContext.delete(transaction)
                try? modelContext.save()
            } label: {
                Label(L10n.delete, systemImage: "trash")
            }
        }
    }
}

#Preview("Пустой список") {
    TransactionsList(transactions: [])
        .frame(height: 220)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}

#Preview("Список операций") {
    let category = TransactionCategory(name: "Кафе", categoryIcon: CategoryIcon(name: "cup.and.saucer", iconColor: .orange))
    let transaction = Transaction(amount: 1250, category: category)

    TransactionsList(transactions: [transaction])
        .frame(height: 100)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}

#Preview("Операция") {
    let category = TransactionCategory(name: "Кафе", categoryIcon: CategoryIcon(name: "cup.and.saucer", iconColor: .orange))
    let transaction = Transaction(amount: 1250, category: category)

    TransactionRow(transaction: transaction)
        .padding(.horizontal)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}
