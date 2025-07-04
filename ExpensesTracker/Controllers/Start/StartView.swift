//
//  ExpenseList.swift
//  ExpensesTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

struct StartView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var input: String = String()
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationSplitView {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    Text(formattedTotal())
                        .font(.headline)
                    
                    DigitPadView(input: $input)
                    
                    CategoryGrid(input: $input) { category in
                        addTransaction(with: category)
                    }
                    
                    if !transactions.isEmpty {
                        TransactionsList(transactions: transactions)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color.gray)
        } detail: {
            Text("Введите расход")
        }
    }
    
    private func formattedTotal() -> String {
        return input.isEmpty ? "Введите расход" : input
    }
    
    private func addTransaction(with category: TransactionCategory) {
        guard !input.isEmpty, let amount = Double(input), amount != 0.0 else { return }
        
        let transaction = Transaction(amount: amount, category: category, date: Date())
        
        modelContext.insert(transaction)
        input = String()
    }
}

#Preview {
    StartView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
