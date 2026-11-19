//
//  CategoriesEdit.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 28.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct CategoriesEdit: View {
    @Query(filter: TransactionCategory.notDeleted) private var storedCategories: [TransactionCategory]
    @Query(filter: Transaction.visible) private var transactions: [Transaction]

    private var categories: [TransactionCategory] { storedCategories.of(operationType) }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showAddCategory = false
    @State private var selectedCategory: TransactionCategory?

    @State private var showAddFolderAlert = false
    @State private var newFolderName: String = String()
    @State private var operationType: OperationType
    @StoredSettings private var appSettings

    private let showsOperationTypePicker: Bool

    init(operationType: OperationType? = nil) {
        _operationType = State(initialValue: operationType ?? .outcome)
        self.showsOperationTypePicker = operationType == nil
    }

    private var transactionsCounts: [UUID: Int] {
        let transactions = transactions
        let period = StatisticsPeriod.year
        let interval = period.interval(containing: period.starts(of: transactions).first ?? Date())

        var counts: [UUID: Int] = [:]
        for transaction in transactions where transaction.date >= interval.start && transaction.date < interval.end {
            counts[transaction.category.uuid, default: 0] += 1
        }
        return counts
    }

    var body: some View {
        let transactionsCounts = transactionsCounts

        Group {
            if showsOperationTypePicker, appSettings.accounting.incomeEnabled {
                VStack(spacing: 0) {
                    SegmentedControl(items: OperationType.allCases, selection: $operationType, title: \.title)
                        .sensoryFeedback(trigger: operationType) { _, _ in FeedbackManager.shared.selectionFeedback }
                        .padding(.horizontal, 56)
                        .padding(.vertical, 8)

                    PeriodPager(count: OperationType.allCases.count, selection: pageSelection) { index in
                        categoriesList(of: OperationType.allCases[index], transactionsCounts: transactionsCounts)
                    }
                }
            } else {
                categoriesList(of: operationType, transactionsCounts: transactionsCounts)
            }
        }
        .appBackground()
        .navigationTitle(L10n.categoriesEditTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    newFolderName = String()
                    showAddFolderAlert = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.appWhite)
                }

                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.appWhite)
                }
            }
        }
        .sheet(item: $selectedCategory) { category in
            EditCategoryView(category: category)
        }
        .sheet(isPresented: $showAddCategory) {
            EditCategoryView(operationType: operationType)
        }
        .alert(L10n.categoriesEditNewFolderAlertTitle, isPresented: $showAddFolderAlert) {
            TextField(L10n.categoriesEditNewFolderAlertPlaceholder, text: $newFolderName)
                .foregroundColor(.black)
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.categoriesEditCreate, role: .none) {
                createFolderCategory()
            }
        }
    }

    private var pageSelection: Binding<Int> {
        Binding(
            get: { OperationType.allCases.firstIndex(of: operationType) ?? .zero },
            set: { operationType = OperationType.allCases[$0] }
        )
    }

    private func categoriesList(of type: OperationType, transactionsCounts: [UUID: Int]) -> some View {
        let categories = storedCategories.of(type)
        let orderedCategories = categories.inDisplayOrder

        return List {
            ForEach(orderedCategories, id: \.id) { category in
                CategoryRow(
                    category: category,
                    subtitle: category.parent(from: categories)?.name.localized,
                    transactionsCount: category.isDirectory ? nil : transactionsCounts[category.uuid] ?? .zero,
                    accessory: category.isDirectory ? .none : .reorder
                ) {
                    selectedCategory = category
                }
                .moveDisabled(category.isDirectory)
                .categoryListRow(isLast: category.id == orderedCategories.last?.id)
            }
            .onMove { source, destination in
                moveCategories(orderedCategories, from: source, to: destination, among: categories)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func moveCategories(_ orderedCategories: [TransactionCategory], from source: IndexSet, to destination: Int, among categories: [TransactionCategory]) {
        let foldersCount = orderedCategories.count(where: \.isDirectory)
        orderedCategories.reorder(fromOffsets: source, toOffset: max(destination, foldersCount), among: categories)
        try? modelContext.save()
    }

    // MARK: - Creating a new folder

    private func createFolderCategory() {
        guard !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newFolder = TransactionCategory(
            name: .custom(newFolderName),
            categoryIcon: CategoryIcon(name: "folder", iconColor: .yellow),
            isDirectory: true,
            sortIndex: categories.nextSortIndex,
            operationType: operationType
        )
        modelContext.insert(newFolder)
        try? modelContext.save()
    }
}

extension CategoriesEdit: Equatable {
    nonisolated static func == (lhs: CategoriesEdit, rhs: CategoriesEdit) -> Bool { lhs.showsOperationTypePicker == rhs.showsOperationTypePicker }
}

#Preview {
    NavigationStack {
        CategoriesEdit()
    }
    .modelContainer(makePreviewModelContainer())
}
