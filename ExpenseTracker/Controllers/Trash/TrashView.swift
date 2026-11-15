//
//  TrashView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct TrashView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var storedCategories: [TransactionCategory]
    @Query private var storedTransactions: [Transaction]

    @State private var showClearConfirmation = false

    private var categories: [TransactionCategory] {
        storedCategories.inTrash.sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    var body: some View {
        let categories = categories
        let transactions = storedTransactions.inTrash
        let visibleTransactions = transactions
            .filter { $0.category.deletedAt == nil }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
        let transactionsCounts = transactions.reduce(into: [UUID: Int]()) { $0[$1.category.uuid, default: 0] += 1 }
        let isEmpty = categories.isEmpty && visibleTransactions.isEmpty

        List {
            if isEmpty {
                Text(L10n.trashEmpty)
                    .font(.appLight(18))
                    .foregroundColor(.appGray.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(categories, id: \.id) { category in
                    CategoryRow(
                        category: category,
                        subtitle: category.isDirectory ? nil : L10n.backupsTransactionsCount(transactionsCounts[category.uuid] ?? .zero),
                        accessory: .none,
                        action: {}
                    )
                    .padding(.horizontal, 16)
                    .frame(minHeight: 68)
                    .trashRow(isLast: category.id == categories.last?.id && visibleTransactions.isEmpty) {
                        withAnimation { modelContext.restore(category) }
                    } onDelete: {
                        withAnimation { modelContext.deletePermanently(category) }
                    }
                }

                ForEach(visibleTransactions, id: \.id) { transaction in
                    TransactionDetailsRow(transaction: transaction)
                        .trashRow(isLast: transaction.id == visibleTransactions.last?.id) {
                            withAnimation { modelContext.restore(transaction) }
                        } onDelete: {
                            withAnimation { modelContext.deletePermanently(transaction) }
                        }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle(L10n.menuTrash)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(L10n.clear) {
                    showClearConfirmation = true
                }
                .foregroundColor(.appWhite.opacity(isEmpty ? 0.4 : 1))
                .disabled(isEmpty)
            }
        }
        .alert(L10n.menuTrash, isPresented: $showClearConfirmation) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.clear, role: .destructive) {
                modelContext.emptyTrash()
            }
        } message: {
            Text(L10n.trashClearConfirmation)
        }
    }
}

extension View {
    fileprivate func trashRow(isLast: Bool, onRestore: @escaping () -> Void, onDelete: @escaping () -> Void) -> some View {
        swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onRestore) {
                Label(L10n.trashRestore, systemImage: "arrow.uturn.backward")
            }
            .tint(.appPrimary)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label(L10n.delete, systemImage: "trash")
            }
            .tint(.appRed)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in 64 }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(.appSecond)
        .listRowSeparator(.hidden, edges: .top)
        .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
    }
}

#Preview("Trash") {
    let container = makePreviewModelContainer()
    let categories = ((try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []).filter { !$0.isDirectory }
    for (index, category) in categories.prefix(5).enumerated() {
        let transaction = Transaction(amount: (index + 1) * 36000, category: category)
        container.mainContext.insert(transaction)
        if index < 3 {
            container.mainContext.moveToTrash(transaction)
        }
    }
    if let category = categories.dropFirst(4).first {
        container.mainContext.moveToTrash(category)
    }

    return NavigationStack {
        TrashView()
    }
    .modelContainer(container)
}

#Preview("Empty trash") {
    NavigationStack {
        TrashView()
    }
    .modelContainer(makePreviewModelContainer())
}
