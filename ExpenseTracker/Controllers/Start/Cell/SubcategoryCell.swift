//
//  SubcategoryCell.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 30.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct SubcategoryCell: View {
    let category: TransactionCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
                
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .buttonStyle(.plain)
    }
}
