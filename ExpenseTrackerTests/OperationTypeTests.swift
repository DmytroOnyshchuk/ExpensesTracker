//
//  OperationTypeTests.swift
//  ExpenseTrackerTests
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

@testable import ExpenseTracker
import SwiftData
import XCTest

final class OperationTypeTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Transaction.self, TransactionCategory.self, configurations: configuration)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
    }

    private func makeCategory(_ name: String, operationType: OperationType) -> TransactionCategory {
        let category = TransactionCategory(
            name: .custom(name),
            categoryIcon: CategoryIcon(name: "star", iconColor: .blue),
            operationType: operationType
        )
        context.insert(category)
        return category
    }

    private func makeTransaction(_ amount: Int, in category: TransactionCategory, date: Date = Date()) -> Transaction {
        let transaction = Transaction(amount: amount, category: category, date: date)
        context.insert(transaction)
        return transaction
    }

    func testCategoryIsOutcomeByDefault() {
        let category = TransactionCategory(name: "Cafe", categoryIcon: CategoryIcon(name: "star", iconColor: .blue))

        XCTAssertEqual(category.operationType, .outcome)
    }

    func testTransactionTakesOperationTypeFromCategory() {
        let salary = makeCategory("Salary", operationType: .income)
        let cafe = makeCategory("Cafe", operationType: .outcome)

        let income = makeTransaction(500000, in: salary)
        let expense = makeTransaction(12000, in: cafe)

        XCTAssertEqual(income.operationType, .income)
        XCTAssertEqual(income.signedAmount, 500000)
        XCTAssertEqual(expense.operationType, .outcome)
        XCTAssertEqual(expense.signedAmount, -12000)
        XCTAssertEqual([income, expense].of(.income).map(\.id), [income.id])
        XCTAssertEqual([salary, cafe].of(.outcome).map(\.uuid), [cafe.uuid])
    }

    func testBalanceGrowsWithIncomeAndShrinksWithExpenses() {
        let salary = makeCategory("Salary", operationType: .income)
        let cafe = makeCategory("Cafe", operationType: .outcome)
        let start = Date(timeIntervalSinceNow: -3600)
        let balance = Balance(amount: 100000, date: start)

        let transactions = [
            makeTransaction(500000, in: salary),
            makeTransaction(12000, in: cafe),
            makeTransaction(70000, in: salary, date: start.addingTimeInterval(-60)),
            makeTransaction(30000, in: cafe, date: start.addingTimeInterval(-60)),
        ]

        XCTAssertEqual(balance.remaining(after: transactions), 588000)
    }

    func testDraftKeepsOperationType() {
        let draft = CategoryDraft(operationType: .income)

        XCTAssertEqual(draft.makeCategory().operationType, .income)
        XCTAssertEqual(CategoryDraft(makeCategory("Salary", operationType: .income)).operationType, .income)
    }

    func testSeederAddsDefaultIncomeCategoriesOnce() throws {
        DataSeeder.seedDefaultCategories(in: context)
        DataSeeder.seedDefaultCategories(in: context)

        let income = try context.fetch(FetchDescriptor<TransactionCategory>()).of(.income)

        XCTAssertEqual(Set(income.map(\.name)), [.salary, .savings])
        XCTAssertEqual(income.count, 2)
    }
}
