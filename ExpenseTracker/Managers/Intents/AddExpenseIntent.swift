import AppIntents
import Foundation
import SwiftData

struct AddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Expense"
    static let description: IntentDescription? = IntentDescription("Adds an expense. Use it in a Wallet transaction automation to record every Apple Pay payment.")
    static let openAppWhenRun = false

    @Parameter(title: "Amount")
    var amount: String

    @Parameter(title: "Merchant")
    var merchant: String?

    @Parameter(title: "Card")
    var card: String?

    @Parameter(title: "Category")
    var category: CategoryEntity?

    @Parameter(title: "Account")
    var account: AccountEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Add expense of \(\.$amount) at \(\.$merchant)") {
            \.$card
            \.$category
            \.$account
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let value = AmountInput.amount(fromCurrencyText: amount)
        guard value != .zero else { throw AddExpenseError.invalidAmount }

        let context = ModelContainer.shared.mainContext
        let merchantName = merchant?.trimmingCharacters(in: .whitespacesAndNewlines) ?? String()
        guard let expenseCategory = context.expenseCategory(id: category?.id, merchant: merchantName) else { throw AddExpenseError.categoryNotFound }

        let expenseAccount = context.expenseAccount(id: account?.id, card: card)
        context.add(Transaction(amount: value, category: expenseCategory, note: merchantName.isEmpty ? nil : merchantName, account: expenseAccount))
        try context.save()
        return .result()
    }
}

enum AddExpenseError: Error, CustomLocalizedStringResourceConvertible {
    case invalidAmount
    case categoryNotFound

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidAmount: "The amount could not be recognized."
        case .categoryNotFound: "There is no expense category to add the transaction to."
        }
    }
}

extension ModelContext {
    fileprivate func expenseCategory(id: UUID?, merchant: String) -> TransactionCategory? {
        let categories = ((try? fetch(FetchDescriptor<TransactionCategory>(predicate: TransactionCategory.nonDirectories))) ?? []).of(.outcome)
        if let id, let chosen = categories.first(where: { $0.uuid == id }) {
            return chosen
        }
        if let remembered = lastCategory(for: merchant, among: categories) {
            return remembered
        }
        return categories.first { $0.name == .other } ?? categories.inDisplayOrder.first
    }

    fileprivate func expenseAccount(id: UUID?, card: String?) -> Account? {
        let accounts = (try? fetch(FetchDescriptor<Account>(predicate: Account.available, sortBy: [SortDescriptor(\.sortIndex)]))) ?? []
        if let id, let chosen = accounts.first(where: { $0.uuid == id }) {
            return chosen
        }
        if let card, let matching = accounts.first(where: { card.localizedCaseInsensitiveContains($0.name) }) {
            return matching
        }
        let selectedId = UserDefaults.shared.string(forKey: UDKey.selectedAccount.rawValue)
        return accounts.first { $0.uuid.uuidString == selectedId } ?? accounts.first
    }

    private func lastCategory(for merchant: String, among categories: [TransactionCategory]) -> TransactionCategory? {
        guard !merchant.isEmpty else { return nil }

        var descriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.deletedAt == nil && $0.note == merchant }, sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 10
        let recent = (try? fetch(descriptor)) ?? []
        let allowed = Set(categories.map(\.uuid))
        return recent.first { allowed.contains($0.category.uuid) }?.category
    }
}
