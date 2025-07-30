//
//  CategoriesEdit.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 28.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

struct CategoriesEdit: View {
    @Query private var categories: [TransactionCategory]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddCategory = false
    @State private var showEditCategory = false
    @State private var selectedCategory: TransactionCategory?
    
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
        .navigationTitle("Редактирование категорий")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: gridLayout, spacing: 16) {
            ForEach(categories.filter { $0.isDirectory }, id: \.id) { category in
                SubcategoryCell(category: category) {}
            }
            
            ForEach(categories.filter { !$0.isDirectory }, id: \.id) { category in
                CategoryCell(category: category) {
                    selectedCategory = category
                    showEditCategory = true
                }
            }
        }
    }
}
