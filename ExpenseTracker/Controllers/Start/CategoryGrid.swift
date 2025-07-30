//
//  CategoryGrid.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

struct CategoryGrid: View {
    @Query(filter: #Predicate<TransactionCategory> { $0.parent == nil })
    var categories: [TransactionCategory]
    var onSelect: (TransactionCategory) -> Void
    
    @State private var currentPage: Int = 0
    @State private var showAllCategories = false
    @State private var navigateToEditCategories = false
    
    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    }
    
    private var chunkedCategories: [[TransactionCategory]] {
        
        let chunks = categories.chunked(into: 8)
        
        return chunks.enumerated().map { index, chunk in
            if index == chunks.count - 1 {
                return chunk
            }
            return chunk
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentPage) {
                ForEach(0..<chunkedCategories.count, id: \.self) { pageIndex in
                    VStack(alignment: .center, spacing: 0) {
                        LazyVGrid(columns: gridLayout, spacing: 16) {
                            ForEach(chunkedCategories[pageIndex], id: \.id) { category in
                                CategoryCell(category: category) {
                                    onSelect(category)
                                }
                            }
                            
                            if pageIndex == chunkedCategories.count - 1 {
                                EditCategoriesCell {
                                    showAllCategories = true
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .tag(pageIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 176)
            
            if chunkedCategories.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<chunkedCategories.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage = index
                                }
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
        .navigationDestination(isPresented: $showAllCategories) {
            CategoriesEdit()
        }
    }
}

struct EditCategoriesCell: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "square.grid.2x2")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(IconColor.yellow.color)
                    .frame(width: 48, height: 56)
                
                Spacer(minLength: 8)
                
                Text("Все категории")
                    .font(.appRegular(12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(height: 80)
        }
        .buttonStyle(.plain)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
