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
            let car = TransactionCategory(name: "Авто", categoryIcon: CategoryIcon(name: "car.fill", iconColor: .pink), isDirectory: true)
            let food = TransactionCategory(name: "Еда", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), isDirectory: true)
            let house = TransactionCategory(name: "Дом",  categoryIcon: CategoryIcon(name: "house.fill", iconColor: .yellow), isDirectory: true)
            context.insert(car)
            context.insert(food)
            context.insert(house)
            
            let defaultCategories = [
                TransactionCategory(name: "Обслуживание", categoryIcon: CategoryIcon(name: "car.fill", iconColor: .red), parent: car),
                TransactionCategory(name: "Топливо", categoryIcon: CategoryIcon(name: "fuelpump.fill", iconColor: .pink), parent: car),
                
                TransactionCategory(name: "Рестораны", categoryIcon: CategoryIcon(name: "wineglass.fill", iconColor: .blue), parent: food),
                TransactionCategory(name: "Еда домой", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow), parent: food),
                
                TransactionCategory(name: "Быт", categoryIcon: CategoryIcon(name: "house.fill", iconColor: .orange), parent: house),
                TransactionCategory(name: "Коммунальные услуги", categoryIcon: CategoryIcon(name: "house.fill", iconColor: .pink), parent: house),
                
                TransactionCategory(name: "Одежда", categoryIcon: CategoryIcon(name: "tshirt.fill", iconColor: .purple)),
                
                TransactionCategory(name: "Красота и здоровье", categoryIcon: CategoryIcon(name: "stethoscope", iconColor: .red)),
                
                TransactionCategory(name: "Другое", categoryIcon: CategoryIcon(name: "star", iconColor: .blue)),
                
                TransactionCategory(name: "Благо", categoryIcon: CategoryIcon(name: "heart", iconColor: .red)),
                TransactionCategory(name: "Интернет", categoryIcon: CategoryIcon(name: "gamecontroller.fill", iconColor: .green)),
                
                TransactionCategory(name: "Транспорт", categoryIcon: CategoryIcon(name: "bus.fill", iconColor: .green)),
            ]
            
            for category in defaultCategories {
                context.insert(category)
            }
            
            do {
                try context.save()
                Logger.default.logMessage("Default categories seeded successfully", category: self.className)
            } catch {
                Logger.default.errorLog("Failed to seed default categories", error: error, category: self.className)
            }
        }
    }
    
}
