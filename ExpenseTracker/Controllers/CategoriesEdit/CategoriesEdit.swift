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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showAddCategory = false
    @State private var showEditCategory = false
    @State private var selectedCategory: TransactionCategory?

    @State private var showAddFolderAlert = false
    @State private var newFolderName: String = ""

    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    }

    var body: some View {
        ScrollView(.vertical) {
            categoryGrid
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
        }
        .background(.appMain)
        .navigationTitle(L10n.categoriesEditTitle)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    newFolderName = ""
                    showAddFolderAlert = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.white)
                }

                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showEditCategory) {
            if let selected = selectedCategory {
                EditCategoryView(category: selected, isEdit: true)
            }
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

    private var categoryGrid: some View {
        LazyVGrid(columns: gridLayout, spacing: 16) {
            ForEach(
                categories
                    .filter { category in
                        category.parent(from: categories) == nil || !(category.parent(from: categories)?.isDirectory ?? false)
                    }
                    .sorted {
                        if $0.isDirectory != $1.isDirectory {
                            return $0.isDirectory
                        }
                        return $0.name < $1.name
                    },
                id: \.id
            ) { category in
                CategoryCell(category: category) {
                    selectedCategory = category
                    showEditCategory = true
                }
            }
        }
    }

    // MARK: - Создание новой папки

    private func createFolderCategory() {
        guard !newFolderName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newFolder = TransactionCategory(
            name: newFolderName,
            categoryIcon: CategoryIcon(name: "folder", iconColor: .yellow),
            isDirectory: true
        )
        modelContext.insert(newFolder)
        try? modelContext.save()
    }
}
