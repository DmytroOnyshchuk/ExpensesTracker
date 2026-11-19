//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
    var resetToken: Int = .zero
    var directory: TransactionCategory?

    @Query(filter: Transaction.visible) private var storedTransactions: [Transaction]
    @Query(filter: TransactionCategory.notDeleted) private var storedCategories: [TransactionCategory]

    @State private var period: StatisticsPeriod
    @State private var selectedOperationType: OperationType = .outcome
    @StoredSettings private var appSettings

    private let initialDate: Date

    private var operationType: OperationType {
        appSettings.accounting.incomeEnabled ? selectedOperationType : .outcome
    }

    private var transactions: [Transaction] {
        guard let directoryUuid = directory?.uuid else { return storedTransactions.of(operationType) }

        return storedTransactions.filter {
            $0.category.parentUuid == directoryUuid || $0.category.uuid == directoryUuid
        }
    }

    private var categories: [TransactionCategory] {
        directory == nil ? storedCategories.of(operationType) : []
    }

    init(
        resetToken: Int = .zero,
        directory: TransactionCategory? = nil,
        period: StatisticsPeriod = .month,
        date: Date = Date()
    ) {
        self.resetToken = resetToken
        self.directory = directory
        self.initialDate = date
        _period = State(initialValue: period)
    }

    var body: some View {
        StatisticsContent(
            resetToken: resetToken,
            buckets: StatisticsBuckets(period: period, transactions: transactions),
            categories: categories,
            period: $period,
            date: initialDate
        )
        .navigationTitle(directory?.name.localized ?? operationType.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: resetToken) {
            selectedOperationType = .outcome
        }
        .toolbar {
            if directory == nil {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ExpensesChartView(operationType: operationType)
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite)
                    }
                    .accessibilityLabel(L10n.statisticsChart)

                    if appSettings.accounting.incomeEnabled {
                        Button(action: toggleOperationType) {
                            Image(systemName: operationType.systemImage)
                                .font(.system(size: 14, weight: .semibold))
                                .contentTransition(.symbolEffect(.replace))
                                .foregroundColor(operationType == .income ? .green : .appWhite)
                        }
                        .accessibilityLabel(operationType.title)
                    }
                }
            }
        }
    }

    private func toggleOperationType() {
        FeedbackManager.shared.selectionChanged()
        selectedOperationType = operationType.toggled
    }
}

extension StatisticsView: Equatable {
    nonisolated static func == (lhs: StatisticsView, rhs: StatisticsView) -> Bool { lhs.resetToken == rhs.resetToken && lhs.directory?.persistentModelID == rhs.directory?.persistentModelID && lhs.initialDate == rhs.initialDate }
}

struct StatisticsContent: View {
    let resetToken: Int
    let buckets: StatisticsBuckets
    let categories: [TransactionCategory]

    @Binding var period: StatisticsPeriod

    @State private var anchorDate: Date
    @State private var showPeriodList = false
    @State private var showDayPicker = false

    init(
        resetToken: Int,
        buckets: StatisticsBuckets,
        categories: [TransactionCategory],
        period: Binding<StatisticsPeriod>,
        date: Date
    ) {
        self.resetToken = resetToken
        self.buckets = buckets
        self.categories = categories
        _period = period
        _anchorDate = State(initialValue: date)
    }

