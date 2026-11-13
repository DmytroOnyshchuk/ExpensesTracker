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
    @Query private var categories: [TransactionCategory]
    @Query private var transactions: [Transaction]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showAddCategory = false
    @State private var selectedCategory: TransactionCategory?

    @State private var showAddFolderAlert = false
    @State private var newFolderName: String = ""

    private var orderedCategories: [TransactionCategory] {
        categories.inDisplayOrder
    }

    private var transactionsCounts: [UUID: Int] {
        var counts: [UUID: Int] = [:]
        for transaction in transactions {
            counts[transaction.category.uuid, default: 0] += 1
        }
        return counts
    }

    var body: some View {
        let transactionsCounts = transactionsCounts

        List {
            ForEach(orderedCategories, id: \.id) { category in
                CategoryRow(
                    category: category,
                    subtitle: category.parent(from: categories)?.name.localized,
                    transactionsCount: category.isDirectory ? nil : transactionsCounts[category.uuid] ?? 0
                ) {
                    selectedCategory = category
                }
                .categoryListRow(isLast: category.id == orderedCategories.last?.id)
            }
            .onMove(perform: moveCategories)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.appMain)
        .navigationTitle(L10n.categoriesEditTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    newFolderName = ""
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
            EditCategoryView()
        }
        .alert(L10n.categoriesEditNewFolderAlertTitle, isPresented: $showAddFolderAlert) {
            TextField(L10n.categoriesEditNewFolderAlertMessage, text: $newFolderName)
                .foregroundColor(.black)
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.categoriesEditCreate, role: .none) {
                createFolderCategory()
            }
        } message: {
            Text(L10n.categoriesEditNewFolderAlertMessage)
        }
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        orderedCategories.reorder(fromOffsets: source, toOffset: destination, among: categories)
        try? modelContext.save()
    }

    // MARK: - Creating a new folder

    private func createFolderCategory() {
        guard !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newFolder = TransactionCategory(
            name: .custom(newFolderName),
            categoryIcon: CategoryIcon(name: "folder", iconColor: .yellow),
            isDirectory: true,
            sortIndex: categories.nextSortIndex
        )
        modelContext.insert(newFolder)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        CategoriesEdit()
    }
    .modelContainer(makePreviewModelContainer())
}
