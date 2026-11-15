import Foundation
import SwiftData

enum BackupExportFormat: CaseIterable, Identifiable {
    case json
    case csv
    case xlsx

    var id: Self { self }

    var fileExtension: String {
        switch self {
        case .json: "json"
        case .csv: "csv"
        case .xlsx: "xlsx"
        }
    }
}

extension BackupExportFormat {
    var title: String {
        switch self {
        case .json: "JSON"
        case .csv: "CSV"
        case .xlsx: "Excel"
        }
    }
    
    var summary: String {
        switch self {
        case .json: L10n.backupsFormatJson
        case .csv, .xlsx: L10n.backupsFormatCsv
        }
    }
}

enum BackupImportMode {
    case merge
    case replace
}

struct BackupImportResult {
    let transactions: Int
    let categories: Int
}

extension BackupError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat: L10n.backupsErrorUnsupported
        case .newerVersion: L10n.backupsErrorNewerVersion
        case .corrupted: L10n.backupsErrorCorrupted
        }
    }
}

enum BackupManager {
    private struct Header: Decodable {
        let format: String
        let version: Int
    }

    static var defaultFilename: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return "ExpenseTracker-\(formatter.string(from: Date()))"
    }

    private static var storedBalance: Balance? {
        get { Balance(jsonData: UserDefaults.standard.data(forKey: UDKey.balance.rawValue)) }
        set { UserDefaults.standard.set(newValue?.jsonData(), forKey: UDKey.balance.rawValue) }
    }

    @MainActor
    static func exportData(from context: ModelContext) throws -> Data {
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>())
        let transactions = try context.fetch(FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)]))

        let snapshot = BackupSnapshot(
            categories: categories.map { category in
                BackupCategory(
                    uuid: category.uuid,
                    name: category.name.rawValue,
                    iconName: category.categoryIcon.name,
                    iconColor: category.categoryIcon.iconColor.rawValue,
                    customColorHex: category.categoryIcon.customColorHex,
                    isDirectory: category.isDirectory,
                    parentUuid: category.parentUuid,
                    sortIndex: category.sortIndex
                )
            },
            transactions: transactions.map { transaction in
                BackupTransaction(
                    id: transaction.id,
                    amount: transaction.amount,
                    date: transaction.date,
                    comment: transaction.comment,
                    categoryUuid: transaction.category.uuid
                )
            },
            balance: storedBalance.map { BackupBalance(amount: $0.amount, date: $0.date) }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    @MainActor
    static func tableData(from context: ModelContext, format: BackupExportFormat) throws -> Data {
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>())
        let transactions = try context.fetch(FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)]))

        let rows = transactions.map { transaction in
            BackupTableRow(
                date: transaction.date,
                folder: transaction.category.parent(from: categories)?.name.localized ?? "",
                category: transaction.category.name.localized,
                amount: transaction.amount,
                comment: transaction.comment ?? ""
            )
        }
        let header = [
            L10n.transactionEditDate,
            L10n.backupsCsvFolder,
            L10n.transactionEditCategory,
            L10n.transactionEditAmount,
            L10n.backupsCsvComment,
        ]
        return switch format {
        case .xlsx: BackupXLSXWriter.data(header: header, rows: rows, sheetName: L10n.appName)
        case .json, .csv: BackupCSVWriter.data(header: header, rows: rows)
        }
    }

    @MainActor
    static func writeExportFile(from context: ModelContext, format: BackupExportFormat) throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("BackupExport", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let data: Data = switch format {
        case .json: try exportData(from: context)
        case .csv, .xlsx: try tableData(from: context, format: format)
        }
        let url = directory.appendingPathComponent(defaultFilename).appendingPathExtension(format.fileExtension)
        try data.write(to: url, options: .atomic)
        return url
    }

    static func read(from url: URL) throws -> ImportedBackup {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing { url.stopAccessingSecurityScopedResource() }
        }

        let copy = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.copyItem(at: url, to: copy)
        } catch {
            throw BackupError.corrupted
        }
        defer { try? FileManager.default.removeItem(at: copy) }

        if MokBackupReader.canRead(copy) {
            return try MokBackupReader.read(from: copy)
        }
        guard let data = try? Data(contentsOf: copy) else {
            throw BackupError.corrupted
        }
        return try decodeNative(data)
    }

    private static func decodeNative(_ data: Data) throws -> ImportedBackup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let header = try? decoder.decode(Header.self, from: data), header.format == BackupSnapshot.formatIdentifier else {
            throw BackupError.unsupportedFormat
        }
        guard header.version <= BackupSnapshot.currentVersion else {
            throw BackupError.newerVersion
        }
        guard let snapshot = try? decoder.decode(BackupSnapshot.self, from: data) else {
            throw BackupError.corrupted
        }
        return ImportedBackup(snapshot: snapshot, source: .native, skippedTransactions: 0)
    }

    @MainActor
    static func apply(_ backup: ImportedBackup, mode: BackupImportMode, to context: ModelContext) throws -> BackupImportResult {
        let snapshot = backup.snapshot

        if mode == .replace {
            for transaction in try context.fetch(FetchDescriptor<Transaction>()) {
                context.delete(transaction)
            }
            for category in try context.fetch(FetchDescriptor<TransactionCategory>()) {
                context.delete(category)
            }
        }

        let existingCategories = try mode == .replace ? [] : context.fetch(FetchDescriptor<TransactionCategory>())
        let sortOffset = existingCategories.nextSortIndex
        var unclaimed = existingCategories
        var resolved: [UUID: TransactionCategory] = [:]
        var created: [(category: TransactionCategory, parentUuid: UUID?)] = []

        for item in snapshot.categories {
            let name = TransactionCategoryName(rawValue: item.name)
            let matchIndex = unclaimed.firstIndex { $0.uuid == item.uuid } ?? unclaimed.firstIndex {
                $0.isDirectory == item.isDirectory && $0.name.localized.caseInsensitiveCompare(name.localized) == .orderedSame
            }

            if let matchIndex {
                resolved[item.uuid] = unclaimed.remove(at: matchIndex)
                continue
            }

            var icon = CategoryIcon(name: item.iconName, iconColor: IconColor(rawValue: item.iconColor) ?? .yellow)
            icon.customColorHex = item.customColorHex.flatMap(CategoryIcon.normalizedHex)

            let category = TransactionCategory(
                name: name,
                categoryIcon: icon,
                isDirectory: item.isDirectory,
                sortIndex: sortOffset + item.sortIndex
            )
            category.uuid = item.uuid
            context.insert(category)
            resolved[item.uuid] = category
            created.append((category, item.parentUuid))
        }

        for (category, parentUuid) in created {
            category.parentUuid = parentUuid.flatMap { resolved[$0]?.uuid }
        }

        let existingIds: Set<UUID> = try mode == .replace ? [] : Set(context.fetch(FetchDescriptor<Transaction>()).map(\.id))
        var addedTransactions = 0

        for item in snapshot.transactions where !existingIds.contains(item.id) {
            guard let category = resolved[item.categoryUuid], !category.isDirectory else { continue }
            let transaction = Transaction(amount: item.amount, category: category, date: item.date, note: item.comment)
            transaction.id = item.id
            context.insert(transaction)
            addedTransactions += 1
        }

        try context.save()

        if mode == .replace, let balance = snapshot.balance {
            storedBalance = Balance(amount: balance.amount, date: balance.date)
        }

        return BackupImportResult(transactions: addedTransactions, categories: created.count)
    }
}
