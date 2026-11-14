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
    @Environment(\.modelContext) private var modelContext
    @State private var openedFolder: TransactionCategory?

    private var visibleCategories: [TransactionCategory] {
        guard let folder else { return categories.topLevel.inDisplayOrder }
        return folder.allSubcategories(from: categories).inDisplayOrder
    }

    var body: some View {
        List {
            ForEach(visibleCategories, id: \.id) { category in
                CategoryRow(category: category, accessory: category.isDirectory ? .chevron : .none) {
                    if category.isDirectory {
                        openedFolder = category
                    } else {
                        onSelect(category)
                    }
                }
                .moveDisabled(category.isDirectory)
                .categoryListRow(isLast: category.id == visibleCategories.last?.id)
            }
            .onMove(perform: moveCategories)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.appMain)
        .navigationTitle(folder?.name.localized ?? L10n.transactionEditCategoriesTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $openedFolder) { folder in
            TransactionCategoryPicker(folder: folder, onSelect: onSelect)
        }
    }

    private func moveCategories(from source: IndexSet, to destination: Int) {
        let foldersCount = visibleCategories.count(where: \.isDirectory)
        visibleCategories.reorder(fromOffsets: source, toOffset: max(destination, foldersCount), among: categories)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        TransactionCategoryPicker(onSelect: { _ in })
    }
    .modelContainer(makePreviewModelContainer())
}
