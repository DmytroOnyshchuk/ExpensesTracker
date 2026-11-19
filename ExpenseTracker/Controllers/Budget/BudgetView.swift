//
//  BudgetView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum BudgetTarget: Identifiable {
    case month
    case category(TransactionCategory)

    var id: String {
        switch self {
        case .month: "month"
        case let .category(category): category.uuid.uuidString
        }
    }

    var title: String {
        switch self {
        case .month: L10n.budgetForMonth
        case let .category(category): L10n.budgetForCategory(category.name.localized)
        }
    }
}

struct BudgetView: View {
    var resetToken: Int = .zero

    @Environment(\.modelContext) private var modelContext

    @Query(filter: Transaction.visible) private var storedTransactions: [Transaction]
    @Query(filter: TransactionCategory.nonDirectories) private var storedCategories: [TransactionCategory]
    @AppStorage(UDKey.budget.rawValue, store: UserDefaults.shared) private var budgetData: Data?

    @State private var target: BudgetTarget?

    var body: some View {
        let categories = storedCategories.of(.outcome).inDisplayOrder

        NavigationStack {
            BudgetPager(
                resetToken: resetToken,
                buckets: StatisticsBuckets(period: .month, transactions: storedTransactions.of(.outcome)),
                limited: categories.filter { $0.budget > .zero },
                unlimited: categories.filter { $0.budget <= .zero },
                monthlyLimit: monthlyLimit,
                onOpen: open
            )
            .appBackground()
            .navigationTitle(L10n.menuBudget)
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if let target {
                BalanceInputPopup(
                    title: target.title,
                    balance: limit(for: target),
                    allowsEmpty: true,
                    onRemove: limit(for: target) > .zero ? { remove(target) } : nil,
                    onCancel: close
                ) { amount in
                    setLimit(amount, for: target)
                    close()
                }
                .id(target.id)
                .transition(.opacity)
            }
        }
        .animation(.appStandard, value: target?.id)
    }

    private var monthlyLimit: Int {
        Budget(jsonData: budgetData)?.monthly ?? .zero
    }

    private func limit(for target: BudgetTarget) -> Int {
        switch target {
        case .month: monthlyLimit
        case let .category(category): category.budget
        }
    }

    private func setLimit(_ amount: Int, for target: BudgetTarget) {
        withAnimation(.appStandard) {
            switch target {
            case .month:
                var budget = Budget()
                budget.setMonthly(amount)
                budgetData = budget.jsonData()
            case let .category(category):
                category.budget = amount
                try? modelContext.save()
            }
        }
    }

    private func remove(_ target: BudgetTarget) {
        setLimit(.zero, for: target)
        close()
    }

    private func open(_ target: BudgetTarget) {
        FeedbackManager.shared.buttonTapped()
        self.target = target
    }

    private func close() {
        target = nil
    }
}

struct BudgetPager: View {
    let resetToken: Int
    let buckets: StatisticsBuckets
    let limited: [TransactionCategory]
    let unlimited: [TransactionCategory]
    let monthlyLimit: Int
    let onOpen: (BudgetTarget) -> Void

    @State private var selectedMonth = Date()
    @State private var showUnlimited = false

    var body: some View {
        let month = buckets.clamped(selectedMonth)
        let index = buckets.index(of: month)

        VStack(spacing: 0) {
            monthHeader(month: month, index: index)

            BudgetMonthPage(month: month, transactions: buckets.transactions(at: month), limited: limited, unlimited: unlimited, monthlyLimit: monthlyLimit, showUnlimited: $showUnlimited, onOpen: onOpen)
        }
        .onChange(of: resetToken) {
            selectedMonth = Date()
        }
    }

