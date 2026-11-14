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
    }

    private let transaction: Transaction

    @State private var draft: TransactionDraft
    @State private var popup: Popup?
    @State private var showCategoryPicker = false
    @State private var amountText = ""
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isCommentFocused: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    init(transaction: Transaction) {
        self.transaction = transaction
        _draft = State(initialValue: TransactionDraft(transaction))
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    header
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        row(L10n.transactionEditDate) {
                            isAmountFocused = false
                            isCommentFocused = false
                            popup = .date
                        } value: {
                            HStack(spacing: 8) {
                                valueText(draft.date.dayString(.dateTime.day().month(.wide).year()))
                                    .minimumScaleFactor(0.7)

                                valueText(draft.date.formatted(date: .omitted, time: .shortened))
                                    .padding(.horizontal, 10)
                                    .frame(height: 32)
                                    .background(.appLabel.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))

                    commentRow

                    deleteButton
                        .padding(.top, 8)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isAmountFocused || isCommentFocused {
                    keyboardDoneButton
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isAmountFocused || isCommentFocused)
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
        VStack(spacing: 12) {
            Button {
                isAmountFocused = false
                isCommentFocused = false
                showCategoryPicker = true
            } label: {
                VStack(spacing: 4) {
                    draft.category.categoryIcon.image
                        .font(.system(size: 44))
                        .foregroundColor(draft.category.categoryIcon.color)
                        .frame(width: 72, height: 72)

                    Text(draft.category.name.localized)
                        .font(.appLight(18))
                        .foregroundColor(.appLabel)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(draft.category.name.localized)

            amountField
        }
        .frame(maxWidth: .infinity)
    }

    private var commentRow: some View {
        TextField(
            "",
            text: $draft.comment,
            prompt: Text(L10n.transactionEditAddComment).foregroundColor(.appLabel),
            axis: .vertical
        )
        .lineLimit(3 ... 6)
        .focused($isCommentFocused)
        .font(.appLight(18))
        .foregroundColor(.appWhite)
        .tint(.appPrimary)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            isCommentFocused = true
        }
    }

    private var keyboardDoneButton: some View {
        Button {
            isAmountFocused = false
            isCommentFocused = false
        } label: {
            Text(L10n.done)
                .font(.appMedium(17))
                .foregroundColor(.appWhite)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .glassSurface(in: Capsule(), isInteractive: true, fallback: .appSecond)
                .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var deleteButton: some View {
        Button {
            isAmountFocused = false
            isCommentFocused = false
            delete()
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.appRed)
                .frame(width: 60, height: 60)
                .glassSurface(
                    in: Circle(),
                    tint: .appRed.opacity(0.15),
                    isInteractive: true,
                    fallback: .appRed.opacity(0.15)
                )
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
        case nil:
            EmptyView()
        }
    }

    private var amountField: some View {
        ZStack {
            TextField("", text: $amountText)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)
                .font(.appMedium(44))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
                .opacity(isAmountFocused ? 1 : 0)

            Text(draft.amount.getAmount())
                .font(.appMedium(44))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .opacity(isAmountFocused ? 0 : 1)
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .contentShape(Rectangle())
        .onTapGesture {
            isAmountFocused = true
        }
    }

    private func valueText(_ text: String) -> some View {
        Text(text)
            .font(.appLight(18))
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
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func combined(day: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(
            bySettingHour: components.hour ?? .zero,
            minute: components.minute ?? .zero,
            second: components.second ?? .zero,
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
