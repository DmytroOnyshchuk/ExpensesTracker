//
//  BudgetView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct BudgetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.bifold")
                .font(.system(size: 56))
                .foregroundColor(.appPrimary)

            Text(L10n.menuBudget)
                .font(.appRegular(22))
                .foregroundColor(.appLabel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appMain)
        .navigationTitle(L10n.menuBudget)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BudgetView()
    }
}
