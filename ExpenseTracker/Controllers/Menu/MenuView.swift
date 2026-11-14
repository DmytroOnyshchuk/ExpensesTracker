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
    case settings
    case language
    case about

    static let sections: [[MenuItem]] = [[.settings], [.language, .about]]

    var id: Self { self }

    var title: String {
        switch self {
        case .settings: L10n.menuSettings
        case .language: L10n.menuLanguage
        case .about: L10n.menuAbout
        }
    }

    var systemImage: String {
        switch self {
        case .settings: "slider.horizontal.3"
        case .language: "globe"
        case .about: "info.circle"
        }
    }
}

struct MenuView: View {
    @Query private var transactions: [Transaction]

    @State private var showStatistics = false
    @State private var showSettings = false
    @State private var showAbout = false

    private let period = StatisticsPeriod.month

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                MenuSpentCard(title: spentTitle, amount: spentAmount, action: openStatistics)

                ForEach(MenuItem.sections, id: \.self) { section in
                    VStack(spacing: 0) {
                        ForEach(section) { item in
                            MenuRow(title: item.title, systemImage: item.systemImage) {
                                open(item)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                }
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
        .navigationDestination(isPresented: $showAbout) {
            AboutView()
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
        case .settings: showSettings = true
        case .language: UIApplication.shared.openSettings()
        case .about: showAbout = true
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
                    .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .glassSurface(
                in: RoundedRectangle(cornerRadius: 18, style: .continuous),
                tint: .appPrimary.opacity(0.15),
                isInteractive: true,
                fallback: .appPrimary.opacity(0.15)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct MenuRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MenuRowLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

struct MenuRowLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .foregroundColor(.appPrimary)
                .frame(width: 32)

            Text(title)
                .font(.appLight(18))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .contentShape(Rectangle())
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
