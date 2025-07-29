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
    @Query var categories: [TransactionCategory]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddCategory = false
    
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
        .sheet(isPresented: $showAddCategory) {
            EditCategoryView()
        }
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: gridLayout, spacing: 16) {
            ForEach(categories, id: \.id) { category in
                NavigationLink(destination: EditCategoryView(category: category)) {
                    CategoryCell(category: category) {}
                }
                .buttonStyle(.plain)
            }
        }
    }
}
