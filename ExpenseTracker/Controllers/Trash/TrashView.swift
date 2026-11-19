//
//  TrashView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import RealmSwift
import SwiftUI

struct TrashView: View {
    private enum Target {
        case account(Account)
        case category(TransactionCategory)
        case autoPayment(AutoPayment)
        case transaction(Transaction)

        var restoreConfirmation: String {
            switch self {
            case .account: L10n.trashRestoreAccountConfirmation
            case .category: L10n.trashRestoreCategoryConfirmation
            case .autoPayment: L10n.trashRestoreAutopaymentConfirmation
            case .transaction: L10n.trashRestoreTransactionConfirmation
            }
        }

        var deleteConfirmation: String {
            switch self {
            case .account: L10n.trashDeleteAccountConfirmation
            case .category: L10n.trashDeleteCategoryConfirmation
            case .autoPayment: L10n.trashDeleteAutopaymentConfirmation
            case .transaction: L10n.transactionEditDeleteConfirmation
            }
        }
    }

    @Environment(\.realm) private var realm

    @ObservedResults(Account.self, where: Account.inTrash, sortDescriptor: RealmSwift.SortDescriptor(keyPath: "deletedAt", ascending: false)) private var accounts
    @ObservedResults(TransactionCategory.self, where: TransactionCategory.inTrash, sortDescriptor: RealmSwift.SortDescriptor(keyPath: "deletedAt", ascending: false)) private var categories
    @ObservedResults(AutoPayment.self, where: AutoPayment.inTrash, sortDescriptor: RealmSwift.SortDescriptor(keyPath: "deletedAt", ascending: false)) private var autoPayments
    @ObservedResults(Transaction.self, where: Transaction.inTrash, sortDescriptor: RealmSwift.SortDescriptor(keyPath: "deletedAt", ascending: false)) private var transactions

    @State private var showClearConfirmation = false
    @State private var restoreTarget: Target?
    @State private var restoreConfirmation = String()
    @State private var deleteTarget: Target?
    @State private var deleteConfirmation = String()

    var body: some View {
        let accounts = Array(accounts)
        let categories = Array(categories)
        let transactions = Array(transactions)
        let visibleTransactions = transactions.filter { $0.category.deletedAt == nil && $0.account?.deletedAt == nil }
        let transactionsCounts = transactions.reduce(into: [UUID: Int]()) { $0[$1.category.uuid, default: 0] += 1 }
        let accountTransactionsCounts = transactions.reduce(into: [UUID: Int]()) { counts, transaction in
            guard let uuid = transaction.account?.uuid else { return }
            counts[uuid, default: 0] += 1
        }
        let visibleAutoPayments = Array(autoPayments).filter { $0.category?.deletedAt == nil && $0.account?.deletedAt == nil }
        let isEmpty = accounts.isEmpty && categories.isEmpty && visibleAutoPayments.isEmpty && visibleTransactions.isEmpty
        let itemsCount: Int = accounts.count + categories.count + visibleAutoPayments.count + transactions.count

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
                    .frame(minHeight: 64)
                    .trashRow(isLast: account.uuid == accounts.last?.uuid && categories.isEmpty && visibleAutoPayments.isEmpty && visibleTransactions.isEmpty) {
                        askToDelete(.account(account))
                    }
                }

                ForEach(categories, id: \.id) { category in
                    let count: Int = transactionsCounts[category.uuid] ?? 0
                    let subtitle: String? = category.isDirectory ? nil : L10n.backupsTransactionsCount(count)

                    CategoryRow(
                        category: category,
                        subtitle: subtitle,
                        accessory: .none,
                        action: { askToRestore(.category(category)) }
                    )
                    .padding(.horizontal, 16)
                    .frame(minHeight: 64)
                    .trashRow(isLast: category.id == categories.last?.id && visibleAutoPayments.isEmpty && visibleTransactions.isEmpty) {
                        askToDelete(.category(category))
                    }
                }

                ForEach(visibleAutoPayments, id: \.uuid) { autoPayment in
                    AutoPaymentRow(autoPayment: autoPayment) {
                        askToRestore(.autoPayment(autoPayment))
                    }
                    .frame(minHeight: 64)
                    .trashRow(isLast: autoPayment.uuid == visibleAutoPayments.last?.uuid && visibleTransactions.isEmpty) {
                        askToDelete(.autoPayment(autoPayment))
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
        .animation(.appStandard, value: itemsCount)
        .alert(L10n.menuTrash, isPresented: $showClearConfirmation) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.clear, role: .destructive) {
                realm.emptyTrash()
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
                withAnimation(.appStandard) {
                    switch target {
                    case .account(let account): realm.restore(account)
                    case .category(let category): realm.restore(category)
                    case .autoPayment(let autoPayment): realm.restore(autoPayment)
                    case .transaction(let transaction): realm.restore(transaction)
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
                withAnimation(.appStandard) {
                    switch target {
                    case .account(let account): realm.deletePermanently(account)
                    case .category(let category): realm.deletePermanently(category)
                    case .autoPayment(let autoPayment): realm.deletePermanently(autoPayment)
                    case .transaction(let transaction): realm.deletePermanently(transaction)
                    }
                }
            }
        } message: { _ in
            Text(L10n.trashDeleteMessage)
        }
    }
}

extension TrashView: Equatable {
    nonisolated static func == (lhs: TrashView, rhs: TrashView) -> Bool { true }
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
    let realm = makePreviewRealm()
    let categories = Array(realm.objects(TransactionCategory.self)).filter { !$0.isDirectory }
    for (index, category) in categories.prefix(5).enumerated() {
        let transaction = Transaction(amount: (index + 1) * 36000, category: category)
        realm.update { realm.add(transaction) }
        if index < 3 {
            realm.moveToTrash(transaction)
        }
    }
    if let category = categories.dropFirst(4).first {
        realm.moveToTrash(category)
    }

    return NavigationStack {
        TrashView()
    }
    .environment(\.realmConfiguration, realm.configuration)
}

#Preview("Empty trash") {
    NavigationStack {
        TrashView()
    }
    .environment(\.realmConfiguration, makePreviewRealm().configuration)
}
