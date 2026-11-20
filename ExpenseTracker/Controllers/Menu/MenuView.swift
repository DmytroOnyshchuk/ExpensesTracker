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
    case categories
    case settings
    case accounting
    case autoPayments
    case backups
    case language
    case about
    case trash

    var id: Self { self }

    var title: String {
        switch self {
        case .categories: L10n.menuCategories
        case .settings: L10n.menuSettings
        case .accounting: L10n.menuAccountingSettings
        case .autoPayments: L10n.menuAutopayments
        case .backups: L10n.menuBackups
        case .language: L10n.menuLanguage
        case .about: L10n.menuAbout
        case .trash: L10n.menuTrash
        }
    }

    var systemImage: String {
        switch self {
        case .categories: "square.grid.2x2"
        case .settings: "slider.horizontal.3"
        case .accounting: "checklist"
        case .autoPayments: "repeat"
        case .backups: "externaldrive"
        case .language: "globe"
        case .about: "info.circle"
        case .trash: "trash"
        }
    }
}

enum MenuSection: CaseIterable, Identifiable {
    case general
    case data
    case app

    var id: Self { self }

    var title: String {
        switch self {
        case .general: L10n.menuSectionGeneral
        case .data: L10n.menuSectionData
        case .app: L10n.menuSectionApp
        }
    }

    var items: [MenuItem] {
        switch self {
        case .general: [.settings, .accounting, .categories, .autoPayments]
        case .data: [.backups, .trash]
        case .app: [.language, .about]
        }
    }
}

enum MenuDestination: Hashable {
    case statistics
    case categories
    case settings
    case accounting
    case autoPayments
    case backups
    case about
    case trash
}

struct MenuView: View {
    var isActive = true

    @State private var destination: MenuDestination?

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.tabStatistics)

                    if isActive {
                        MenuSummary(title: spentTitle, action: openStatistics)
                    } else {
                        MenuSpentCard(title: spentTitle, amount: .zero, balance: nil, action: openStatistics)
                    }
                }

                ForEach(MenuSection.allCases) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        MenuSectionHeader(title: section.title)

                        VStack(spacing: 0) {
                            ForEach(section.items) { item in
                                MenuRow(title: item.title, systemImage: item.systemImage) {
                                    open(item)
                                }

                                if item != section.items.last {
                                    MenuRowDivider()
                                }
                            }
                        }
                        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $destination) { destination in
            switch destination {
            case .statistics: StatisticsView()
            case .categories: CategoriesEdit()
            case .settings: SettingsView()
            case .accounting: AccountingSettingsView()
            case .autoPayments: AutoPaymentsView()
            case .backups: BackupsView()
            case .about: AboutView()
            case .trash: TrashView()
            }
        }
    }

    private var spentTitle: String {
        L10n.menuSpentInMonth(Date().formatted(.dateTime.month(.wide)))
    }

    private func open(_ item: MenuItem) {
        FeedbackManager.shared.buttonTapped()
        switch item {
        case .categories: destination = .categories
        case .settings: destination = .settings
        case .accounting: destination = .accounting
        case .autoPayments: destination = .autoPayments
        case .backups: destination = .backups
        case .language: UIApplication.shared.openSettings()
        case .about: destination = .about
        case .trash: destination = .trash
        }
    }

    private func openStatistics() {
        FeedbackManager.shared.buttonTapped()
        destination = .statistics
    }
}

struct MenuSummary: View {
    let title: String
    let action: () -> Void

    private let start: Date

    @Query private var transactions: [Transaction]
    @Query(filter: Account.notDeleted) private var accounts: [Account]
    @StoredSettings private var appSettings

    init(title: String, action: @escaping () -> Void) {
        let interval = StatisticsPeriod.month.interval(containing: Date())
        self.title = title
        self.action = action
        self.start = interval.start
        _transactions = Query(filter: Transaction.existing(from: interval.start, to: interval.end))
    }

    var body: some View {
        MenuSpentCard(title: title, amount: spentAmount, balance: balance, action: action)
    }

    private var spentAmount: Int {
        transactions.of(.outcome).reduce(0) { $0 + $1.amount }
    }

    private var balance: Int? {
        guard appSettings.accounting.multipleAccountsEnabled, !accounts.isEmpty else { return nil }
        return accounts.enabled.total
    }
}

extension MenuSummary: Equatable {
    nonisolated static func == (lhs: MenuSummary, rhs: MenuSummary) -> Bool { lhs.title == rhs.title && lhs.start == rhs.start }
}

struct MenuSpentCard: View {
    let title: String
    let amount: Int
    let balance: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(amount.getAmount())
                        .font(.appRegular(26))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())

                    if let balance {
                        HStack(spacing: 8) {
                            Text(L10n.startviewBalance)
                                .font(.appLight(14))
                                .foregroundColor(.appLabel)

                            Text(balance.getAmount())
                                .font(.appRegular(14))
                                .foregroundColor(balance < 0 ? .appRed : .appWhite.opacity(0.75))
                                .contentTransition(.numericText())
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), tint: .appPrimary.opacity(0.15), isInteractive: true, fallback: .appPrimary.opacity(0.15))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.appStandard, value: balance)
    }
}

struct MenuSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appMedium(14))
            .foregroundColor(.appLabel)
            .lineLimit(1)
            .padding(.horizontal, 16)
    }
}

struct MenuRowDivider: View {
    var body: some View {
        InsetDivider(leading: 52)
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
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17))
                .foregroundColor(.appPrimary)
                .frame(width: 24)

            Text(title)
                .font(.appLight(16))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appLabel)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
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