    private func monthHeader(month: Date, index: Int) -> some View {
        Text(StatisticsPeriod.month.title(for: month))
            .font(.appRegular(22))
            .foregroundColor(.appPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .contentTransition(.opacity)
            .animation(.appStandard, value: month)
            .padding(.horizontal, 64)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .overlay {
                HStack {
                    monthArrow(systemImage: "chevron.left", target: index - 1)
                    Spacer()
                    monthArrow(systemImage: "chevron.right", target: index + 1)
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
    }

    private func monthArrow(systemImage: String, target: Int) -> some View {
        PeriodArrowButton(systemImage: systemImage, isEnabled: target >= .zero && target < buckets.count) {
            FeedbackManager.shared.selectionChanged()
            selectedMonth = buckets.start(at: target)
        }
    }
}

struct BudgetMonthPage: View {
    let month: Date
    let transactions: [Transaction]
    let limited: [TransactionCategory]
    let unlimited: [TransactionCategory]
    let monthlyLimit: Int
    @Binding var showUnlimited: Bool
    let onOpen: (BudgetTarget) -> Void

    private static let collapsedCount = 3

    var body: some View {
        let spent = spentByCategory

        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                MonthBudgetCard(spent: transactions.reduce(0) { $0 + $1.amount }, limit: monthlyLimit) {
                    onOpen(.month)
                }

                if !limited.isEmpty {
                    BudgetSection(leadingTitle: L10n.menuCategories, trailingTitle: L10n.menuBudget) {
                        ForEach(limited, id: \.uuid) { category in
                            CategoryBudgetRow(category: category, spent: spent[category.uuid] ?? .zero) {
                                onOpen(.category(category))
                            }
                        }
                    }
                }

                if !unlimited.isEmpty {
                    let visible = visibleUnlimited

                    if !visible.isEmpty {
                        BudgetSection(leadingTitle: L10n.budgetNoLimit, trailingTitle: nil) {
                            ForEach(visible, id: \.uuid) { category in
                                UnsetCategoryBudgetRow(category: category, spent: spent[category.uuid] ?? .zero) {
                                    onOpen(.category(category))
                                }
                                .transition(.opacity)
                            }
                        }
                        .transition(.opacity)
                    }

                    if !showUnlimited, !limited.isEmpty || unlimited.count > Self.collapsedCount {
                        unlimitedToggle
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private var visibleUnlimited: [TransactionCategory] {
        if showUnlimited { return unlimited }
        return limited.isEmpty ? Array(unlimited.prefix(Self.collapsedCount)) : []
    }

    private var spentByCategory: [UUID: Int] {
        transactions.reduce(into: [:]) { result, transaction in
            result[transaction.category.uuid, default: .zero] += transaction.amount
        }
    }

    private var unlimitedToggle: some View {
        RoundIconButton(systemImage: "chevron.down") {
            FeedbackManager.shared.buttonTapped()
            withAnimation(.appStandard) {
                showUnlimited = true
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(L10n.budgetNoLimit)
    }
}

struct MonthBudgetCard: View {
    let spent: Int
    let limit: Int
    let action: () -> Void

    private var hasLimit: Bool { limit > .zero }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                if hasLimit {
                    BudgetWaveGauge(spent: spent, limit: limit)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(spent.getAmount())
                        .font(.appRegular(24))
                        .foregroundColor(.appWhite)
                        .contentTransition(.numericText())

                    Text(hasLimit ? "/ \(limit.getAmount())" : L10n.budgetNoLimit)
                        .font(.appLight(15))
                        .foregroundColor(.appLabel)
                        .contentTransition(.numericText())

                    Spacer(minLength: 0)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), tint: .appPrimary.opacity(0.15), isInteractive: true, fallback: .appPrimary.opacity(0.15))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct BudgetSection<Content: View>: View {
    let leadingTitle: String
    let trailingTitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(leadingTitle)

                Spacer(minLength: 8)

                if let trailingTitle {
                    Text(trailingTitle)
                }
            }
            .font(.appLight(14))
            .foregroundColor(.appLabel)
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 4)

            content
        }
        .padding(.bottom, 8)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
    }
}

struct CategoryBudgetRow: View {
    let category: TransactionCategory
    let spent: Int
    let action: () -> Void

    private var limit: Int { category.budget }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CategoryIconView(category: category, size: 24)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(category.name.localized)
                            .font(.appLight(16))
                            .foregroundColor(.appWhite)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(spent.getAmount())
                                .font(.appRegular(16))
                                .foregroundColor(.appWhite)
                                .contentTransition(.numericText())

                            Text("/ \(limit.getAmount())")
                                .font(.appLight(15))
                                .foregroundColor(.appLabel)
                                .contentTransition(.numericText())
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                    }

                    BudgetProgressBar(spent: spent, limit: limit, color: category.categoryIcon.color, height: 4)

                    if spent > limit {
                        Text(L10n.budgetExceeded((spent - limit).getAmount()))
                            .font(.appLight(13))
                            .foregroundColor(.appRed)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct UnsetCategoryBudgetRow: View {
    let category: TransactionCategory
    let spent: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CategoryIconView(category: category, size: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name.localized)
                        .font(.appLight(16))
                        .foregroundColor(.appWhite)

                    Text(spent.getAmount())
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .contentTransition(.numericText())
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                Text(L10n.budgetSet)
                    .font(.appLight(13))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.appLabel.opacity(0.15), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.appLabel.opacity(0.4), lineWidth: 0.5)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BudgetProgressBar: View {
    let spent: Int
    let limit: Int
    let color: Color
    let height: CGFloat

    private var fraction: Double {
        guard limit > .zero else { return .zero }
        return min(max(spent.double / limit.double, .zero), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.appLabel.opacity(0.25))

                Capsule()
                    .fill(spent > limit ? Color.appRed : color)
                    .frame(width: spent > .zero ? max(geometry.size.width * fraction, height) : .zero)
            }
        }
        .frame(height: height)
        .animation(.appStandard, value: fraction)
    }
}

#Preview("Budget") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(5).enumerated() {
        container.mainContext.insert(Transaction(amount: (index + 1) * 29000, category: category, date: Date()))
        category.budget = index < 3 ? 60000 : 0
    }

    return BudgetView()
        .modelContainer(container)
}

#Preview("Empty budget") {
    BudgetView()
        .modelContainer(makePreviewModelContainer())
}

#Preview("Budget cards") {
    VStack(spacing: 16) {
        MonthBudgetCard(spent: 116100, limit: 1500000, action: {})
        MonthBudgetCard(spent: 71800, limit: 12500, action: {})
        MonthBudgetCard(spent: 116100, limit: 0, action: {})
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}
