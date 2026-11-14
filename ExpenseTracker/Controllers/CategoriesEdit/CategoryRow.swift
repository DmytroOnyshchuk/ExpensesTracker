//
//  CategoryRow.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CategoryRow: View {
    enum Accessory {
        case chevron
        case reorder
        case none
    }

    let category: TransactionCategory
    var subtitle: String?
    var transactionsCount: Int?
    var accessory: Accessory = .chevron
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                icon

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name.localized)
                        .font(.appLight(18))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)

                    if let subtitle {
                        Text(subtitle)
                            .font(.appLight(13))
                            .foregroundColor(.appGray)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                if let transactionsCount {
                    Text(String(transactionsCount))
                        .font(.appLight(16))
                        .foregroundColor(.appGray)
                        .lineLimit(1)
                }

                switch accessory {
                case .chevron:
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appWhite.opacity(0.6))
                case .reorder:
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.appWhite.opacity(0.5))
                case .none:
                    EmptyView()
                }
            }
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var icon: some View {
        if category.isDirectory {
            ZStack {
                Image(systemName: "folder.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.appYellow)

                category.categoryIcon.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.appMain)
                    .frame(width: 13, height: 13)
                    .offset(y: 2)
            }
            .frame(width: 32, height: 32)
        } else {
            category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .foregroundColor(category.categoryIcon.color)
                .frame(width: 32, height: 32)
        }
    }
}

extension View {
    func categoryListRow(isLast: Bool) -> some View {
        listRowBackground(Color.appMain)
            .listRowInsets(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
            .listRowSeparatorTint(.appSecond)
            .listRowSeparator(.hidden, edges: .top)
            .listRowSeparator(isLast ? .hidden : .visible, edges: .bottom)
    }
}

#Preview {
    VStack {
        CategoryRow(
            category: TransactionCategory(name: "Fuel", categoryIcon: CategoryIcon(name: "fuelpump", iconColor: .pink)),
            subtitle: "Car",
            action: {}
        )
        CategoryRow(
            category: TransactionCategory(name: "Home", categoryIcon: CategoryIcon(name: "house", iconColor: .yellow), isDirectory: true),
            action: {}
        )
    }
    .padding()
    .background(.appMain)
}
