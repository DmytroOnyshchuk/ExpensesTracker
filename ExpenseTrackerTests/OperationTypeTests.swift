//
//  OperationTypeTests.swift
//  ExpenseTrackerTests
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

@testable import ExpenseTracker
import RealmSwift
import XCTest

final class OperationTypeTests: XCTestCase {
    private func makeCategory(_ name: String, operationType: OperationType) -> TransactionCategory {
        TransactionCategory(name: .custom(name), categoryIcon: CategoryIcon(name: "star", iconColor: .blue), operationType: operationType)
    }

    private func makeTransaction(_ amount: Int, in category: TransactionCategory, date: Date = Date()) -> Transaction {
        Transaction(amount: amount, category: category, date: date)
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

        XCTAssertEqual(BalanceLedger(checkpoint: balance, transactions: transactions).current, 588000)
    }

    func testBalanceIsUnknownWithoutCheckpointAndIncome() {
        let cafe = makeCategory("Cafe", operationType: .outcome)

        XCTAssertNil(BalanceLedger(checkpoint: nil, transactions: [makeTransaction(12000, in: cafe)]).current)
    }

    func testBalanceWithoutCheckpointStartsFromFirstIncome() {
        let salary = makeCategory("Salary", operationType: .income)
        let cafe = makeCategory("Cafe", operationType: .outcome)
        let firstIncomeDate = Date(timeIntervalSinceNow: -3600)

        let transactions = [
            makeTransaction(90000, in: cafe, date: firstIncomeDate.addingTimeInterval(-60)),
            makeTransaction(500000, in: salary, date: firstIncomeDate),
            makeTransaction(12000, in: cafe),
            makeTransaction(70000, in: salary),
        ]

        XCTAssertEqual(BalanceLedger(checkpoint: nil, transactions: transactions).current, 558000)
    }

    func testDraftKeepsOperationType() {
        let draft = CategoryDraft(operationType: .income)

        XCTAssertEqual(draft.makeCategory().operationType, .income)
        XCTAssertEqual(CategoryDraft(makeCategory("Salary", operationType: .income)).operationType, .income)
    }

    func testSeederAddsDefaultIncomeCategoriesOnce() throws {
        let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: UUID().uuidString))
        DataSeeder.seedDefaultCategories(in: realm)
        DataSeeder.seedDefaultCategories(in: realm)

        let income = realm.objects(TransactionCategory.self).of(.income)

        XCTAssertEqual(Set(income.map(\.name)), [.salary, .savings])
        XCTAssertEqual(income.count, 2)
    }
}
