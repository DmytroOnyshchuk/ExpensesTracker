//
//  DataSeeder.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift

final class DataSeeder: NSObject {
    static func seedDefaultAccount(in realm: Realm) {
        realm.update {
            let defaultAccount: Account
            if let first = realm.objects(Account.self).where(Account.notDeleted).sorted(byKeyPath: "sortIndex").first {
                defaultAccount = first
            } else {
                defaultAccount = Account(name: L10n.accountsDefaultName, checkpointDate: .distantPast)
                realm.add(defaultAccount)
            }

            for transaction in realm.objects(Transaction.self).where({ $0.account == nil }) {
                transaction.account = defaultAccount
            }
        }
    }

    static func seedDefaultCategories(in realm: Realm) {
        seedDefaultAccount(in: realm)

        let existingCategories = Array(realm.objects(TransactionCategory.self))

        seedIncomeCategories(in: realm, existingCategories: existingCategories)

        if existingCategories.isEmpty {
            let food = TransactionCategory(name: .food, categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
            let car = TransactionCategory(name: .car, categoryIcon: CategoryIcon(name: "car.fill", iconColor: .pink), isDirectory: true)
            let house = TransactionCategory(name: .home, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .yellow), isDirectory: true)
            let folders = [food, car, house]
            for (index, folder) in folders.enumerated() {
                folder.sortIndex = index
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
            }

            realm.update {
                realm.add(folders)
                realm.add(defaultCategories)
            }
            Logger.default.logMessage("Default categories seeded", category: className)
        }
    }

    private static func seedIncomeCategories(in realm: Realm, existingCategories: [TransactionCategory]) {
        guard existingCategories.of(.income).isEmpty else { return }

        let incomeCategories = [
            TransactionCategory(name: .salary, categoryIcon: CategoryIcon(name: "briefcase.fill", iconColor: .green), operationType: .income),
            TransactionCategory(name: .savings, categoryIcon: CategoryIcon(name: "banknote.fill", iconColor: .mint), operationType: .income),
        ]

        for (index, category) in incomeCategories.enumerated() {
            category.sortIndex = index
        }

        realm.update {
            realm.add(incomeCategories)
        }
        Logger.default.logMessage("Income categories seeded", category: className)
    }
}
