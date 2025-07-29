//
//  Application.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

@main
struct ExpenseTracker: App {
    var body: some Scene {
        WindowGroup {
            StartView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Transaction.self, TransactionCategory.self]) { result in
            switch result {
                case .success(let container):
                    // Предзаполнение данных при первом запуске
                    DataSeeder.seedDefaultCategories(container: container)
                case .failure(let error):
                    Logger.default.errorLog("Failed to initialize model container:", error: error, category: "Application")
            }
        }
    }
}
