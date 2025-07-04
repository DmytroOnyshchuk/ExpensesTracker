//
//  TransactionsList.swift
//  ExpensesTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct TransactionsList: View {
    var transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("История расходов")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(transactions, id: \.id) { transaction in
                    TransactionRow(transaction: transaction)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
                Image(systemName: transaction.category.icon)
                    .foregroundColor(transaction.category.color)
                    .frame(width: 30, height: 30)        
            
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.subheadline)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.amount.asString)
                .font(.headline)
        }
    }
}
