import Foundation
import RealmSwift

extension Realm {
    private static let isConfigured: Bool = {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        do {
            try DataSeeder.seedDefaultCategories(in: Realm())
        } catch {
            Logger.default.logError("Failed to open Realm:", error: error, category: "Application")
            fatalError("Failed to open Realm: \(error)")
        }
        return true
    }()

    static var shared: Realm {
        guard isConfigured else { fatalError("Realm is not configured") }
        do {
            return try Realm()
        } catch {
            Logger.default.logError("Failed to open Realm:", error: error, category: "Application")
            fatalError("Failed to open Realm: \(error)")
        }
    }

    func update(_ changes: () -> Void) {
        if isInWriteTransaction {
            changes()
            return
        }
        do {
            try write(changes)
        } catch {
            Logger.default.logError("Failed to write to Realm", error: error, category: "Realm")
        }
    }
}

extension ThreadConfined {
    var live: Self? {
        if isInvalidated { return nil }
        return isFrozen ? thaw() : self
    }
}
