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
    private enum Target {
        case account(Account)
        case category(TransactionCategory)
        case transaction(Transaction)

        var restoreConfirmation: String {
            switch self {
            case .account: L10n.trashRestoreAccountConfirmation
            case .category: L10n.trashRestoreCategoryConfirmation
            case .transaction: L10n.trashRestoreTransactionConfirmation
            }
        }

        var deleteConfirmation: String {
            switch self {
            case .account: L10n.trashDeleteAccountConfirmation
            case .category: L10n.trashDeleteCategoryConfirmation
            case .transaction: L10n.transactionEditDeleteConfirmation
            }
        }
    }

    @Environment(\.modelContext) private var modelContext

    @Query private var storedAccounts: [Account]
    @Query private var storedCategories: [TransactionCategory]
    @Query private var storedTransactions: [Transaction]

    @State private var showClearConfirmation = false
    @State private var restoreTarget: Target?
    @State private var restoreConfirmation = String()
    @State private var deleteTarget: Target?
    @State private var deleteConfirmation = String()

    private var accounts: [Account] {
        storedAccounts.inTrash.sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    private var categories: [TransactionCategory] {
        storedCategories.inTrash.sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    var body: some View {
        let accounts = accounts
        let categories = categories
        let transactions = storedTransactions.inTrash
        let visibleTransactions = transactions
            .filter { $0.category.deletedAt == nil && $0.account?.deletedAt == nil }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
        let transactionsCounts = transactions.reduce(into: [UUID: Int]()) { $0[$1.category.uuid, default: 0] += 1 }
        let accountTransactionsCounts = transactions.reduce(into: [UUID: Int]()) { counts, transaction in
            guard let uuid = transaction.account?.uuid else { return }
            counts[uuid, default: 0] += 1
        }
        let isEmpty = accounts.isEmpty && categories.isEmpty && visibleTransactions.isEmpty

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
                ForEach(accounts, id: \.uuid) { account in
                    TrashAccountRow(name: account.name, subtitle: L10n.backupsTransactionsCount(accountTransactionsCounts[account.uuid] ?? .zero)) {
                        askToRestore(.account(account))
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: 68)
                    .trashRow(isLast: account.uuid == accounts.last?.uuid && categories.isEmpty && visibleTransactions.isEmpty) {
                        askToDelete(.account(account))
                    }
                }

                ForEach(categories, id: \.id) { category in
                    CategoryRow(
                        category: category,
                        subtitle: category.isDirectory ? nil : L10n.backupsTransactionsCount(transactionsCounts[category.uuid] ?? .zero),
                        accessory: .none,
                        action: { askToRestore(.category(category)) }
                    )
                    .padding(.horizontal, 16)
                    .frame(minHeight: 68)
                    .trashRow(isLast: category.id == categories.last?.id && visibleTransactions.isEmpty) {
                        askToDelete(.category(category))
                    }
                }

                ForEach(visibleTransactions, id: \.id) { transaction in
                    TransactionDetailsRow(transaction: transaction)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            askToRestore(.transaction(transaction))
                        }
                        .trashRow(isLast: transaction.id == visibleTransactions.last?.id) {
                            askToDelete(.transaction(transaction))
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
        .alert(
            restoreConfirmation,
            isPresented: Binding(
                get: { restoreTarget != nil },
                set: { if !$0 { restoreTarget = nil } }
            ),
            presenting: restoreTarget
        ) { target in
            Button(L10n.yes) {
                withAnimation {
                    switch target {
                    case .account(let account): modelContext.restore(account)
                    case .category(let category): modelContext.restore(category)
                    case .transaction(let transaction): modelContext.restore(transaction)
                    }
                }
            }
            Button(L10n.no, role: .cancel) {}
        }
        .alert(
            deleteConfirmation,
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            ),
            presenting: deleteTarget
        ) { target in
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.delete, role: .destructive) {
                withAnimation {
                    switch target {
                    case .account(let account): modelContext.deletePermanently(account)
                    case .category(let category): modelContext.deletePermanently(category)
                    case .transaction(let transaction): modelContext.deletePermanently(transaction)
                    }
                }
            }
        } message: { _ in
            Text(L10n.trashDeleteMessage)
        }
    }
}

extension TrashView {
    private func askToRestore(_ target: Target) {
        restoreConfirmation = target.restoreConfirmation
        restoreTarget = target
    }

    private func askToDelete(_ target: Target) {
        deleteConfirmation = target.deleteConfirmation
        deleteTarget = target
    }
}

private struct TrashAccountRow: View {
    let name: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: "wallet.bifold")
                    .font(.system(size: 20))
                    .foregroundColor(.appLabel)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.appLight(18))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.appLight(13))
                        .foregroundColor(.appGray)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension View {
    fileprivate func trashRow(isLast: Bool, onDelete: @escaping () -> Void) -> some View {
        swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: onDelete) {
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
