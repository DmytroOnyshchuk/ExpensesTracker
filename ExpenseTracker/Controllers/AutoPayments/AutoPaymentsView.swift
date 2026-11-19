//
//  AutoPaymentsView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct AutoPaymentsView: View {
    @Query(filter: AutoPayment.active) private var storedAutoPayments: [AutoPayment]

    @State private var showAddAutoPayment = false
    @State private var selectedAutoPayment: AutoPayment?

    private var autoPayments: [AutoPayment] { storedAutoPayments.inDisplayOrder }

    var body: some View {
        let autoPayments = autoPayments

        ScrollView(.vertical) {
            if autoPayments.isEmpty {
                Text(L10n.autopaymentsEmpty)
                    .font(.appLight(18))
                    .foregroundColor(.appGray.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
            } else {
                VStack(spacing: 0) {
                    ForEach(autoPayments, id: \.uuid) { autoPayment in
                        AutoPaymentRow(autoPayment: autoPayment) {
                            selectedAutoPayment = autoPayment
                        }

                        if autoPayment.uuid != autoPayments.last?.uuid {
                            InsetDivider()
                        }
                    }
                }
                .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                .padding(16)
            }
        }
        .appBackground()
        .navigationTitle(L10n.menuAutopayments)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddAutoPayment = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.appWhite)
                }
            }
        }
        .sheet(isPresented: $showAddAutoPayment) {
            AutoPaymentEdit()
        }
        .sheet(item: $selectedAutoPayment) { autoPayment in
            AutoPaymentEdit(autoPayment: autoPayment)
        }
    }
}

struct AutoPaymentRow: View {
    let autoPayment: AutoPayment
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let category = autoPayment.category {
                    category.categoryIcon.image
                        .font(.system(size: 22))
                        .foregroundColor(category.categoryIcon.color)
                        .frame(width: 36, height: 36)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(autoPayment.category?.name.localized ?? String())
                        .font(.appLight(18))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 8)

                Text(autoPayment.displayAmount)
                    .font(.appRegular(18))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .frame(height: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        [autoPayment.periodTitle, autoPayment.nextDate.dayString(.dateTime.day().month(.abbreviated).year())].joined(separator: " · ")
    }
}

#Preview("Autopayments") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(3).enumerated() {
        container.mainContext.insert(AutoPayment(amount: (index + 1) * 15000, category: category, periodCount: index + 1, periodUnit: AutoPaymentPeriodUnit.allCases[index + 1], startDate: Date().adding(index + 1, .day)))
    }

    return NavigationStack {
        AutoPaymentsView()
    }
    .modelContainer(container)
}

#Preview("Empty autopayments") {
    NavigationStack {
        AutoPaymentsView()
    }
    .modelContainer(makePreviewModelContainer())
}
