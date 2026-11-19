//
//  AutoPaymentEdit.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct AutoPaymentEdit: View {
    private enum Popup {
        case period
        case date
    }

    private let autoPayment: AutoPayment?

    @State private var draft: AutoPaymentDraft?
    @State private var popup: Popup?
    @State private var pickerOperationType: OperationType?
    @State private var amountText = String()
    @Query(filter: Account.notDeleted, sort: \Account.sortIndex) private var storedAccounts: [Account]

    @StoredSettings private var appSettings

    @FocusState private var isAmountFocused: Bool
    @FocusState private var isNoteFocused: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private var accounts: [Account] { storedAccounts.filter { !$0.isDisabled || $0.uuid == current.account?.uuid } }
    private var current: AutoPaymentDraft { draft ?? AutoPaymentDraft(account: storedAccounts.enabled.first) }
    private var isKeyboardShown: Bool { isAmountFocused || isNoteFocused }

    private var draftBinding: Binding<AutoPaymentDraft> {
        Binding(get: { current }, set: { draft = $0 })
    }

    private var operationTypeBinding: Binding<OperationType> {
        Binding(get: { current.operationType }, set: { draftBinding.wrappedValue.setOperationType($0) })
    }

    init(autoPayment: AutoPayment? = nil) {
        self.autoPayment = autoPayment
        _draft = State(initialValue: autoPayment.map(AutoPaymentDraft.init))
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    if appSettings.accounting.incomeEnabled {
                        SegmentedControl(items: OperationType.allCases, selection: operationTypeBinding, title: \.title)
                            .sensoryFeedback(trigger: current.operationType) { _, _ in FeedbackManager.shared.selectionFeedback }
                            .padding(.horizontal, 64)
                    }

                    header
                        .padding(.vertical, 8)

                    VStack(spacing: 0) {
                        if appSettings.accounting.multipleAccountsEnabled {
                            accountRow

                            InsetDivider()
                        }

                        row(L10n.autopaymentsPeriod, popup: .period) {
                            valueText(current.periodTitle)
                        }

                        InsetDivider()

                        row(L10n.autopaymentsStartDate, popup: .date) {
                            valueText(current.startDate.dayString(.dateTime.day().month(.wide).year()))
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))

                    noteRow

                    if autoPayment != nil {
                        deleteButton
                            .padding(.top, 8)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isKeyboardShown {
                    KeyboardDoneButton(action: hideKeyboard)
                        .transition(.opacity)
                }
            }
            .animation(.appStandard, value: isKeyboardShown)
            .appBackground()
            .navigationTitle(autoPayment == nil ? L10n.autopaymentsNewTitle : L10n.transactionEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.appWhite)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.ok, action: save)
                        .foregroundColor(.appWhite)
                        .disabled(!current.canSave)
                }
            }
            .onChange(of: isAmountFocused) { _, isFocused in
                if isFocused {
                    amountText = AmountInput.text(from: current.amount)
                }
            }
            .onChange(of: amountText) { _, text in
                if isAmountFocused {
                    draftBinding.wrappedValue.amount = AmountInput.amount(from: text)
                }
            }
            .navigationDestination(item: $pickerOperationType) { operationType in
                TransactionCategoryPicker(operationType: operationType) { category in
                    draftBinding.wrappedValue.category = category
                    pickerOperationType = nil
                }
            }
        }
        .overlay {
            popupView
        }
        .animation(.appStandard, value: popup)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Button {
                hideKeyboard()
                pickerOperationType = current.operationType
            } label: {
                VStack(spacing: 4) {
                    categoryIcon
                        .font(.system(size: 44))
                        .frame(width: 72, height: 72)

                    Text(current.category?.name.localized ?? L10n.transactionEditCategory)
                        .font(.appLight(18))
                        .foregroundColor(current.category == nil ? .appPrimary : .appLabel)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(current.category?.name.localized ?? L10n.transactionEditCategory)

            amountField
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var categoryIcon: some View {
        if let icon = current.category?.categoryIcon {
            icon.image
                .foregroundColor(icon.color)
        } else {
            Image(systemName: "square.grid.2x2")
                .foregroundColor(.appPrimary)
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

            Text(current.amount.getAmount())
                .font(.appMedium(44))
                .foregroundColor(current.amount == .zero ? .appLabel : .appWhite)
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
        .accessibilityLabel(L10n.transactionEditAmount)
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
                        draftBinding.wrappedValue.account = account
                    } label: {
                        if account.uuid == current.account?.uuid {
                            Label(account.name, systemImage: "checkmark")
                        } else {
                            Text(account.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    valueText(current.account?.name ?? "—")

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appLabel)
                }
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }

    private var noteRow: some View {
        TextField("", text: draftBinding.note, prompt: Text(L10n.transactionEditAddNote).foregroundColor(.appLabel.opacity(0.6)), axis: .vertical)
            .lineLimit(3 ... 6)
            .focused($isNoteFocused)
            .font(.appLight(18))
            .foregroundColor(.appWhite)
            .tint(.appPrimary)
            .padding(16)
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .onTapGesture {
                isNoteFocused = true
            }
    }

    private var deleteButton: some View {
        RoundIconButton(systemImage: "trash", color: .appRed, tint: .appRed, action: delete)
            .accessibilityLabel(L10n.delete)
    }

    @ViewBuilder
    private var popupView: some View {
        switch popup {
        case .period:
            AutoPaymentPeriodPopup(count: current.periodCount, unit: current.periodUnit, onCancel: closePopup) { count, unit in
                draftBinding.wrappedValue.periodCount = count
                draftBinding.wrappedValue.periodUnit = unit
                closePopup()
            }
            .transition(.opacity)
        case .date:
            AutoPaymentDatePopup(date: current.startDate, onCancel: closePopup) { date in
                draftBinding.wrappedValue.startDate = Calendar.current.startOfDay(for: date)
                closePopup()
            }
            .transition(.opacity)
        case nil:
            EmptyView()
        }
    }

    private func valueText(_ text: String) -> some View {
        Text(text)
            .font(.appLight(18))
            .foregroundColor(.appWhite)
            .lineLimit(1)
    }

    private func row(_ title: String, popup: Popup, @ViewBuilder value: () -> some View) -> some View {
        Button {
            open(popup)
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .font(.appLight(18))
                    .foregroundColor(.appLabel)

                Spacer(minLength: 8)

                value()
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func open(_ popup: Popup) {
        hideKeyboard()
        self.popup = popup
    }

    private func closePopup() {
        popup = nil
    }

    private func hideKeyboard() {
        isAmountFocused = false
        isNoteFocused = false
    }

    private func save() {
        if let autoPayment {
            current.apply(to: autoPayment)
        } else if let autoPayment = current.makeAutoPayment() {
            modelContext.insert(autoPayment)
        }
        try? modelContext.save()
        modelContext.runAutoPayments()
        dismiss()
    }

    private func delete() {
        hideKeyboard()
        if let autoPayment {
            modelContext.deleteWithUndo(autoPayment)
        }
        dismiss()
    }
}

struct AutoPaymentPeriodPopup: View {
    let onCancel: () -> Void
    let onConfirm: (Int, AutoPaymentPeriodUnit) -> Void

    @State private var count: Int
    @State private var unit: AutoPaymentPeriodUnit

    init(count: Int, unit: AutoPaymentPeriodUnit, onCancel: @escaping () -> Void, onConfirm: @escaping (Int, AutoPaymentPeriodUnit) -> Void) {
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _count = State(initialValue: count)
        _unit = State(initialValue: unit)
    }

    var body: some View {
        TransactionEditPopup(onCancel: onCancel, onConfirm: { onConfirm(count, unit) }) {
            HStack(spacing: 0) {
                Picker("", selection: $count) {
                    ForEach(AutoPaymentDraft.periodCounts, id: \.self) { count in
                        Text(String(count)).tag(count)
                    }
                }
                .frame(width: 80)

                Picker("", selection: $unit) {
                    ForEach(AutoPaymentPeriodUnit.allCases) { unit in
                        Text(unit.name(count: count)).tag(unit)
                    }
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .padding(.horizontal, 16)
        }
    }
}

struct AutoPaymentDatePopup: View {
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
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
        }
    }
}

#Preview("New autopayment") {
    AutoPaymentEdit()
        .modelContainer(makePreviewModelContainer())
}

#Preview("Edit autopayment") {
    let container = makePreviewModelContainer()
    let category = TransactionCategory(name: "Rent", categoryIcon: CategoryIcon(name: "house.fill", iconColor: .orange))
    let autoPayment = AutoPayment(amount: 1200000, category: category, periodCount: 1, periodUnit: .month)
    container.mainContext.insert(category)
    container.mainContext.insert(autoPayment)

    return AutoPaymentEdit(autoPayment: autoPayment)
        .modelContainer(container)
}

#Preview("Period popup") {
    AutoPaymentPeriodPopup(count: 3, unit: .day, onCancel: {}, onConfirm: { _, _ in })
        .background(.appMain)
}
