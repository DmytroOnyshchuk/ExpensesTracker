//
//  DataSeeder.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData

final class DataSeeder: NSObject {
    static func seedDefaultCategories(container: ModelContainer) {
        seedDefaultCategories(in: ModelContext(container))
    }

    static func seedDefaultAccount(in context: ModelContext) {
        let accounts = (try? context.fetch(FetchDescriptor<Account>(predicate: Account.notDeleted, sortBy: [SortDescriptor(\.sortIndex)]))) ?? []
        let transactions = (try? context.fetch(FetchDescriptor<Transaction>(predicate: Transaction.withoutAccount))) ?? []

        let defaultAccount: Account
        if let first = accounts.first {
            defaultAccount = first
        } else {
            defaultAccount = Account(name: L10n.accountsDefaultName, checkpointDate: .distantPast)
            context.insert(defaultAccount)
        }

        for transaction in transactions {
            transaction.account = defaultAccount
        }
        if !transactions.isEmpty {
            context.recalculateBalances()
        }

        do {
            try context.save()
        } catch {
            Logger.default.logError("Failed to seed default account", error: error, category: className)
        }
    }

    static func seedDefaultCategories(in context: ModelContext) {
        seedDefaultAccount(in: context)

        let descriptor = FetchDescriptor<TransactionCategory>()
        let existingCategories = (try? context.fetch(descriptor)) ?? []

        seedIncomeCategories(in: context, existingCategories: existingCategories)

        if existingCategories.isEmpty {
            let food = TransactionCategory(name: .food, categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
            let car = TransactionCategory(name: .car, categoryIcon: CategoryIcon(name: "car.fill", iconColor: .pink), isDirectory: true)
            let house = TransactionCategory(name: .home, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .yellow), isDirectory: true)
            let folders = [food, car, house]
            for (index, folder) in folders.enumerated() {
                folder.sortIndex = index
                context.insert(folder)
            }

            let defaultCategories = [
                TransactionCategory(name: .foodRestaurants, categoryIcon: CategoryIcon(name: "wineglass.fill", iconColor: .blue), parentUuid: food.uuid),
                TransactionCategory(name: .foodGroceries, categoryIcon: CategoryIcon(name: "cart.fill", iconColor: .yellow), parentUuid: food.uuid),
                TransactionCategory(name: .charity, categoryIcon: CategoryIcon(name: "heart.fill", iconColor: .red)),
                TransactionCategory(name: .carFuel, categoryIcon: CategoryIcon(name: "fuelpump.fill", iconColor: .pink), parentUuid: car.uuid),
                TransactionCategory(name: .family, categoryIcon: CategoryIcon(name: "person.2.fill", iconColor: .orange)),
                TransactionCategory(name: .homeHousehold, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .orange), parentUuid: house.uuid),
                TransactionCategory(name: .carMaintenance, categoryIcon: CategoryIcon(name: "car.fill", iconColor: .red), parentUuid: car.uuid),
                TransactionCategory(name: .healthBeauty, categoryIcon: CategoryIcon(name: "cross.case.fill", iconColor: .red)),
                TransactionCategory(name: .digitalServices, categoryIcon: CategoryIcon(name: "gamecontroller.fill", iconColor: .green)),
                TransactionCategory(name: .homeUtilities, categoryIcon: CategoryIcon(name: "lightbulb.fill", iconColor: .pink), parentUuid: house.uuid),
                TransactionCategory(name: .taxi, categoryIcon: CategoryIcon(name: "car.side.fill", iconColor: .yellow)),
                TransactionCategory(name: .publicTransit, categoryIcon: CategoryIcon(name: "bus.fill", iconColor: .teal)),
                TransactionCategory(name: .other, categoryIcon: CategoryIcon(name: "star.fill", iconColor: .blue)),
                TransactionCategory(name: .taxes, categoryIcon: CategoryIcon(name: "building.columns.fill", iconColor: .gray)),
                TransactionCategory(name: .repair, categoryIcon: CategoryIcon(name: "hammer.fill", iconColor: .brown)),
                TransactionCategory(name: .clothing, categoryIcon: CategoryIcon(name: "tshirt.fill", iconColor: .purple)),
                TransactionCategory(name: .electronics, categoryIcon: CategoryIcon(name: "tv.fill", iconColor: .indigo)),
                TransactionCategory(name: .carParking, categoryIcon: CategoryIcon(name: "parkingsign.circle.fill", iconColor: .blue), parentUuid: car.uuid),
                TransactionCategory(name: .pets, categoryIcon: CategoryIcon(name: "pawprint.fill", iconColor: .orange)),
                TransactionCategory(name: .savings, categoryIcon: CategoryIcon(name: "banknote.fill", iconColor: .mint)),
            ]

            for (index, category) in defaultCategories.enumerated() {
                category.sortIndex = folders.count + index
                context.insert(category)
            }

            do {
                try context.save()
                Logger.default.logMessage("Default categories seeded successfully", category: className)
            } catch {
                Logger.default.logError("Failed to seed default categories", error: error, category: className)
            }
        }
    }

    private static func seedIncomeCategories(in context: ModelContext, existingCategories: [TransactionCategory]) {
        guard existingCategories.of(.income).isEmpty else { return }

        let incomeCategories = [
            TransactionCategory(name: .salary, categoryIcon: CategoryIcon(name: "briefcase.fill", iconColor: .green), operationType: .income),
            TransactionCategory(name: .savings, categoryIcon: CategoryIcon(name: "banknote.fill", iconColor: .mint), operationType: .income),
        ]

        for (index, category) in incomeCategories.enumerated() {
            category.sortIndex = index
            context.insert(category)
        }

        do {
            try context.save()
            Logger.default.logMessage("Income categories seeded successfully", category: className)
        } catch {
            Logger.default.logError("Failed to seed income categories", error: error, category: className)
        }
    }
}
