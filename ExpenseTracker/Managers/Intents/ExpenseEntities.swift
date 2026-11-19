import AppIntents
import Foundation
import RealmSwift

struct CategoryEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static let defaultQuery = CategoryEntityQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CategoryEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [CategoryEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [CategoryEntity] {
        let categories = Realm.shared.objects(TransactionCategory.self).where(TransactionCategory.nonDirectories)
        return categories.of(.outcome).inDisplayOrder.map { CategoryEntity(id: $0.uuid, name: $0.name.localized) }
    }
}

struct AccountEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Account"
    static let defaultQuery = AccountEntityQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct AccountEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [AccountEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    @MainActor
    func suggestedEntities() async throws -> [AccountEntity] {
        let accounts = Realm.shared.objects(Account.self).where(Account.available).sorted(byKeyPath: "sortIndex")
        return accounts.map { AccountEntity(id: $0.uuid, name: $0.name) }
    }
}
