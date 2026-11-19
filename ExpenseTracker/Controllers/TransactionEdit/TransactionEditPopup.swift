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
    var cancelTitle: String? = L10n.cancel
    var confirmTitle = L10n.ok
    var confirmColor: Color = .appPrimary
    var onRemove: (() -> Void)?
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
                    .fill(.appLabel.opacity(0.25))
                    .frame(height: 0.5)
                    .padding(.top, 16)

                HStack(spacing: 0) {
                    if let onRemove {
                        actionButton(L10n.remove, color: .appRed, action: onRemove)

                        buttonDivider
                    }

                    if let cancelTitle {
                        actionButton(cancelTitle, action: onCancel)

                        buttonDivider
                    }

                    actionButton(confirmTitle, color: confirmColor, action: onConfirm)
                        .disabled(!canConfirm)
                        .opacity(canConfirm ? 1 : 0.4)
                }
            }
            .padding(.top, 16)
            .frame(maxWidth: 360)
            .glassSurface(in: RoundedRectangle(cornerRadius: 28, style: .continuous), fallback: .appSecond)
            .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, 32)
            .animation(.appStandard, value: canConfirm)
        }
    }

    private var buttonDivider: some View {
        Rectangle()
            .fill(.appLabel.opacity(0.25))
            .frame(width: 0.5, height: 32)
    }

    private func actionButton(_ title: String, color: Color = .appPrimary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appRegular(18))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MessagePopup: View {
    let title: String
    var message: String?
    var cancelTitle: String? = L10n.cancel
    var confirmTitle = L10n.ok
    var confirmColor: Color = .appPrimary
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        TransactionEditPopup(cancelTitle: cancelTitle, confirmTitle: confirmTitle, confirmColor: confirmColor, onCancel: onCancel, onConfirm: onConfirm) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.appMedium(18))
                    .foregroundColor(.appWhite)

                if let message {
                    Text(message)
                        .font(.appLight(15))
                        .foregroundColor(.appLabel)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }
}

struct TextInputPopup: View {
    let title: String
    let placeholder: String
    let confirmTitle: String
    let onCancel: () -> Void
    let onConfirm: (String) -> Void

    @State private var text = String()
    @FocusState private var isFocused: Bool

    init(title: String, placeholder: String, confirmTitle: String, onCancel: @escaping () -> Void, onConfirm: @escaping (String) -> Void) {
        self.title = title
        self.placeholder = placeholder
        self.confirmTitle = confirmTitle
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }

    var body: some View {
        TransactionEditPopup(canConfirm: !text.isBlank, confirmTitle: confirmTitle, onCancel: cancel, onConfirm: confirm) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.appMedium(18))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.appLabel.opacity(0.6)))
                    .focused($isFocused)
                    .font(.appRegular(18))
                    .foregroundColor(.appWhite)
                    .tint(.appPrimary)
                    .submitLabel(.done)
                    .onSubmit(submit)
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            isFocused = true
        }
    }

    private func submit() {
        guard !text.isBlank else { return }
        confirm()
    }

    private func cancel() {
        isFocused = false
        onCancel()
    }

    private func confirm() {
        isFocused = false
        onConfirm(text.trimmingCharacters(in: .whitespacesAndNewlines))
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
            withAnimation(.appStandard) {
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

#Preview("Message popup") {
    MessagePopup(title: "Remove category", message: "The category and all its transactions will be moved to the Trash.", confirmTitle: "Remove", confirmColor: .appRed, onCancel: {}, onConfirm: {})
        .background(.appMain)
}

#Preview("Text input popup") {
    TextInputPopup(title: "New folder category", placeholder: "Enter name", confirmTitle: "Create", onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}

#Preview("Time popup") {
    TransactionTimePopup(time: Date(), onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}

#Preview("Date popup") {
    TransactionDatePopup(date: .yesterday, onCancel: {}, onConfirm: { _ in })
        .background(.appMain)
}
