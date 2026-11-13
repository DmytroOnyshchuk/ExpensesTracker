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
    var transactions: [Transaction]

    private static let rowHeight = 64 + 8
    private static let headerHeight = 40
    private static let sectionSpacing = 28

    @State private var contentHeight: CGFloat = 0
    @State private var editedTransaction: Transaction?

    private var days: [TransactionsDay] {
        let calendar = Calendar.current

        return [
            (L10n.transactionsListSpentToday, Date()),
            (L10n.transactionsListSpentYesterday, Date.yesterday),
        ].map { title, day in
            TransactionsDay(
                title: title,
                transactions: transactions.filter { calendar.isDate($0.date, inSameDayAs: day) }
            )
        }
    }

    var body: some View {
        let days = days

        List {
            ForEach(days) { day in
                Section {
                    if day.transactions.isEmpty {
                        Text(L10n.transactionsListNoTransactions)
                            .font(.appLight(18))
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .listRowBackground(Color.appMain)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(day.transactions, id: \.id) { transaction in
                            TransactionRow(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editedTransaction = transaction
                                }
                                .listRowBackground(Color.appMain)
                                .listRowSeparatorTint(.appSecond)
                                .listRowSeparator(
                                    transaction.id == day.transactions.last?.id ? .hidden : .visible,
                                    edges: .bottom
                                )
                        }
                    }
                } header: {
                    TransactionsDayHeader(day: day)
                        .frame(height: Self.headerHeight.asCgFloat)
                        .listRowInsets(EdgeInsets())
                }
            }
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .environment(\.defaultMinListHeaderHeight, 0)
        .background(.appMain)
        .scrollContentBackground(.hidden)
        .background(.appMain)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentSize.height
        } action: { _, height in
            contentHeight = height
        }
        .frame(height: max(contentHeight, estimatedHeight(for: days)), alignment: .top)
        .fullScreenCover(item: $editedTransaction) { transaction in
            TransactionEdit(transaction: transaction)
        }
    }

    private func estimatedHeight(for days: [TransactionsDay]) -> CGFloat {
        let rows = days.reduce(0) { $0 + max($1.transactions.count, 1) }
        return (rows * Self.rowHeight + days.count * (Self.headerHeight + Self.sectionSpacing)).asCgFloat
    }
}

struct TransactionsDay: Identifiable {
    let title: String
    var transactions: [Transaction]

    var id: String { title }

    var total: Int { transactions.reduce(0) { $0 + $1.amount } }

    var topCategoryColor: Color? {
        Dictionary(grouping: transactions) { $0.category.uuid }
            .values
            .max { lhs, rhs in
                lhs.reduce(0) { $0 + $1.amount } < rhs.reduce(0) { $0 + $1.amount }
            }?
            .first?
            .category.categoryIcon.color
    }
}

struct TransactionsDayHeader: View {
    let day: TransactionsDay

    var body: some View {
        let totalColor = day.topCategoryColor

        HStack(spacing: 12) {
            Text(day.title)
                .font(.appLight(16))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Text(day.total.getAmount())
                .font(.appRegular(16))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(totalColor?.opacity(0.45) ?? .appLabel.opacity(0.4))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .textCase(nil)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appSecond)
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

                if let note = transaction.comment, !note.isEmpty {
                    Text(note)
                        .font(.appLight(13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
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

#Preview("Empty list") {
    TransactionsList(transactions: [])
        .frame(height: 220)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}

#Preview("Transactions list") {
    let category = TransactionCategory(name: "Cafe", categoryIcon: CategoryIcon(name: "cup.and.saucer", iconColor: .orange))
    let transactions = [
        Transaction(amount: 36000, category: category, date: .yesterday),
        Transaction(amount: 48100, category: category, date: .yesterday, note: "Lunch with colleagues"),
        Transaction(amount: 125000, category: category),
    ]

    TransactionsList(transactions: transactions)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}

#Preview("Transaction") {
    let category = TransactionCategory(name: "Cafe", categoryIcon: CategoryIcon(name: "cup.and.saucer", iconColor: .orange))
    let transaction = Transaction(amount: 1250, category: category)

    TransactionRow(transaction: transaction)
        .padding(.horizontal)
        .background(.appMain)
        .modelContainer(makePreviewModelContainer())
}
