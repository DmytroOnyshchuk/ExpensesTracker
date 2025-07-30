//
//  CategoryCell.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 30.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CategoryCell: View {
    let category: TransactionCategory
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                category.categoryIcon.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(category.categoryIcon.color)
                    .frame(width: 48, height: 56)
                
                Spacer(minLength: 8)
                
                Text(category.name)
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
