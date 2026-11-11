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
            let car = TransactionCategory(name: "Авто", categoryIcon: CategoryIcon(name: "car", iconColor: .pink), isDirectory: true)
            let food = TransactionCategory(name: "Еда", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
            let house = TransactionCategory(name: "Дом", categoryIcon: CategoryIcon(name: "house", iconColor: .yellow), isDirectory: true)
            context.insert(car)
            context.insert(food)
            context.insert(house)

            let defaultCategories = [
                TransactionCategory(name: "Обслуживание", categoryIcon: CategoryIcon(name: "car", iconColor: .red), parentUuid: car.uuid),
                TransactionCategory(name: "Топливо", categoryIcon: CategoryIcon(name: "fuelpump", iconColor: .pink), parentUuid: car.uuid),

                TransactionCategory(name: "Рестораны", categoryIcon: CategoryIcon(name: "wineglass", iconColor: .blue), parentUuid: food.uuid),
                TransactionCategory(name: "Еда домой", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), parentUuid: food.uuid),

                TransactionCategory(name: "Быт", categoryIcon: CategoryIcon(name: "house", iconColor: .orange), parentUuid: house.uuid),
                TransactionCategory(name: "Коммунальные услуги", categoryIcon: CategoryIcon(name: "house", iconColor: .pink), parentUuid: house.uuid),

                TransactionCategory(name: "Одежда", categoryIcon: CategoryIcon(name: "tshirt", iconColor: .purple)),

                TransactionCategory(name: "Красота и здоровье", categoryIcon: CategoryIcon(name: "cross.case", iconColor: .red)),

                TransactionCategory(name: "Другое", categoryIcon: CategoryIcon(name: "star", iconColor: .blue)),

                TransactionCategory(name: "Благотворительность", categoryIcon: CategoryIcon(name: "heart", iconColor: .red)),
                TransactionCategory(name: "Интернет", categoryIcon: CategoryIcon(name: "gamecontroller", iconColor: .green)),

                TransactionCategory(name: "Транспорт", categoryIcon: CategoryIcon(name: "bus", iconColor: .green)),
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
