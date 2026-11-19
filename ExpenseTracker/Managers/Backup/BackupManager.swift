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
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return "ExpenseTracker-\(formatter.string(from: Date()))"
    }

    @MainActor
    static func exportData(from context: ModelContext) throws -> Data {
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>(predicate: TransactionCategory.notDeleted))
        let transactions = try context.fetch(FetchDescriptor<Transaction>(predicate: Transaction.notDeleted, sortBy: [SortDescriptor(\.date)]))
        let accounts = try context.fetch(FetchDescriptor<Account>(predicate: Account.notDeleted, sortBy: [SortDescriptor(\.sortIndex)]))

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
                    sortIndex: category.sortIndex,
                    budget: category.budget > .zero ? category.budget : nil,
                    operationType: category.operationTypeRaw
                )
            },
            transactions: transactions.map { transaction in
                BackupTransaction(
                    id: transaction.id,
                    amount: transaction.amount,
                    date: transaction.date,
                    note: transaction.note,
                    categoryUuid: transaction.category.uuid,
                    accountUuid: transaction.account?.uuid
                )
            },
            accounts: accounts.map { account in
                BackupAccount(
                    uuid: account.uuid,
                    name: account.name,
                    amount: account.amount,
                    date: account.checkpointDate,
                    sortIndex: account.sortIndex,
                    isDisabled: account.isDisabled
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    @MainActor
    static func tableData(
        from context: ModelContext,
        format: BackupExportFormat,
        options: BackupExportOptions = BackupExportOptions()
    ) throws -> Data {
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>(predicate: TransactionCategory.notDeleted))
        let stored = try context.fetch(FetchDescriptor<Transaction>(predicate: Transaction.notDeleted, sortBy: [SortDescriptor(\.date)]))
        let transactions = options.filter(stored)

        let rows = transactions.map { transaction in
            BackupTableRow(
                date: transaction.date,
                folder: transaction.category.parent(from: categories)?.name.localized ?? "",
                category: transaction.category.name.localized,
                amount: transaction.amount,
                note: transaction.note ?? ""
            )
        }
        let header = [
            L10n.transactionEditDate,
            L10n.backupsCsvFolder,
            L10n.transactionEditCategory,
            L10n.transactionEditAmount,
            L10n.backupsCsvNote,
        ]
        return switch format {
        case .xlsx: BackupXLSXWriter.data(header: header, rows: rows, sheetName: L10n.appName)
        case .json, .csv: BackupCSVWriter.data(header: header, rows: rows)
        }
    }

    @MainActor
    static func writeExportFile(
        from context: ModelContext,
        format: BackupExportFormat,
        options: BackupExportOptions = BackupExportOptions()
    ) throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("BackupExport", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let data: Data = switch format {
        case .json: try exportData(from: context)
        case .csv, .xlsx: try tableData(from: context, format: format, options: options)
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
            for autoPayment in try context.fetch(FetchDescriptor<AutoPayment>()) {
                context.delete(autoPayment)
            }
            for transaction in try context.fetch(FetchDescriptor<Transaction>()) {
                context.delete(transaction)
            }
            for category in try context.fetch(FetchDescriptor<TransactionCategory>()) {
                context.delete(category)
            }
            for account in try context.fetch(FetchDescriptor<Account>()) {
                context.delete(account)
            }
        }

        var accountsByUuid: [UUID: Account] = [:]
        let existingAccounts = try mode == .replace ? [] : context.fetch(FetchDescriptor<Account>())
        for account in existingAccounts {
            accountsByUuid[account.uuid] = account
        }
        var accountSortIndex = existingAccounts.nextSortIndex
        for item in snapshot.accounts ?? [] where accountsByUuid[item.uuid] == nil {
            let account = Account(name: item.name, amount: item.amount, checkpointDate: item.date, sortIndex: accountSortIndex)
            account.uuid = item.uuid
            account.isDisabled = item.isDisabled ?? false
            context.insert(account)
            accountsByUuid[item.uuid] = account
            accountSortIndex += 1
        }

        let existingCategories = try mode == .replace ? [] : context.fetch(FetchDescriptor<TransactionCategory>())
        let sortOffset = existingCategories.nextSortIndex
        var unclaimed = existingCategories
        var resolved: [UUID: TransactionCategory] = [:]
        var created: [(category: TransactionCategory, parentUuid: UUID?)] = []

        for item in snapshot.categories {
            let name = TransactionCategoryName(rawValue: item.name)
            let operationType = item.operationType.flatMap { OperationType(rawValue: $0) } ?? .outcome
            let matchIndex = unclaimed.firstIndex { $0.uuid == item.uuid } ?? unclaimed.firstIndex {
                $0.isDirectory == item.isDirectory && $0.operationType == operationType && $0.name.localized.caseInsensitiveCompare(name.localized) == .orderedSame
            }

            if let matchIndex {
                let match = unclaimed.remove(at: matchIndex)
                match.deletedAt = nil
                resolved[item.uuid] = match
                continue
            }

            var icon = CategoryIcon(name: item.iconName, iconColor: IconColor(rawValue: item.iconColor) ?? .yellow)
            icon.customColorHex = item.customColorHex.flatMap(CategoryIcon.normalizedHex)

            let category = TransactionCategory(
                name: name,
                categoryIcon: icon,
                isDirectory: item.isDirectory,
                sortIndex: sortOffset + item.sortIndex,
                operationType: operationType
            )
            category.uuid = item.uuid
            category.budget = max(item.budget ?? .zero, .zero)
            context.insert(category)
            resolved[item.uuid] = category
            created.append((category, item.parentUuid))
        }

        for (category, parentUuid) in created {
            category.parentUuid = parentUuid.flatMap { resolved[$0]?.uuid }
        }

        let existingIds: Set<UUID> = try mode == .replace ? [] : Set(context.fetch(FetchDescriptor<Transaction>()).map(\.id))
        var addedTransactions: Int = .zero

        for item in snapshot.transactions where !existingIds.contains(item.id) {
            guard let category = resolved[item.categoryUuid], !category.isDirectory else { continue }
            let transaction = Transaction(
                amount: item.amount,
                category: category,
                date: item.date,
                note: item.note,
                account: item.accountUuid.flatMap { accountsByUuid[$0] }
            )
            transaction.id = item.id
            context.insert(transaction)
            addedTransactions += 1
        }

        try context.save()

        DataSeeder.seedDefaultAccount(in: context)

        return BackupImportResult(transactions: addedTransactions, categories: created.count)
    }
}
