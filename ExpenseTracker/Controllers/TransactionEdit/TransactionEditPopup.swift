//
//  TransactionEditPopup.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct TransactionEditPopup<Content: View>: View {
    var canConfirm = true
    let onCancel: () -> Void
    let onConfirm: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.appOverlay.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 0) {
                content

                Rectangle()
                    .fill(.appLabel.opacity(0.2))
                    .frame(height: 0.5)
                    .padding(.top, 14)

                HStack(spacing: 0) {
                    actionButton(L10n.cancel, action: onCancel)

                    Rectangle()
                        .fill(.appLabel.opacity(0.2))
                        .frame(width: 0.5, height: 24)

                    actionButton(L10n.ok, action: onConfirm)
                        .disabled(!canConfirm)
                        .opacity(canConfirm ? 1 : 0.4)
                }
            }
            .padding(.top, 18)
            .frame(maxWidth: .infinity)
            .glassSurface(
                in: RoundedRectangle(cornerRadius: LiquidGlass.isAvailable ? 24 : 16, style: .continuous),
                fallback: .appSecond
            )
            .padding(.horizontal, 48)
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appRegular(15))
                .foregroundColor(.appPrimary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TransactionDatePopup: View {
    let onCancel: () -> Void
    let onConfirm: (Date) -> Void

    @State private var date: Date

    init(date: Date, onCancel: @escaping () -> Void, onConfirm: @escaping (Date) -> Void) {
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _date = State(initialValue: date)
    }

    var body: some View {
        TransactionEditPopup(onCancel: onCancel, onConfirm: { onConfirm(date) }) {
            VStack(spacing: 4) {
                quickButton(for: Date())
                quickButton(for: .yesterday)

                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
            }
        }
    }

    private func quickButton(for day: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: day)

        return Button {
            withAnimation {
                date = day
            }
        } label: {
            Text(day.relativeDayName ?? "")
                .font(.appLight(20))
                .foregroundColor(isSelected ? .appPrimary : .appLabel)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TransactionTimePopup: View {
    let onCancel: () -> Void
    let onConfirm: (Date) -> Void

    @State private var time: Date

    init(time: Date, onCancel: @escaping () -> Void, onConfirm: @escaping (Date) -> Void) {
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _time = State(initialValue: time)
    }

    var body: some View {
        TransactionEditPopup(onCancel: onCancel, onConfirm: { onConfirm(time) }) {
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
        }
    }
}

#Preview("Time popup") {
    TransactionTimePopup(time: Date(), onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}

#Preview("Date popup") {
    TransactionDatePopup(date: .yesterday, onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}
