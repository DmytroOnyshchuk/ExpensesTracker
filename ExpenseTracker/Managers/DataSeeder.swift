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
            let defaultCategories = [
                TransactionCategory(name: "Обслуживание", categoryIcon: CategoryIcon(name: "car.fill", iconColor: .red)),
                TransactionCategory(name: "Топливо", categoryIcon: CategoryIcon(name: "fuelpump.fill", iconColor: .pink)),
                TransactionCategory(name: "Рестораны", categoryIcon: CategoryIcon(name: "wineglass.fill", iconColor: .blue)),
                TransactionCategory(name: "Еда домой", categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow)),
                TransactionCategory(name: "Быт", categoryIcon: CategoryIcon(name: "house.fill", iconColor: .orange)),
                TransactionCategory(name: "Коммуналь", categoryIcon: CategoryIcon(name: "house.fill", iconColor: .pink)),
                TransactionCategory(name: "Одежда", categoryIcon: CategoryIcon(name: "tshirt.fill", iconColor: .purple)),
                TransactionCategory(name: "Красота и здоровье", categoryIcon: CategoryIcon(name: "bag.fill", iconColor: .red)),
                TransactionCategory(name: "Транспорт", categoryIcon: CategoryIcon(name: "bus.fill", iconColor: .green)),
                TransactionCategory(name: "Развлечения", categoryIcon: CategoryIcon(name: "gamecontroller.fill", iconColor: .purple)),
                TransactionCategory(name: "Здоровье", categoryIcon: CategoryIcon(name: "cross.fill", iconColor: .red)),
                TransactionCategory(name: "Образование", categoryIcon: CategoryIcon(name: "book.fill", iconColor: .blue))
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
