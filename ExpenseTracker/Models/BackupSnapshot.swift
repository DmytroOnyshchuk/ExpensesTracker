import Foundation

struct BackupSnapshot: Codable {
    static let formatIdentifier = "expense-tracker-backup"
    static let currentVersion = 1

    var format: String = BackupSnapshot.formatIdentifier
    var version: Int = BackupSnapshot.currentVersion
    var createdAt: Date = .init()
    var categories: [BackupCategory]
    var transactions: [BackupTransaction]
    var balance: BackupBalance?
}

struct BackupCategory: Codable {
    var uuid: UUID
    var name: String
    var iconName: String
    var iconColor: String
    var customColorHex: String?
    var isDirectory: Bool
    var parentUuid: UUID?
    var sortIndex: Int
}

struct BackupTransaction: Codable {
    var id: UUID
    var amount: Int
    var date: Date
    var note: String?
    var categoryUuid: UUID
}

struct BackupBalance: Codable {
    var amount: Int
    var date: Date
}

enum BackupSource {
    case native
    case mok
}

enum BackupError: Error {
    case unsupportedFormat
    case newerVersion
    case corrupted
}

struct ImportedBackup: Identifiable {
    let id = UUID()
    let snapshot: BackupSnapshot
    let source: BackupSource
    let skippedTransactions: Int

    var dateRange: ClosedRange<Date>? {
        let dates = snapshot.transactions.map(\.date)
        guard let first = dates.min(), let last = dates.max() else { return nil }
        return first ... last
    }
}
