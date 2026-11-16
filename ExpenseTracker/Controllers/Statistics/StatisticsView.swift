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

struct StatisticsPages {
    let period: StatisticsPeriod
    let first: Date
    let last: Date

    init(period: StatisticsPeriod, transactions: [Transaction], now: Date = Date()) {
        let current = period.interval(containing: now).start
        let dates = transactions.map(\.date)
        let earliest = dates.min().map { period.interval(containing: $0).start } ?? current
        let latest = dates.max().map { period.interval(containing: $0).start } ?? current

        self.period = period
        self.first = min(earliest, current)
        self.last = max(latest, current)
    }

    var count: Int {
        index(of: last) + 1
    }

    func start(at index: Int) -> Date {
        period.shifted(first, by: index)
    }

    func index(of start: Date) -> Int {
        Calendar.current.dateComponents([period.component], from: first, to: start).value(for: period.component) ?? .zero
    }

    func clamped(_ date: Date) -> Date {
        min(max(period.interval(containing: date).start, first), last)
    }
}

struct StatisticsView: View {
    var resetToken: Int = .zero
    var directory: TransactionCategory?

    @Query private var storedTransactions: [Transaction]
    @Query private var storedCategories: [TransactionCategory]

    private var transactions: [Transaction] {
        let transactions = storedTransactions.notDeleted
        guard let directoryUuid = directory?.uuid else { return transactions }

        return transactions.filter {
            $0.category.parentUuid == directoryUuid || $0.category.uuid == directoryUuid
        }
    }

    private var categories: [TransactionCategory] {
        directory == nil ? storedCategories.notDeleted : []
    }

    @State private var period: StatisticsPeriod
    @State private var anchorDate: Date
    @State private var showPeriodList = false
    @State private var showDayPicker = false

    init(
        resetToken: Int = .zero,
        directory: TransactionCategory? = nil,
        period: StatisticsPeriod = .month,
        date: Date = Date()
    ) {
        self.resetToken = resetToken
        self.directory = directory
        _period = State(initialValue: period)
        _anchorDate = State(initialValue: date)
    }

    var body: some View {
        let transactions = transactions
        let pages = StatisticsPages(period: period, transactions: transactions)
        let start = pages.clamped(anchorDate)

        VStack(spacing: 12) {
            periodPicker
            periodTitle(start: start, transactions: transactions)
            pager(transactions: transactions, pages: pages, start: start)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .overlay {
            if showDayPicker {
                StatisticsDayPicker(selected: start) { date in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDayPicker = false
                    }
                    if let date {
                        select(pages.clamped(date), from: start)
                    }
                }
                .transition(.opacity)
            }
        }
        .onChange(of: resetToken) {
            resetToCurrentMonth()
        }
        .navigationTitle(directory?.name.localized ?? L10n.statisticsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if directory == nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ExpensesChartView()
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite)
                    }
                    .accessibilityLabel(L10n.statisticsChart)
                }
            }
        }
    }

    private var periodPicker: some View {
        SegmentedControl(items: StatisticsPeriod.allCases, selection: $period, title: \.title)
            .sensoryFeedback(trigger: period) { _, _ in FeedbackManager.shared.selectionFeedback }
            .padding(.horizontal, 64)
    }

    private func pager(transactions: [Transaction], pages: StatisticsPages, start: Date) -> some View {
        let selectedIndex = pages.index(of: start)

        return ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(0 ..< pages.count, id: \.self) { index in
                    Group {
                        if abs(index - selectedIndex) <= 1 {
                            page(transactions: transactions, start: pages.start(at: index))
                        } else {
                            Color.clear
                        }
                    }
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition(id: pageSelection(pages: pages, start: start))
        .id(period)
    }

    private func page(transactions: [Transaction], start: Date) -> some View {
        let interval = period.interval(containing: start)
        let slices = StatisticsSlice.slices(from: transactions, in: interval, categories: categories)

        return ScrollView(.vertical) {
            StatisticsBreakdown(
                slices: slices,
                interval: interval,
                period: period,
                points: period.chartPoints(of: transactions, in: interval),
                averageTitle: period.unitAverageTitle(of: transactions, in: interval)
            )
            .padding(.bottom, 16)
        }
    }

    private func pageSelection(pages: StatisticsPages, start: Date) -> Binding<Int?> {
        Binding(
            get: { pages.index(of: start) },
            set: { index in
                guard let index else { return }
                let target = pages.start(at: index)
                guard target != start else { return }
                FeedbackManager.shared.selectionChanged()
                anchorDate = target
            }
        )
    }

    private func periodTitle(start: Date, transactions: [Transaction]) -> some View {
        Text(period.title(for: start))
            .font(.appRegular(22))
            .foregroundColor(.appPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: start)
            .padding(.horizontal, 64)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                if period == .day {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDayPicker = true
                    }
                } else {
                    showPeriodList = !transactions.isEmpty
                }
            }
            .popover(isPresented: $showPeriodList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                StatisticsPeriodList(period: period, starts: period.starts(of: transactions), selected: start) { date in
                    showPeriodList = false
                    select(date, from: start)
                }
                .presentationCompactAdaptation(.popover)
                .legacyPresentationBackground(.appSecond)
            }
    }

    private func resetToCurrentMonth() {
        showPeriodList = false
        showDayPicker = false
        withAnimation(.easeInOut(duration: 0.25)) {
            period = .month
            anchorDate = Date()
        }
    }

    private func select(_ date: Date, from start: Date) {
        guard date != start else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            anchorDate = date
        }
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
                                barRatio: maxAmount > 0 ? slice.amount.asDouble / maxAmount.asDouble : 0
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
                if chartStyle == .bars {
                    GlassBarChart(points: points, period: period)
                } else {
                    GlassLineChart(points: points, interval: interval, period: period)
                }
            }
            .padding(.vertical, 24)
            .frame(height: 350)
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
        ZStack {
            Color.appOverlay.opacity(0.4)
                .ignoresSafeArea(edges: .bottom)
                .onTapGesture {
                    onFinish(nil)
                }

            VStack(spacing: 0) {
                shortcutButton(for: Date())
                shortcutButton(for: .yesterday)

                DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)

                HStack(spacing: 0) {
                    actionButton(L10n.cancel) {
                        onFinish(nil)
                    }
                    actionButton(L10n.ok) {
                        onFinish(date)
                    }
                }
            }
            .padding(.vertical, 12)
            .glassSurface(
                in: RoundedRectangle(cornerRadius: LiquidGlass.isAvailable ? 28 : 16, style: .continuous),
                fallback: .appSecond
            )
            .padding(.horizontal, 32)
        }
    }

    private func shortcutButton(for day: Date) -> some View {
        Button {
            onFinish(day)
        } label: {
            Text(day.relativeDayName ?? "")
                .font(.appLight(20))
                .foregroundColor(.appWhite.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appRegular(20))
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
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
                            .padding(.horizontal, 20)
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
        .frame(width: 280, height: min(starts.count.asCgFloat * Self.rowHeight, Self.maxHeight))
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
        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
        .padding(.horizontal, 16)
        .frame(height: 52)
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
