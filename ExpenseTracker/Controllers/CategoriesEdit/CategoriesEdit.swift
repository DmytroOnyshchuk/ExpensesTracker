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
    private let operationType: OperationType?

    @Query private var latest: [Transaction]

    init(operationType: OperationType? = nil) {
        var latest = FetchDescriptor<Transaction>(predicate: Transaction.visible, sortBy: [SortDescriptor(\.date, order: .reverse)])
        latest.fetchLimit = 1

        self.operationType = operationType
        _latest = Query(latest)
    }

    var body: some View {
        CategoriesEditCounts(interval: StatisticsPeriod.year.interval(containing: latest.first?.date ?? Date()), operationType: operationType)
    }
}

struct CategoriesEditCounts: View {
    let interval: DateInterval
    let operationType: OperationType?

    @Query private var transactions: [Transaction]

    init(interval: DateInterval, operationType: OperationType?) {
        self.interval = interval
        self.operationType = operationType
        _transactions = Query(filter: Transaction.shown(from: interval.start, to: interval.end))
    }

    var body: some View {
        CategoriesEditContent(operationType: operationType, transactionsCounts: transactions.reduce(into: [:]) { $0[$1.category.uuid, default: .zero] += 1 })
    }
}

extension CategoriesEditCounts: Equatable {
    nonisolated static func == (lhs: CategoriesEditCounts, rhs: CategoriesEditCounts) -> Bool { lhs.interval == rhs.interval && lhs.operationType == rhs.operationType }
}

struct CategoriesEditContent: View {
    let transactionsCounts: [UUID: Int]

    @Query(filter: TransactionCategory.notDeleted) private var storedCategories: [TransactionCategory]

    private var categories: [TransactionCategory] { storedCategories.of(operationType) }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showAddCategory = false
    @State private var selectedCategory: TransactionCategory?

    @State private var showAddFolderAlert = false
    @State private var operationType: OperationType
    @StoredSettings private var appSettings

    private let showsOperationTypePicker: Bool

    init(operationType: OperationType?, transactionsCounts: [UUID: Int]) {
        self.transactionsCounts = transactionsCounts
        self.showsOperationTypePicker = operationType == nil
        _operationType = State(initialValue: operationType ?? .outcome)
    }

    var body: some View {
        Group {
            if showsOperationTypePicker, appSettings.accounting.incomeEnabled {
                VStack(spacing: 0) {
                    SegmentedControl(items: OperationType.allCases, selection: $operationType, title: \.title)
                        .sensoryFeedback(trigger: operationType) { _, _ in FeedbackManager.shared.selectionFeedback }
                        .padding(.horizontal, 64)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

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
        .overlay {
            if showAddFolderAlert {
                TextInputPopup(title: L10n.categoriesEditNewFolderAlertTitle, placeholder: L10n.categoriesEditNewFolderAlertPlaceholder, confirmTitle: L10n.categoriesEditCreate, onCancel: { showAddFolderAlert = false }) { name in
                    createFolderCategory(named: name)
                    showAddFolderAlert = false
                }
                .transition(.opacity)
            }
        }
        .animation(.appStandard, value: showAddFolderAlert)
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

    private func createFolderCategory(named name: String) {
        guard !name.isBlank else { return }

        let newFolder = TransactionCategory(
            name: .custom(name),
            categoryIcon: CategoryIcon(name: "folder", iconColor: .yellow),
            isDirectory: true,
            sortIndex: categories.nextSortIndex,
            operationType: operationType
        )
        modelContext.insert(newFolder)
        try? modelContext.save()
    }
}

extension CategoriesEditContent: Equatable {
    nonisolated static func == (lhs: CategoriesEditContent, rhs: CategoriesEditContent) -> Bool { lhs.showsOperationTypePicker == rhs.showsOperationTypePicker && lhs.transactionsCounts == rhs.transactionsCounts }
}

#Preview {
    NavigationStack {
        CategoriesEdit()
    }
    .modelContainer(makePreviewModelContainer())
}
