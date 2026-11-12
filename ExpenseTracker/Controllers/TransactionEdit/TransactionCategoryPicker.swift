//
//  TransactionCategoryPicker.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct TransactionCategoryPicker: View {
    var folder: TransactionCategory?
    let onSelect: (TransactionCategory) -> Void

    @Query private var categories: [TransactionCategory]
    @State private var openedFolder: TransactionCategory?
    @State private var showAddCategory = false

    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    }

    private var visibleCategories: [TransactionCategory] {
        guard let folder else { return categories.topLevel.inDisplayOrder }
        return folder.allSubcategories(from: categories).inDisplayOrder
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridLayout, spacing: 16) {
                ForEach(visibleCategories, id: \.id) { category in
                    CategoryCell(category: category) {
                        if category.isDirectory {
                            openedFolder = category
                        } else {
                            onSelect(category)
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
        }
        .background(.appMain)
        .navigationTitle(folder?.name.localized ?? L10n.transactionEditCategoriesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.appWhite)
                }
            }
        }
        .navigationDestination(item: $openedFolder) { folder in
            TransactionCategoryPicker(folder: folder, onSelect: onSelect)
        }
        .sheet(isPresented: $showAddCategory) {
            EditCategoryView()
        }
    }
}

#Preview {
    NavigationStack {
        TransactionCategoryPicker(onSelect: { _ in })
    }
    .modelContainer(makePreviewModelContainer())
}
