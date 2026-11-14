//
//  ExpensesChartView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

struct ExpensesChartView: View {
    @Query private var transactions: [Transaction]
    @Query private var categories: [TransactionCategory]

    @State private var period: StatisticsPeriod = .day
    @State private var selection: DateInterval?

    var body: some View {
        let amounts = period.amounts(of: transactions)

        ScrollView(.vertical) {
            VStack(spacing: 12) {
                SegmentedControl(items: StatisticsPeriod.allCases, selection: $period, title: \.title)
                    .sensoryFeedback(.selection, trigger: period)
                    .padding(.horizontal, 64)

                if amounts.isEmpty {
                    Text(L10n.transactionsListNoTransactions)
                        .font(.appLight(18))
                        .foregroundColor(.appGray.opacity(0.6))
                        .frame(height: 120)
                } else {
                    ExpensesChart(period: period, amounts: amounts, selection: $selection)
                        .frame(height: 320)
                        .padding(12)
                        .background(.appSecond)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                        .id(period)

                    if let selection {
                        Text(period.rangeTitle(for: selection))
                            .font(.appRegular(22))
                            .foregroundColor(.appPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        StatisticsBreakdown(
                            slices: StatisticsSlice.slices(from: transactions, in: selection),
                            interval: selection,
                            categories: categories
                        )
                    }
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .navigationTitle(L10n.statisticsChart)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: period) {
            selection = nil
        }
    }
}

struct ExpensesChart: View {
    let period: StatisticsPeriod
    let amounts: [Date: Int]
    @Binding var selection: DateInterval?

    @State private var visibleStart: Date
    @State private var visibleLength: TimeInterval
    @State private var panBase: (start: Date, offset: CGFloat)?
    @State private var zoomBase: (start: Date, length: TimeInterval)?

    private let domain: DateInterval

    private static let space = "ExpensesChart"
    private static let maxPointsCount = 62.0
    private static let handleSize: CGFloat = 26
    private static let handleHitWidth: CGFloat = 44

    private enum Cursor {
        case leading
        case trailing

        var color: Color {
            switch self {
            case .leading: .orange
            case .trailing: .indigo
            }
        }
    }

    init(period: StatisticsPeriod, amounts: [Date: Int], selection: Binding<DateInterval?>) {
        self.period = period
        self.amounts = amounts
        _selection = selection

        let now = Date()
        let end = period.interval(containing: max(amounts.keys.max() ?? now, now)).end
        let paddedStart = period.interval(containing: end.addingTimeInterval(-period.defaultVisibleLength)).start
        let domain = DateInterval(start: min(amounts.keys.min() ?? paddedStart, paddedStart), end: end)
        let length = min(period.defaultVisibleLength, domain.duration)

        self.domain = domain
        _visibleStart = State(initialValue: end.addingTimeInterval(-length))
        _visibleLength = State(initialValue: length)
    }

    private var visibleEnd: Date {
        visibleStart.addingTimeInterval(visibleLength)
    }

    private var minLength: TimeInterval {
        min(period.minVisibleLength, domain.duration)
    }

    private var maxLength: TimeInterval {
        min(period.maxVisibleLength, domain.duration)
    }

    private var showsPoints: Bool {
        visibleLength / period.unitDuration <= Self.maxPointsCount
    }

    private var buckets: [ExpensesChartBucket] {
        let calendar = Calendar.current
        let from = max(domain.start, visibleStart.addingTimeInterval(-visibleLength))
        let to = min(domain.end, visibleEnd.addingTimeInterval(visibleLength))

        var result: [ExpensesChartBucket] = []
        var date = period.interval(containing: from).start
        while date < to {
            result.append(ExpensesChartBucket(start: date, amount: amounts[date] ?? .zero))
            guard let next = calendar.date(byAdding: period.component, value: 1, to: date) else { break }
            let normalized = period.interval(containing: next).start
            guard normalized > date else { break }
            date = normalized
        }
        return result
    }

    var body: some View {
        let buckets = buckets
        let upperBound = upperBound(of: buckets)

        Chart {
            if let selection {
                RectangleMark(
                    xStart: .value("Start", selection.start),
                    xEnd: .value("End", selection.end)
                )
                .foregroundStyle(Color.appPrimary.opacity(0.08))
            }

            ForEach(buckets) { bucket in
                if period == .day {
                    LineMark(
                        x: .value("Date", bucket.start, unit: .day),
                        y: .value("Amount", bucket.value)
                    )
                    .foregroundStyle(Color.appRed)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineJoin: .round))

                    if showsPoints {
                        PointMark(
                            x: .value("Date", bucket.start, unit: .day),
                            y: .value("Amount", bucket.value)
                        )
                        .symbolSize(18)
                        .foregroundStyle(Color.appWhite)
                    }
                } else {
                    BarMark(
                        x: .value("Date", bucket.start, unit: period.component),
                        y: .value("Amount", bucket.value),
                        width: .ratio(0.6)
                    )
                    .foregroundStyle(Color.appRed)
                }
            }
        }
        .chartXScale(domain: visibleStart ... visibleEnd)
        .chartYScale(domain: 0 ... upperBound)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                AxisGridLine()
                    .foregroundStyle(Color.appLabel.opacity(0.2))
                AxisValueLabel()
                    .foregroundStyle(Color.appLabel)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.appLabel.opacity(0.2))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.formatted(.number.notation(.compactName)))
                            .foregroundColor(.appLabel)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { plot in
            plot.clipped()
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                if let anchor = proxy.plotFrame {
                    let frame = geometry[anchor]

                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(panGesture(width: frame.width))
                            .simultaneousGesture(zoomGesture)

                        cursor(.leading, in: frame)
                        cursor(.trailing, in: frame)
                    }
                }
            }
            .coordinateSpace(name: Self.space)
        }
    }

    private func cursor(_ cursor: Cursor, in frame: CGRect) -> some View {
        let date = date(of: cursor)
        let exactX = frame.minX + CGFloat(date.timeIntervalSince(visibleStart) / visibleLength) * frame.width
        let x = min(max(exactX, frame.minX), frame.maxX)
        let isOutside = abs(exactX - x) > 0.5

        return ZStack(alignment: .top) {
            Rectangle()
                .fill(cursor.color)
                .frame(width: 2, height: frame.height)
                .opacity(isOutside ? 0 : 1)

            RoundedRectangle(cornerRadius: 6)
                .fill(cursor.color)
                .frame(width: Self.handleSize, height: Self.handleSize)
        }
        .frame(width: Self.handleHitWidth, height: frame.height, alignment: .top)
        .contentShape(Rectangle())
        .opacity(isOutside ? 0.45 : 1)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.space))
                .onChanged { value in
                    move(cursor, toX: value.location.x, in: frame)
                }
        )
        .position(x: x, y: frame.midY)
    }

    private func date(of cursor: Cursor) -> Date {
        switch cursor {
        case .leading: selection?.start ?? visibleStart
        case .trailing: selection?.end ?? visibleEnd
        }
    }

    private func move(_ cursor: Cursor, toX x: CGFloat, in frame: CGRect) {
        guard frame.width > 0 else { return }

        let ratio = Double((min(max(x, frame.minX), frame.maxX) - frame.minX) / frame.width)
        let date = period.boundary(nearest: visibleStart.addingTimeInterval(visibleLength * ratio))
        var start = selection?.start ?? max(period.boundary(nearest: visibleStart), domain.start)
        var end = selection?.end ?? min(period.boundary(nearest: visibleEnd), domain.end)

        switch cursor {
        case .leading:
            start = min(max(date, domain.start), period.shifted(end, by: -1))
        case .trailing:
            end = max(min(date, domain.end), period.shifted(start, by: 1))
        }

        guard start < end else { return }

        let updated = DateInterval(start: start, end: end)
        guard updated != selection else { return }

        FeedbackManager.selectionChanged()
        selection = updated
    }

    private func panGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard zoomBase == nil, width > 0 else { return }

                let base = panBase ?? (visibleStart, value.translation.width)
                panBase = base
                let shift = Double((value.translation.width - base.offset) / width) * visibleLength
                visibleStart = clampedStart(base.start.addingTimeInterval(-shift), length: visibleLength)
            }
            .onEnded { _ in
                panBase = nil
            }
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let base = zoomBase ?? (visibleStart, visibleLength)
                zoomBase = base
                panBase = nil

                let length = min(max(base.length / Double(max(value.magnification, 0.01)), minLength), maxLength)
                let anchor = Double(value.startAnchor.x)
                let anchorDate = base.start.addingTimeInterval(base.length * anchor)
                visibleLength = length
                visibleStart = clampedStart(anchorDate.addingTimeInterval(-length * anchor), length: length)
            }
            .onEnded { _ in
                zoomBase = nil
            }
    }

    private func clampedStart(_ start: Date, length: TimeInterval) -> Date {
        min(max(start, domain.start), domain.end.addingTimeInterval(-length))
    }

    private func upperBound(of buckets: [ExpensesChartBucket]) -> Double {
        let visibleMax = buckets
            .filter { $0.start < visibleEnd && period.interval(containing: $0.start).end > visibleStart }
            .map(\.value)
            .max() ?? .zero

        guard visibleMax > 0 else { return 1 }

        let target = visibleMax * 1.2
        let magnitude = pow(10, floor(log10(target)))
        let step = [1.0, 1.5, 2, 3, 4, 5, 6, 8, 10].first { $0 * magnitude >= target } ?? 10
        return step * magnitude
    }
}

struct ExpensesChartBucket: Identifiable {
    let start: Date
    let amount: Int

    var id: Date { start }

    var value: Double { amount.asDouble / 100 }
}

#Preview("Chart") {
    let container = makePreviewModelContainer()
    let categories = ((try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? [])
        .filter { !$0.isDirectory }
    for day in 0 ..< 400 {
        guard let category = categories.randomElement() else { break }
        container.mainContext.insert(
            Transaction(
                amount: Int.random(in: 20000 ... 800000),
                category: category,
                date: Date().adding(-day, .day)
            )
        )
    }

    return NavigationStack {
        ExpensesChartView()
    }
    .modelContainer(container)
}

#Preview("Empty chart") {
    NavigationStack {
        ExpensesChartView()
    }
    .modelContainer(makePreviewModelContainer())
}