    var body: some View {
        let start = buckets.clamped(anchorDate)

        VStack(spacing: 12) {
            periodPicker
            periodTitle(start: start)

            PeriodPager(count: buckets.count, selection: pageSelection(start: start)) { index in
                page(start: buckets.start(at: index))
            }
            .id(buckets.period)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .overlay {
            if showDayPicker {
                StatisticsDayPicker(selected: start) { date in
                    withAnimation(.appStandard) {
                        showDayPicker = false
                    }
                    if let date {
                        anchorDate = buckets.clamped(date)
                    }
                }
                .transition(.opacity)
            }
        }
        .onChange(of: resetToken) {
            resetToCurrentMonth()
        }
    }

    private var periodSelection: Binding<StatisticsPeriod> {
        Binding(
            get: { period },
            set: { newValue in
                if newValue == .day, period != .day {
                    anchorDate = initialDay(inSelected: period)
                }
                period = newValue
            }
        )
    }

    private func initialDay(inSelected period: StatisticsPeriod) -> Date {
        let now = Date()
        let interval = period.interval(containing: anchorDate)
        return interval.contains(now) ? now : interval.start
    }

    private var periodPicker: some View {
        SegmentedControl(items: StatisticsPeriod.allCases, selection: periodSelection, title: \.title)
            .sensoryFeedback(trigger: period) { _, _ in FeedbackManager.shared.selectionFeedback }
            .padding(.horizontal, 64)
    }

    private func page(start: Date) -> some View {
        let period = buckets.period
        let interval = period.interval(containing: start)
        let transactions = buckets.transactions(at: start)

        return ScrollView(.vertical) {
            StatisticsBreakdown(
                slices: StatisticsSlice.slices(from: transactions, in: interval, categories: categories),
                interval: interval,
                period: period,
                points: period.chartPoints(of: transactions, in: interval),
                averageTitle: period.unitAverageTitle(of: transactions, in: interval)
            )
            .padding(.bottom, 16)
        }
    }

    private func pageSelection(start: Date) -> Binding<Int> {
        Binding(
            get: { buckets.index(of: start) },
            set: { index in
                FeedbackManager.shared.selectionChanged()
                anchorDate = buckets.start(at: index)
            }
        )
    }

    private func periodTitle(start: Date) -> some View {
        Text(buckets.period.title(for: start))
            .font(.appRegular(22))
            .foregroundColor(.appPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .contentTransition(.opacity)
            .animation(.appStandard, value: start)
            .padding(.horizontal, 64)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                if buckets.period == .day {
                    withAnimation(.appStandard) {
                        showDayPicker = true
                    }
                } else {
                    showPeriodList = !buckets.groups.isEmpty
                }
            }
            .popover(isPresented: $showPeriodList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                StatisticsPeriodList(period: buckets.period, starts: buckets.starts, selected: start) { date in
                    showPeriodList = false
                    anchorDate = date
                }
                .presentationCompactAdaptation(.popover)
                .legacyPresentationBackground(.appSecond)
            }
    }

    private func resetToCurrentMonth() {
        showPeriodList = false
        showDayPicker = false
        withAnimation(.appStandard) {
            period = .month
        }
        anchorDate = Date()
    }
}

struct StatisticsBreakdown: View {
    let slices: [StatisticsSlice]
    let interval: DateInterval
    var period: StatisticsPeriod?
    var points: [StatisticsChartPoint] = []
    var averageTitle: String?

    @StoredSettings private var appSettings

    private var chartStyle: StatisticsChartStyle {
        get { appSettings.statisticsChartStyle }
        nonmutating set { appSettings.statisticsChartStyle = newValue }
    }

    private var canSwitchStyle: Bool {
        period != nil && !slices.isEmpty && !points.isEmpty
    }

