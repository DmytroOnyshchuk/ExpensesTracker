//
//  TransactionEdit.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct TransactionEdit: View {
    private enum Popup {
        case date
        case time
        case comment
    }

    private let transaction: Transaction

    @State private var draft: TransactionDraft
    @State private var popup: Popup?
    @State private var showCategoryPicker = false
    @State private var amountText = ""
    @FocusState private var isAmountFocused: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    init(transaction: Transaction) {
        self.transaction = transaction
        _draft = State(initialValue: TransactionDraft(transaction))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                row(L10n.transactionEditCategory) {
                    isAmountFocused = false
                    showCategoryPicker = true
                } value: {
                    valueText(draft.category.name.localized)
                }
                separator
                    .padding(.leading, 16)

                row(L10n.transactionEditAmount) {
                    isAmountFocused = true
                } value: {
                    amountField
                }
                separator
                    .padding(.leading, 16)

                row(L10n.transactionEditDate) {
                    isAmountFocused = false
                    popup = .date
                } value: {
                    valueText(draft.date.dayString(.dateTime.day().month(.wide).year()))
                }
                separator
                    .padding(.leading, 16)

                row(L10n.transactionEditTime) {
                    isAmountFocused = false
                    popup = .time
                } value: {
                    valueText(draft.date.formatted(date: .omitted, time: .shortened))
                }
                separator
                    .padding(.leading, 16)

                commentRow
                separator

                deleteButton
                    .padding(.top, 24)

                Spacer(minLength: 16)
            }
            .background(.appMain)
            .navigationTitle(L10n.transactionEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.appLabel)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.ok, action: save)
                        .foregroundColor(.appLabel)
                        .disabled(!draft.canSave)
                }

                if isAmountFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button(L10n.done) {
                            isAmountFocused = false
                        }
                    }
                }
            }
            .onChange(of: isAmountFocused) { _, isFocused in
                if isFocused {
                    amountText = text(from: draft.amount)
                }
            }
            .onChange(of: amountText) { _, text in
                if isAmountFocused {
                    draft.amount = amount(from: text)
                }
            }
            .navigationDestination(isPresented: $showCategoryPicker) {
                TransactionCategoryPicker { category in
                    draft.category = category
                    showCategoryPicker = false
                }
            }
        }
        .overlay {
            popupView
        }
        .animation(.easeInOut(duration: 0.2), value: popup)
    }

    private var separator: some View {
        Rectangle()
            .fill(.appSecond)
            .frame(height: 1)
    }

    private var commentRow: some View {
        Button {
            isAmountFocused = false
            popup = .comment
        } label: {
            HStack(spacing: 12) {
                Text(draft.comment.isBlank ? L10n.transactionEditAddComment : draft.comment)
                    .font(.appLight(draft.comment.isBlank ? 18 : 20))
                    .foregroundColor(draft.comment.isBlank ? .appLabel : .appWhite)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appLabel)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var deleteButton: some View {
        Button {
            isAmountFocused = false
            delete()
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 60, height: 60)
                .background(.red.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.transactionEditDelete)
    }

    @ViewBuilder
    private var popupView: some View {
        switch popup {
        case .date:
            TransactionDatePopup(date: draft.date, onCancel: closePopup) { date in
                draft.date = combined(day: date, time: draft.date)
                closePopup()
            }
            .transition(.opacity)
        case .time:
            TransactionTimePopup(time: draft.date, onCancel: closePopup) { time in
                draft.date = combined(day: draft.date, time: time)
                closePopup()
            }
            .transition(.opacity)
        case .comment:
            CommentInputView(
                comment: $draft.comment,
                isPresented: Binding(
                    get: { popup == .comment },
                    set: { isPresented in
                        if !isPresented {
                            closePopup()
                        }
                    }
                )
            )
            .transition(.opacity)
        case nil:
            EmptyView()
        }
    }

    private var amountField: some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)
                .font(.appLight(20))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.trailing)
                .opacity(isAmountFocused ? 1 : 0)

            valueText(draft.amount.getAmount())
                .opacity(isAmountFocused ? 0 : 1)
                .allowsHitTesting(false)
        }
    }

    private func valueText(_ text: String) -> some View {
        Text(text)
            .font(.appLight(20))
            .foregroundColor(.appWhite)
            .lineLimit(1)
    }

    private func text(from amount: Int) -> String {
        guard amount > 0 else { return "" }

        let fraction = amount % 100
        guard fraction != 0 else { return String(amount / 100) }

        let text = String(format: "%d.%02d", amount / 100, fraction)
        return text.hasSuffix("0") ? String(text.dropLast()) : text
    }

    private func amount(from text: String) -> Int {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else { return 0 }

        var scaled = value * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .plain)
        return max(NSDecimalNumber(decimal: rounded).intValue, 0)
    }

    private func row(
        _ title: String,
        action: @escaping () -> Void,
        @ViewBuilder value: () -> some View
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.appLight(18))
                    .foregroundColor(.appLabel)

                Spacer(minLength: 8)

                value()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appLabel)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func combined(day: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: components.second ?? 0,
            of: day
        ) ?? day
    }

    private func closePopup() {
        popup = nil
    }

    private func save() {
        draft.apply(to: transaction)
        try? modelContext.save()
        dismiss()
    }

    private func delete() {
        modelContext.deleteWithUndo(transaction)
        dismiss()
    }
}

#Preview {
    let container = makePreviewModelContainer()
    let category = TransactionCategory(name: "Supermarket", categoryIcon: CategoryIcon(name: "cart", iconColor: .green))
    let transaction = Transaction(amount: 36000, category: category, date: .yesterday)
    container.mainContext.insert(category)
    container.mainContext.insert(transaction)

    return TransactionEdit(transaction: transaction)
        .modelContainer(container)
}
