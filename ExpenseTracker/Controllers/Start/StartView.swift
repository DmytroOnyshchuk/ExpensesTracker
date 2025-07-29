//
//  ExpenseList.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

struct StartView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var inputAmount: Int = 0
    @Query private var transactions: [Transaction]
    
    var body: some View {
        NavigationSplitView {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    DigitPadView(inputAmount: $inputAmount)
                    CategoryGrid() { category in
                        addTransaction(with: category)
                    }
                    
                    TransactionsList(transactions: transactions)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.appMain)
        } detail: {
            Text("Введите расход")
        }
    }
    
    private func addTransaction(with category: TransactionCategory) {
        guard inputAmount != 0 else { return }
        
        let transaction = Transaction(amount: inputAmount, category: category, date: Date())
        
        modelContext.insert(transaction)
        inputAmount = 0
    }
}

#Preview {
    StartView()
        .modelContainer(for: [Transaction.self, TransactionCategory.self], inMemory: true)
}
