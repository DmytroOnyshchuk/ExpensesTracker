import Foundation
import SwiftData

extension ModelContainer {
    static let shared: ModelContainer = {
        do {
            let container = try ModelContainer(for: Transaction.self, TransactionCategory.self, Account.self, AutoPayment.self)
            DataSeeder.seedDefaultCategories(container: container)
            return container
        } catch {
            Logger.default.logError("Failed to initialize model container:", error: error, category: "Application")
            fatalError("Failed to initialize model container: \(error)")
        }
    }()
}
