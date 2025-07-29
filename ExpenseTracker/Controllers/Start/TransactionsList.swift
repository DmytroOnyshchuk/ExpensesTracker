//
//  TransactionsList.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

struct TransactionsList: View {
    var transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Нет операций")
                        .font(.appLight(18))
                        .foregroundColor(.gray.opacity(0.6))
        
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 200)
            } else {
                List {
                    ForEach(transactions.sorted(by: { $0.date > $1.date }), id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                            .listRowBackground(Color.appMain)
                            .listRowSeparatorTint(Color.appSecond)
                    }
                }
                .scrollDisabled(true)
                .listStyle(.plain)
                .background(Color.appMain)
                .scrollContentBackground(.hidden)
                .background(.appMain)
                .frame(height: (transactions.count * (64 + 8)).asCgFloat, alignment: .top)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 16) {
            transaction.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .foregroundColor(transaction.category.categoryIcon.color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.appLight(18))
            }
            
            Spacer()
            
            Text(transaction.amount.getAmount())
                .font(.appLight(22))
        }
        .frame(height: 48)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                modelContext.delete(transaction)
                try? modelContext.save()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