    var body: some View {
        let total = slices.reduce(0) { $0 + $1.amount }
        let maxAmount = slices.first?.amount ?? .zero

        VStack(spacing: 12) {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text(total.getAmount())
                        .font(.appRegular(28))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(.appWhite)

                    if let averageTitle {
                        Text(averageTitle)
                            .font(.appLight(13))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.appWhite.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)

                if slices.isEmpty {
                    Text(L10n.transactionsListNoTransactions)
                        .font(.appLight(18))
                        .foregroundColor(.appGray.opacity(0.6))
                        .frame(height: 120)
                } else {
                    chart
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard canSwitchStyle else { return }
                            chartStyle = chartStyle.next
                        }
                        .sensoryFeedback(trigger: chartStyle) { _, _ in FeedbackManager.shared.selectionFeedback }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())

            if !slices.isEmpty {
                VStack(spacing: 0) {
                    ForEach(slices) { slice in
                        NavigationLink {
                            if let period, slice.category.isDirectory {
                                StatisticsView(directory: slice.category, period: period, date: interval.start)
                            } else {
                                TransactionDetails(category: slice.category, interval: interval)
                            }
                        } label: {
                            StatisticsRow(
                                slice: slice,
                                barRatio: maxAmount > 0 ? slice.amount.double / maxAmount.double : 0
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var chart: some View {
        if let period, canSwitchStyle, chartStyle != .pie {
            Group {
                GlassBarChart(points: points, period: period)
                // if chartStyle == .bars {
                //     GlassBarChart(points: points, period: period)
                // } else {
                //     GlassLineChart(points: points, interval: interval, period: period)
                // }
            }
            .padding(.vertical, 24)
            .frame(height: 260)
            .padding(.bottom, 16)
        } else {
            GlassDonutChart(slices: slices)
        }
    }
}

struct StatisticsDayPicker: View {
    var onFinish: (Date?) -> Void

    @State private var date: Date

    init(selected: Date, onFinish: @escaping (Date?) -> Void) {
        self.onFinish = onFinish
        _date = State(initialValue: selected)
    }

    var body: some View {
        TransactionEditPopup(onCancel: { onFinish(nil) }, onConfirm: { onFinish(date) }) {
            VStack(spacing: 4) {
                shortcutButton(for: Date())
                shortcutButton(for: .yesterday)

                DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
            }
        }
    }

    private func shortcutButton(for day: Date) -> some View {
        Button {
            onFinish(day)
        } label: {
            Text(day.relativeDayName ?? "")
                .font(.appLight(20))
                .foregroundColor(.appLabel)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct StatisticsPeriodList: View {
    let period: StatisticsPeriod
    let starts: [Date]
    let selected: Date
    var onSelect: (Date) -> Void

    private static let rowHeight: CGFloat = 48
    private static let maxHeight: CGFloat = 432

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(starts, id: \.self) { date in
                        Button {
                            onSelect(date)
                        } label: {
                            HStack(spacing: 12) {
                                Text(period.title(for: date))
                                    .font(.appLight(18))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Spacer(minLength: 0)

                                if date == selected {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(.appWhite)
                            .padding(.horizontal, 16)
                            .frame(height: Self.rowHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .id(date)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(selected, anchor: .center)
            }
        }
        .frame(width: 280, height: min(starts.count.cgFloat * Self.rowHeight, Self.maxHeight))
    }
}

struct StatisticsRow: View {
    let slice: StatisticsSlice
    let barRatio: Double

    var body: some View {
        HStack(spacing: 12) {
            slice.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            Text(slice.category.name.localized)
                .font(.appLight(18))
                .lineLimit(1)

            Spacer(minLength: 8)

            Text("\(slice.percent)%")
                .font(.appRegular(18))
                .frame(width: 56, alignment: .trailing)

            Text(slice.amount.getAmount())
                .font(.appLight(18))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 110, alignment: .trailing)
        }
        .foregroundColor(.appWhite)
        .shadow(
            color: ThemeManager.shared.theme.colorScheme == .dark ? .black.opacity(0.35) : .clear,
            radius: 2,
            y: 1
        )
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(alignment: .leading) {
            GeometryReader { geometry in
                glassBar
                    .frame(width: max(geometry.size.width * barRatio, 6))
            }
        }
    }

    private var glassBar: some View {
        let color = slice.category.categoryIcon.color
        let shape = Rectangle()

        return shape
            .fill(color.opacity(0.75))
            .overlay {
                shape
                    .strokeBorder(color.opacity(0.25), lineWidth: 0.15)
            }
            .background {
                shape
                    .stroke(color, lineWidth: 0.25)
                    .blur(radius: 0.5)
                    .opacity(0.7)
            }
    }
}

#Preview("Statistics") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(7).enumerated() {
        container.mainContext.insert(Transaction(amount: (7 - index) * 125000, category: category))
    }

    return NavigationStack {
        StatisticsView()
    }
    .modelContainer(container)
}

#Preview("Directory statistics") {
    let container = makePreviewModelContainer()
    let directory = TransactionCategory(name: "Food", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
    container.mainContext.insert(directory)
    for (index, name) in ["Groceries", "Restaurants", "Coffee"].enumerated() {
        let category = TransactionCategory(
            name: .custom(name),
            categoryIcon: CategoryIcon(name: "cart.fill", iconColor: IconColor.allCases[index]),
            parentUuid: directory.uuid
        )
        container.mainContext.insert(category)
        container.mainContext.insert(Transaction(amount: (3 - index) * 125000, category: category))
    }

    return NavigationStack {
        StatisticsView(directory: directory)
    }
    .modelContainer(container)
}

#Preview("Empty statistics") {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(makePreviewModelContainer())
}

#Preview("Day picker") {
    StatisticsDayPicker(selected: Date()) { _ in }
        .background(.appMain)
}

#Preview("Statistics row") {
    StatisticsRow(
        slice: StatisticsSlice(
            category: TransactionCategory(name: "Food", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true),
            amount: 1248500,
            share: 0.16
        ),
        barRatio: 0.53
    )
    .background(.appMain)
}
