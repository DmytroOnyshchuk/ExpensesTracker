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

    @Query(filter: TransactionCategory.nonDirectories) private var storedCategories: [TransactionCategory]
    @AppStorage(UDKey.budget.rawValue, store: UserDefaults.shared) private var budgetData: Data?

    @State private var target: BudgetTarget?

    var body: some View {
        let categories = storedCategories.of(.outcome).inDisplayOrder

        NavigationStack {
            BudgetPager(resetToken: resetToken, limited: categories.filter { $0.budget > .zero }, unlimited: categories.filter { $0.budget <= .zero }, monthlyLimit: monthlyLimit, schedule: budget.schedule, onOpen: open)
                .appBackground()
                .navigationTitle(L10n.menuBudget)
                .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if let target {
                Group {
                    switch target {
                    case .month:
                        BudgetSetupPopup(limit: monthlyLimit, schedule: budget.schedule, onRemove: monthlyLimit > .zero ? { remove(target) } : nil, onCancel: close) { amount, schedule in
                            save(limit: amount, schedule: schedule)
                            close()
                        }
                    case .category:
                        BalanceInputPopup(title: target.title, balance: limit(for: target), allowsEmpty: true, onRemove: limit(for: target) > .zero ? { remove(target) } : nil, onCancel: close) { amount in
                            setLimit(amount, for: target)
                            close()
                        }
                    }
                }
                .id(target.id)
                .transition(.opacity)
            }
        }
        .animation(.appStandard, value: target?.id)
    }

    private var budget: Budget {
        Budget(jsonData: budgetData) ?? Budget()
    }

    private var monthlyLimit: Int {
        budget.limit ?? .zero
    }

    private func save(limit: Int, schedule: BudgetSchedule) {
        withAnimation(.appStandard) {
            var budget = budget
            budget.setLimit(limit)
            budget.schedule = schedule
            budgetData = budget.jsonData()
        }
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
                save(limit: amount, schedule: budget.schedule)
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
    let limited: [TransactionCategory]
    let unlimited: [TransactionCategory]
    let monthlyLimit: Int
    let schedule: BudgetSchedule
    let onOpen: (BudgetTarget) -> Void

    @Query private var earliest: [Transaction]
    @Query private var latest: [Transaction]

    @State private var selectedMonth = Date()
    @State private var showUnlimited = false

    init(resetToken: Int, limited: [TransactionCategory], unlimited: [TransactionCategory], monthlyLimit: Int, schedule: BudgetSchedule, onOpen: @escaping (BudgetTarget) -> Void) {
        let predicate = Transaction.shown(of: .outcome)
        var earliest = FetchDescriptor<Transaction>(predicate: predicate, sortBy: [SortDescriptor(\.date)])
        earliest.fetchLimit = 1
        var latest = FetchDescriptor<Transaction>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
        latest.fetchLimit = 1

        self.resetToken = resetToken
        self.limited = limited
        self.unlimited = unlimited
        self.monthlyLimit = monthlyLimit
        self.schedule = schedule
        self.onOpen = onOpen
        _earliest = Query(earliest)
        _latest = Query(latest)
    }

    private var range: BudgetRange {
        BudgetRange(schedule: schedule, earliest: earliest.first?.date, latest: latest.first?.date)
    }

    var body: some View {
        let range = range

        BudgetMonth(month: range.clamped(selectedMonth), range: range, limited: limited, unlimited: unlimited, monthlyLimit: monthlyLimit, isUnlimitedShown: showUnlimited, showUnlimited: $showUnlimited, onSelectMonth: { selectedMonth = $0 }, onOpen: onOpen)
            .onChange(of: resetToken) {
                selectedMonth = Date()
            }
            .onChange(of: schedule) {
                selectedMonth = Date()
            }
    }
}

extension BudgetPager: Equatable {
    nonisolated static func == (lhs: BudgetPager, rhs: BudgetPager) -> Bool { lhs.resetToken == rhs.resetToken && lhs.limited == rhs.limited && lhs.unlimited == rhs.unlimited && lhs.monthlyLimit == rhs.monthlyLimit && lhs.schedule == rhs.schedule }
}

struct BudgetMonth: View {
    let month: Date
    let range: BudgetRange
    let limited: [TransactionCategory]
    let unlimited: [TransactionCategory]
    let monthlyLimit: Int
    let isUnlimitedShown: Bool
    let showUnlimited: Binding<Bool>
    let onSelectMonth: (Date) -> Void
    let onOpen: (BudgetTarget) -> Void

    @Query private var storedTransactions: [Transaction]

    init(month: Date, range: BudgetRange, limited: [TransactionCategory], unlimited: [TransactionCategory], monthlyLimit: Int, isUnlimitedShown: Bool, showUnlimited: Binding<Bool>, onSelectMonth: @escaping (Date) -> Void, onOpen: @escaping (BudgetTarget) -> Void) {
        let interval = range.schedule.interval(containing: month)

        self.month = month
        self.range = range
        self.limited = limited
        self.unlimited = unlimited
        self.monthlyLimit = monthlyLimit
        self.isUnlimitedShown = isUnlimitedShown
        self.showUnlimited = showUnlimited
        self.onSelectMonth = onSelectMonth
        self.onOpen = onOpen
        _storedTransactions = Query(filter: Transaction.shown(from: interval.start, to: interval.end))
    }

    var body: some View {
        BudgetMonthPage(month: month, range: range, transactions: storedTransactions.of(.outcome), limited: limited, unlimited: unlimited, monthlyLimit: monthlyLimit, showUnlimited: showUnlimited, onSelectMonth: onSelectMonth, onOpen: onOpen)
    }
}

