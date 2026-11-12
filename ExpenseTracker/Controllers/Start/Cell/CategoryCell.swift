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
        if category.isDirectory {
            Button(action: action) {
                VStack(spacing: 8) {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .frame(height: 60)

                        category.categoryIcon.image
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.appMain)
                            .frame(width: 24, height: 24)
                            .offset(y: 8)
                    }

                    Text(category.name.localized)
                        .font(.caption)
                        .foregroundColor(.appWhite)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .buttonStyle(.plain)
        } else {
            Button(action: action) {
                VStack {
                    category.categoryIcon.image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(category.categoryIcon.color)
                        .frame(width: 48, height: 56)

                    Spacer(minLength: 8)

                    Text(category.name.localized)
                        .font(.appRegular(12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                }
                .frame(height: 80)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("Category") {
    CategoryCell(
        category: TransactionCategory(name: "Groceries", categoryIcon: CategoryIcon(name: "cart", iconColor: .green)),
        action: {}
    )
    .frame(width: 80, height: 90)
    .padding()
    .background(.appMain)
}

#Preview("Category folder") {
    CategoryCell(
        category: TransactionCategory(name: "Home", categoryIcon: CategoryIcon(name: "house", iconColor: .yellow), isDirectory: true),
        action: {}
    )
    .frame(width: 80, height: 90)
    .padding()
    .background(.appMain)
}
