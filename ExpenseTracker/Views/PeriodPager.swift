//
//  PeriodPager.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct PeriodPager<Page: View>: View {
    private static var radius: Int { 30 }
    private static var recenterDistance: Int { 20 }

    let count: Int
    @Binding var selection: Int
    let page: (Int) -> Page

    @State private var center: Int
    @State private var position: Int?

    init(count: Int, selection: Binding<Int>, @ViewBuilder page: @escaping (Int) -> Page) {
        self.count = count
        self.page = page
        _selection = selection
        _center = State(initialValue: selection.wrappedValue)
        _position = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        let window = window

        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(Array(window), id: \.self) { index in
                    page(index)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $position)
        .defaultScrollAnchor(initialAnchor(in: window), for: .initialOffset)
        .onScrollPhaseChange { _, phase in
            guard phase == .idle, let position, abs(position - center) >= Self.recenterDistance else { return }
            center = position
        }
        .id(center)
        .onChange(of: position) { _, newValue in
            guard let newValue, newValue != selection else { return }
            selection = newValue
        }
        .onChange(of: selection) { _, newValue in
            show(newValue)
        }
    }

    private var window: ClosedRange<Int> {
        let lower = max(center - Self.radius, .zero)
        let upper = max(min(center + Self.radius, count - 1), lower)
        return lower ... upper
    }

    private func initialAnchor(in window: ClosedRange<Int>) -> UnitPoint {
        let span = window.upperBound - window.lowerBound
        guard span > .zero else { return .leading }

        let index = min(max(position ?? center, window.lowerBound), window.upperBound)
        return UnitPoint(x: (index - window.lowerBound).double / span.double, y: 0.5)
    }

    private func show(_ index: Int) {
        guard index != position else { return }

        if abs(index - (position ?? center)) == 1, window.contains(index) {
            withAnimation(.appStandard) {
                position = index
            }
        } else {
            center = index
            position = index
        }
    }
}
