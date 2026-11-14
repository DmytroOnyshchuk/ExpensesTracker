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
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<TransactionCategory>()
        let existingCategories = try? context.fetch(descriptor)

        if existingCategories?.isEmpty ?? true {
            let car = TransactionCategory(name: .car, categoryIcon: CategoryIcon(name: "car.fill", iconColor: .pink), isDirectory: true)
            let food = TransactionCategory(name: .food, categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
            let house = TransactionCategory(name: .home, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .yellow), isDirectory: true)
            context.insert(car)
            context.insert(food)
            context.insert(house)

            let defaultCategories = [
                TransactionCategory(name: .carMaintenance, categoryIcon: CategoryIcon(name: "car.fill", iconColor: .red), parentUuid: car.uuid),
                TransactionCategory(name: .carFuel, categoryIcon: CategoryIcon(name: "fuelpump.fill", iconColor: .pink), parentUuid: car.uuid),

                TransactionCategory(name: .foodRestaurants, categoryIcon: CategoryIcon(name: "wineglass.fill", iconColor: .blue), parentUuid: food.uuid),
                TransactionCategory(name: .foodGroceries, categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), parentUuid: food.uuid),

                TransactionCategory(name: .homeHousehold, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .orange), parentUuid: house.uuid),
                TransactionCategory(name: .homeUtilities, categoryIcon: CategoryIcon(name: "house.fill", iconColor: .pink), parentUuid: house.uuid),

                TransactionCategory(name: .clothing, categoryIcon: CategoryIcon(name: "tshirt.fill", iconColor: .purple)),

                TransactionCategory(name: .healthBeauty, categoryIcon: CategoryIcon(name: "cross.case.fill", iconColor: .red)),

                TransactionCategory(name: .other, categoryIcon: CategoryIcon(name: "star.fill", iconColor: .blue)),

                TransactionCategory(name: .charity, categoryIcon: CategoryIcon(name: "heart.fill", iconColor: .red)),
                TransactionCategory(name: .internet, categoryIcon: CategoryIcon(name: "gamecontroller.fill", iconColor: .green)),

                TransactionCategory(name: .transport, categoryIcon: CategoryIcon(name: "bus.fill", iconColor: .green)),
            ]

            for category in defaultCategories {
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
}
