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
    @Query private var transactions: [Transaction]
    @Query private var categories: [TransactionCategory]

    @State private var period: StatisticsPeriod = .month
    @State private var anchorDate = Date()
    @State private var slideEdge: Edge = .trailing
    @State private var showPeriodList = false
    @State private var showDayPicker = false
    @State private var exactStart: Date?

    var body: some View {
        let starts = period.starts(of: transactions)
        let start = displayedStart(in: starts)
        let interval = period.interval(containing: start)
        let slices = StatisticsSlice.slices(from: transactions, in: interval)
        let total = slices.reduce(0) { $0 + $1.amount }
        let maxAmount = slices.first?.amount ?? 0

        ScrollView(.vertical) {
            VStack(spacing: 12) {
                periodPicker
                periodTitle(start: start, starts: starts)
                if let average = period.average(of: transactions) {
                    averageLabel(average)
                }
                totalLabel(total)

                if slices.isEmpty {
                    Text(L10n.transactionsListNoTransactions)
                        .font(.appLight(18))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 120)
                } else {
                    StatisticsPieChart(slices: slices)
                        .frame(height: 264)
                        .padding(.horizontal, 48)

                    VStack(spacing: 0) {
                        ForEach(slices) { slice in
                            NavigationLink {
                                TransactionDetails(category: slice.category, interval: interval)
                            } label: {
                                StatisticsRow(
                                    slice: slice,
                                    parentName: parentName(of: slice.category),
                                    barRatio: maxAmount > 0 ? slice.amount.asDouble / maxAmount.asDouble : 0
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(slice.category.isDirectory)
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .overlay {
            if showDayPicker {
                StatisticsDayPicker(selected: start) { date in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDayPicker = false
                    }
                    if let date {
                        selectDay(date, from: start)
                    }
                }
                .transition(.opacity)
            }
        }
        .navigationTitle(L10n.statisticsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var periodPicker: some View {
        SegmentedControl(items: StatisticsPeriod.allCases, selection: $period, title: \.title)
            .sensoryFeedback(.selection, trigger: period)
            .padding(.horizontal, 64)
    }

    private func periodTitle(start: Date, starts: [Date]) -> some View {
        ZStack {
            Text(period.title(for: start))
                .font(.appRegular(22))
                .foregroundColor(.appBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .id(period.interval(containing: start))
                .transition(.push(from: slideEdge))
        }
        .padding(.horizontal, 64)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            if period == .day {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDayPicker = true
                }
            } else {
                showPeriodList = !starts.isEmpty
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    shiftPeriod(by: value.translation.width < 0 ? 1 : -1, from: start, in: starts)
                }
        )
        .overlay {
            HStack {
                periodArrow(systemImage: "chevron.left", shift: -1, start: start, starts: starts)
                Spacer()
                periodArrow(systemImage: "chevron.right", shift: 1, start: start, starts: starts)
            }
            .padding(.horizontal, 16)
        }
        .popover(isPresented: $showPeriodList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            StatisticsPeriodList(period: period, starts: starts, selected: start) { date in
                showPeriodList = false
                select(date, from: start)
            }
            .presentationCompactAdaptation(.popover)
            .presentationBackground(.appSecond)
        }
    }

    private func periodArrow(systemImage: String, shift: Int, start: Date, starts: [Date]) -> some View {
        let isEnabled = neighbour(of: start, by: shift, in: starts) != nil

        return Button {
            shiftPeriod(by: shift, from: start, in: starts)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.appBlue.opacity(isEnabled ? 1 : 0.3))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func averageLabel(_ average: Int) -> some View {
        Text(period.averageTitle(for: average.getAmount()))
            .font(.appLight(13))
            .foregroundColor(.appWhite.opacity(0.6))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 16)
            .padding(.top, -12)
    }

    private func totalLabel(_ total: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(L10n.statisticsTotalSpent + ":")
                .font(.appLight(16))

            Text(total.getAmount())
                .font(.appLight(24))
        }
        .foregroundColor(.appWhite)
    }

    private func displayedStart(in starts: [Date]) -> Date {
        let start = period.interval(containing: anchorDate).start
        if starts.isEmpty || starts.contains(start) || start == exactStart {
            return start
        }
        return starts.first { $0 < start } ?? starts.last ?? start
    }

    private func shiftPeriod(by value: Int, from start: Date, in starts: [Date]) {
        guard let target = neighbour(of: start, by: value, in: starts) else { return }
        FeedbackManager.selectionChanged()
        select(target, from: start)
    }

    private func neighbour(of start: Date, by value: Int, in starts: [Date]) -> Date? {
        value > 0 ? starts.last { $0 > start } : starts.first { $0 < start }
    }

    private func selectDay(_ date: Date, from start: Date) {
        let day = StatisticsPeriod.day.interval(containing: date).start
        exactStart = day
        select(day, from: start)
    }

    private func select(_ date: Date, from start: Date) {
        guard date != start else { return }

        slideEdge = date > start ? .trailing : .leading
        withAnimation(.easeInOut(duration: 0.25)) {
            anchorDate = date
        }
    }

    private func parentName(of category: TransactionCategory) -> String? {
        guard let parent = category.parent(from: categories), parent.isDirectory else { return nil }
        return parent.name.localized
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
            Color.black.opacity(0.4)
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
            .background(.appSecond)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .foregroundColor(.appBlue)
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

struct StatisticsPieChart: View {
    let slices: [StatisticsSlice]

    private static let minLabelShare = 0.08

    var body: some View {
        Chart(slices) { slice in
            SectorMark(angle: .value("Amount", slice.amount), angularInset: 1)
                .foregroundStyle(slice.category.categoryIcon.color.opacity(0.75))
                .annotation(position: .overlay) {
                    if slice.share >= Self.minLabelShare {
                        Text(slice.category.name.localized)
                            .font(.appRegular(12))
                            .foregroundColor(.appWhite)
                            .lineLimit(1)
                            .frame(maxWidth: 72)
                    }
                }
        }
        .chartLegend(.hidden)
    }
}

struct StatisticsRow: View {
    let slice: StatisticsSlice
    let parentName: String?
    let barRatio: Double

    var body: some View {
        HStack(spacing: 12) {
            slice.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 0) {
                Text(slice.category.name.localized)
                    .font(.appLight(18))
                    .lineLimit(1)

                if let parentName {
                    Text(parentName)
                        .font(.appLight(12))
                        .lineLimit(1)
                }
            }

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
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(alignment: .leading) {
            GeometryReader { geometry in
                Rectangle()
                    .fill(slice.category.categoryIcon.color.opacity(0.8))
                    .frame(width: geometry.size.width * barRatio)
            }
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
            category: TransactionCategory(name: "Groceries", categoryIcon: CategoryIcon(name: "cart", iconColor: .green)),
            amount: 1248500,
            share: 0.16
        ),
        parentName: "Food",
        barRatio: 0.53
    )
    .background(.appMain)
}