extension BudgetMonth: Equatable {
    nonisolated static func == (lhs: BudgetMonth, rhs: BudgetMonth) -> Bool { lhs.month == rhs.month && lhs.range == rhs.range && lhs.limited == rhs.limited && lhs.unlimited == rhs.unlimited && lhs.monthlyLimit == rhs.monthlyLimit && lhs.isUnlimitedShown == rhs.isUnlimitedShown }
}

struct BudgetMonthPage: View {
    let month: Date
    let range: BudgetRange
    let transactions: [Transaction]
    let limited: [TransactionCategory]
    let unlimited: [TransactionCategory]
    let monthlyLimit: Int
    @Binding var showUnlimited: Bool
    let onSelectMonth: (Date) -> Void
    let onOpen: (BudgetTarget) -> Void

    private static let collapsedCount = 3

    var body: some View {
        let spent = spentByCategory

        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                monthHeader

                MonthBudgetCard(spent: transactions.reduce(0) { $0 + $1.amount }, limit: monthlyLimit) {
                    onOpen(.month)
                }

                if !limited.isEmpty {
                    BudgetSection {
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
                        BudgetSection(title: L10n.budgetNoLimit) {
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private var monthHeader: some View {
        let index = range.index(of: month)

        return HStack(spacing: 16) {
            monthArrow(systemImage: "chevron.left", target: index - 1)

            Text(range.schedule.title(for: month))
                .font(.appRegular(22))
                .foregroundColor(.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.opacity)

            monthArrow(systemImage: "chevron.right", target: index + 1)
        }
        .animation(.appStandard, value: month)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
    }

    private func monthArrow(systemImage: String, target: Int) -> some View {
        PeriodArrowButton(systemImage: systemImage, isEnabled: target >= .zero && target < range.count) {
            FeedbackManager.shared.selectionChanged()
            onSelectMonth(range.start(at: target))
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
        RoundIconButton(systemImage: "chevron.down", color: .appPrimary.opacity(0.5)) {
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

    @AppStorage(UDKey.budgetShowsSpent.rawValue, store: UserDefaults.shared) private var showsSpent = false

    private var hasLimit: Bool { limit > .zero }

    var body: some View {
        Button(action: hasLimit ? toggleMode : action) {
            VStack(alignment: .leading, spacing: 8) {
                if hasLimit {
                    BudgetWaveGauge(spent: spent, limit: limit, showsSpent: showsSpent)
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
        .overlay(alignment: .topTrailing) {
            if hasLimit {
                Button(action: action) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appLabel)
                        .frame(width: 52, height: 52)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.budgetForMonth)
            }
        }
    }

    private func toggleMode() {
        FeedbackManager.shared.selectionChanged()
        showsSpent.toggle()
    }
}

struct BudgetSetupPopup: View {
    let onRemove: (() -> Void)?
    let onCancel: () -> Void
    let onConfirm: (Int, BudgetSchedule) -> Void

    @State private var text: String
    @State private var schedule: BudgetSchedule
    @FocusState private var isFocused: Bool

    init(limit: Int, schedule: BudgetSchedule, onRemove: (() -> Void)?, onCancel: @escaping () -> Void, onConfirm: @escaping (Int, BudgetSchedule) -> Void) {
        self.onRemove = onRemove
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _text = State(initialValue: AmountInput.text(from: limit))
        _schedule = State(initialValue: schedule)
    }

    var body: some View {
        TransactionEditPopup(onRemove: onRemove.map { action in { finish(action) } }, onCancel: { finish(onCancel) }, onConfirm: confirm) {
            VStack(spacing: 12) {
                Text(L10n.menuBudget)
                    .font(.appMedium(18))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)

                SegmentedControl(items: BudgetPeriod.allCases, selection: $schedule.period, title: \.title)
                    .sensoryFeedback(trigger: schedule.period) { _, _ in FeedbackManager.shared.selectionFeedback }

                TextField("", text: $text, prompt: Text("0").foregroundColor(.appLabel.opacity(0.6)))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .font(.appRegular(22))
                    .foregroundColor(.appWhite)
                    .tint(.appPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                startRow
            }
            .padding(.horizontal, 16)
            .animation(.appStandard, value: schedule.period)
        }
        .onAppear {
            isFocused = true
        }
    }

    private var startRow: some View {
        HStack(spacing: 12) {
            Text(L10n.autopaymentsStartDate)
                .font(.appLight(16))
                .foregroundColor(.appLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Menu {
                switch schedule.period {
                case .month:
                    Picker("", selection: $schedule.monthDay) {
                        ForEach(BudgetSchedule.monthDays, id: \.self) { day in
                            Text(String(day)).tag(day)
                        }
                    }
                case .week:
                    Picker("", selection: $schedule.weekday) {
                        ForEach(BudgetSchedule.weekdays, id: \.self) { weekday in
                            Text(BudgetSchedule.weekdayName(weekday)).tag(weekday)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(schedule.startTitle)
                        .font(.appRegular(16))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appLabel)
                }
                .frame(height: 48)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func finish(_ action: () -> Void) {
        isFocused = false
        action()
    }

    private func confirm() {
        isFocused = false
        onConfirm(AmountInput.amount(from: text), schedule)
    }
}

struct BudgetSection<Content: View>: View {
    var title: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            if let title {
                Text(title)
                    .font(.appLight(14))
                    .foregroundColor(.appLabel)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            }

            content
        }
        .padding(.vertical, 8)
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
                                .font(.appRegular(20))
                                .foregroundColor(.appWhite)
                                .contentTransition(.numericText())

                            Text("/ \(limit.getAmount())")
                                .font(.appLight(18))
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

#Preview("Budget setup popup") {
    BudgetSetupPopup(limit: 1500000, schedule: BudgetSchedule(), onRemove: {}, onCancel: {}, onConfirm: { _, _ in })
        .background(.appMain)
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
