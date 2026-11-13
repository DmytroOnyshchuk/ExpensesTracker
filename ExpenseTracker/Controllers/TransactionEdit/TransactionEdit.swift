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
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    header
                    transactionSummary

                    VStack(spacing: 0) {
                        row(L10n.transactionEditDate) {
                            isAmountFocused = false
                            popup = .date
                        } value: {
                            valueText(draft.date.dayString(.dateTime.day().month(.wide).year()))
                        }
                        separator.padding(.leading, 16)

                        row(L10n.transactionEditTime) {
                            isAmountFocused = false
                            popup = .time
                        } value: {
                            valueText(draft.date.formatted(date: .omitted, time: .shortened))
                        }
                    }
                    .padding(.vertical, 6)
                    .background(.appLabel.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(spacing: 0) {
                        commentRow
                    }
                    .padding(.vertical, 6)
                    .background(.appLabel.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    deleteButton
                        .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(.appMain)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
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
                    amountText = AmountInput.text(from: draft.amount)
                }
            }
            .onChange(of: amountText) { _, text in
                if isAmountFocused {
                    draft.amount = AmountInput.amount(from: text)
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

    private var header: some View {
        HStack(spacing: 12) {
            headerIconButton(systemImage: "xmark", label: L10n.cancel) { dismiss() }

            Spacer(minLength: 0)

            Button(action: save) {
                Text(L10n.save)
                    .font(.appLight(17))
                    .foregroundColor(.appWhite)
                    .padding(.horizontal, 22)
                    .frame(height: 56)
                    .background(.appBlack.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(.appPrimary.opacity(0.22), lineWidth: 1))
            }
            .disabled(!draft.canSave)
            .opacity(draft.canSave ? 1 : 0.5)
        }
    }

    private var transactionSummary: some View {
        VStack(spacing: 12) {
            Button {
                isAmountFocused = false
                showCategoryPicker = true
            } label: {
                VStack(spacing: 12) {
                    draft.category.categoryIcon.image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(draft.category.categoryIcon.color)
                        .frame(width: 42, height: 42)
                        .frame(width: 88, height: 88)
                        .background(.appBlack.opacity(0.2))
                        .clipShape(Circle())

                    Text(draft.category.name.localized)
                        .font(.appLight(20))
                        .foregroundColor(.appWhite)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            amountField
                .frame(height: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func headerIconButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.appWhite)
                .frame(width: 56, height: 56)
                .background(.appBlack.opacity(0.2))
                .clipShape(Circle())
                .overlay(Circle().stroke(.appPrimary.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var separator: some View {
        Rectangle()
            .fill(.appSecond)
            .frame(height: 1)
    }

    private var deleteButton: some View {
        Button {
            isAmountFocused = false
            delete()
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.appRed)
                .frame(width: 60, height: 60)
                .background(.appRed.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.transactionEditDelete)
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
        ZStack {
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)
                .font(.appRegular(40))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
                .opacity(isAmountFocused ? 1 : 0)

            valueText(draft.amount.getAmount())
                .font(.appRegular(40))
                .opacity(isAmountFocused ? 0 : 1)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onTapGesture { isAmountFocused = true }
    }

    private func valueText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.appWhite)
            .lineLimit(1)
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
