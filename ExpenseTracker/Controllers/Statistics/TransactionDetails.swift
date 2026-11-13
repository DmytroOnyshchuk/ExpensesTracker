//
//  TransactionDetails.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum TransactionsSorting: CaseIterable {
    case date
    case amount

    var title: String {
        switch self {
        case .date: L10n.transactionDetailsSortByDate
        case .amount: L10n.transactionDetailsSortByAmount
        }
    }

    func sorted(_ transactions: [Transaction]) -> [Transaction] {
        transactions.sorted {
            switch self {
            case .date:
                $0.date > $1.date
            case .amount:
                $0.amount != $1.amount ? $0.amount > $1.amount : $0.date > $1.date
            }
        }
    }
}

struct TransactionDetails: View {
    let category: TransactionCategory
    let interval: DateInterval

    @Environment(\.modelContext) private var modelContext

    @Query(animation: .default) private var transactions: [Transaction]
    @State private var sorting: TransactionsSorting = .date
    @State private var editedTransaction: Transaction?

    private var visibleTransactions: [Transaction] {
        let categoryUuid = category.uuid

        return sorting.sorted(
            transactions.filter {
                $0.category.uuid == categoryUuid && $0.date >= interval.start && $0.date < interval.end
            }
        )
    }

    var body: some View {
        let visibleTransactions = visibleTransactions

        List {
            SegmentedControl(items: TransactionsSorting.allCases, selection: $sorting, title: \.title)
                .padding(.horizontal, 80)
                .padding(.vertical, 16)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.appMain)
                .listRowSeparator(.hidden)

            if visibleTransactions.isEmpty {
                Text(L10n.transactionsListNoTransactions)
                    .font(.appLight(18))
                    .foregroundColor(.gray.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.appMain)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(visibleTransactions, id: \.id) { transaction in
                    TransactionDetailsRow(transaction: transaction)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editedTransaction = transaction
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(transaction)
                            } label: {
                                Label(L10n.delete, systemImage: "trash")
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.appMain)
                        .listRowSeparatorTint(.appSecond)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowSeparator(
                            transaction.id == visibleTransactions.last?.id ? .hidden : .visible,
                            edges: .bottom
                        )
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 64 }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.appMain)
        .navigationTitle(category.name.localized)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $editedTransaction) { transaction in
            TransactionEdit(transaction: transaction)
        }
    }

    private func delete(_ transaction: Transaction) {
        modelContext.deleteWithUndo(transaction)
    }
}

struct TransactionDetailsRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 16) {
            transaction.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .foregroundColor(transaction.category.categoryIcon.color)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name.localized)
                    .font(.appLight(16))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)

                if let comment = transaction.comment, !comment.isBlank {
                    Text(comment)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.amount.getAmount())
                    .font(.appLight(20))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)

                Text(transaction.date.dayString(.dateTime.day().month(.wide)))
                    .font(.appLight(13))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 68)
    }
}

#Preview("Transaction details") {
    let container = makePreviewModelContainer()
    let category = TransactionCategory(name: "Taxes", categoryIcon: CategoryIcon(name: "dollarsign.circle.fill", iconColor: .yellow))
    container.mainContext.insert(category)
    container.mainContext.insert(Transaction(amount: 151906, category: category, note: "Military tax, October"))
    container.mainContext.insert(Transaction(amount: 759530, category: category, date: .yesterday, note: "Single tax, October"))
    container.mainContext.insert(Transaction(amount: 190234, category: category))

    return NavigationStack {
        TransactionDetails(
            category: category,
            interval: StatisticsPeriod.month.interval(containing: Date())
        )
    }
    .modelContainer(container)
}

#Preview("Transaction details row") {
    let category = TransactionCategory(name: "Taxes", categoryIcon: CategoryIcon(name: "dollarsign.circle.fill", iconColor: .yellow))

    TransactionDetailsRow(transaction: Transaction(amount: 151906, category: category, note: "Military tax, October"))
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}
