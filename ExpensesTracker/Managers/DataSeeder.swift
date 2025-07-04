//
//  DataSeeder.swift
//  ExpensesTracker
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
                TransactionCategory(name: "Обслужива...\nАвто", icon: "car.fill", colorName: "red"),
                TransactionCategory(name: "Топливо\nАвто", icon: "fuelpump.fill", colorName: "pink"),
                TransactionCategory(name: "Рестораны\nЕда", icon: "wineglass.fill", colorName: "blue"),
                TransactionCategory(name: "Еда домой\nЕда", icon: "fork.knife", colorName: "yellow"),
                TransactionCategory(name: "Быт\nДом", icon: "house.fill", colorName: "orange"),
                TransactionCategory(name: "Коммуналь...\nДом", icon: "house.fill", colorName: "pink"),
                TransactionCategory(name: "Одежда", icon: "tshirt.fill", colorName: "purple"),
                TransactionCategory(name: "Красота и з...", icon: "bag.fill", colorName: "red"),
                TransactionCategory(name: "Транспорт", icon: "bus.fill", colorName: "green"),
                TransactionCategory(name: "Развлечения", icon: "gamecontroller.fill", colorName: "purple"),
                TransactionCategory(name: "Здоровье", icon: "cross.fill", colorName: "red"),
                TransactionCategory(name: "Образование", icon: "book.fill", colorName: "blue")
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
