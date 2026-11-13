//
//  MenuView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum MenuItem: CaseIterable, Identifiable {
    case budget
    case settings

    var id: Self { self }

    var title: String {
        switch self {
        case .budget: L10n.menuBudget
        case .settings: L10n.menuSettings
        }
    }

    var systemImage: String {
        switch self {
        case .budget: "wallet.bifold"
        case .settings: "slider.horizontal.3"
        }
    }
}

struct MenuView: View {
    @Query private var transactions: [Transaction]

    @State private var showStatistics = false
    @State private var showSettings = false

    private let period = StatisticsPeriod.month

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                MenuSpentCard(title: spentTitle, amount: spentAmount, action: openStatistics)

                VStack(spacing: 0) {
                    ForEach(MenuItem.allCases) { item in
                        MenuRow(item: item) {
                            open(item)
                        }
                    }
                }
                .padding(.vertical, 6)
                .background(.appLabel.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .navigationTitle(L10n.menuTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showStatistics) {
            StatisticsView()
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var spentTitle: String {
        L10n.menuSpentInMonth(Date().formatted(.dateTime.month(.wide)))
    }

    private var spentAmount: Int {
        let interval = period.interval(containing: Date())
        return transactions
            .filter { $0.date >= interval.start && $0.date < interval.end }
            .reduce(0) { $0 + $1.amount }
    }

    private func open(_ item: MenuItem) {
        switch item {
        case .budget: break
        case .settings: showSettings = true
        }
    }

    private func openStatistics() {
        showStatistics = true
    }
}

struct MenuSpentCard: View {
    let title: String
    let amount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.appLight(15))
                        .foregroundColor(.appLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(amount.getAmount())
                        .font(.appRegular(30))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 8)

                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.appBlue)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(.appBlue.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct MenuRow: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 22))
                    .foregroundColor(.appBlue)
                    .frame(width: 32)

                Text(item.title)
                    .font(.appLight(18))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Menu") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(4).enumerated() {
        container.mainContext.insert(Transaction(amount: (index + 1) * 29000, category: category, date: Date()))
    }

    return NavigationStack {
        MenuView()
    }
    .modelContainer(container)
}

#Preview("Empty menu") {
    NavigationStack {
        MenuView()
    }
    .modelContainer(makePreviewModelContainer())
}
