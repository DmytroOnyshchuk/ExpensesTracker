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
    @State private var amountText = String()
    @Query(sort: \Account.sortIndex) private var storedAccounts: [Account]

    @StoredSettings private var appSettings

    private var accounts: [Account] { storedAccounts.notDeleted }
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isNoteFocused: Bool

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
                        if appSettings.accounting.multipleAccountsEnabled {
                            accountRow

                            InsetDivider()
                        }

                        row(L10n.transactionEditDate) {
                            isAmountFocused = false
                            isNoteFocused = false
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

                    noteRow

                    deleteButton
                        .padding(.top, 8)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isAmountFocused || isNoteFocused {
                    keyboardDoneButton
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isAmountFocused || isNoteFocused)
            .appBackground()
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
                TransactionCategoryPicker(operationType: draft.category.operationType) { category in
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
                isNoteFocused = false
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

    private var noteRow: some View {
        TextField(
            "",
            text: $draft.note,
            prompt: Text(L10n.transactionEditAddNote).foregroundColor(.appLabel),
            axis: .vertical
        )
        .lineLimit(3 ... 6)
        .focused($isNoteFocused)
        .font(.appLight(18))
        .foregroundColor(.appWhite)
        .tint(.appPrimary)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            isNoteFocused = true
        }
    }

    private var accountRow: some View {
        HStack(spacing: 12) {
            Text(L10n.transactionEditBalance)
                .font(.appLight(18))
                .foregroundColor(.appLabel)

            Spacer(minLength: 8)

            Menu {
                ForEach(accounts, id: \.uuid) { account in
                    Button {
                        draft.account = account
                    } label: {
                        if account.uuid == draft.account?.uuid {
                            Label(account.name, systemImage: "checkmark")
                        } else {
                            Text(account.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    valueText(draft.account?.name ?? "—")

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appLabel)
                }
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }

    private var keyboardDoneButton: some View {
        KeyboardDoneButton {
            isAmountFocused = false
            isNoteFocused = false
        }
    }

    private var deleteButton: some View {
        Button {
            isAmountFocused = false
            isNoteFocused = false
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
        modelContext.applyWithUndo(draft, to: transaction)
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
