//
//  CategoryGrid.swift
//  ExpensesTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct CategoryGrid: View {
    @Query var categories: [TransactionCategory]
    @Binding var input: String
    var onSelect: (TransactionCategory) -> Void
    
    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: gridLayout, spacing: 16) {
                ForEach(categories, id: \.id) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        VStack {
                            Image(systemName: category.icon)
                                .font(.title)
                                .foregroundColor(category.color)
                            Text(category.name)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                        .frame(width: 80)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
