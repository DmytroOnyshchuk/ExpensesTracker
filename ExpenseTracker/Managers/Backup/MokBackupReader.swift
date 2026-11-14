import Foundation
import SQLite3

enum MokBackupReader {
    private static let sqliteHeader = Data("SQLite format 3\0".utf8)

    static func canRead(_ url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        return (try? handle.read(upToCount: sqliteHeader.count)) == sqliteHeader
    }

    static func read(from url: URL) throws -> ImportedBackup {
        var state = MokState()
        for event in try loadEvents(from: url) {
            state.apply(event)
        }
        return state.makeBackup()
    }

    private static func loadEvents(from url: URL) throws -> [MokEvent] {
        var database: OpaquePointer?
        guard sqlite3_open_v2(url.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            sqlite3_close(database)
            throw BackupError.corrupted
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let query = "SELECT type, params FROM Chronicle ORDER BY uid"
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else {
            throw BackupError.unsupportedFormat
        }
        defer { sqlite3_finalize(statement) }

        var events: [MokEvent] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let text = sqlite3_column_text(statement, 1) else { continue }
            let json = Data(String(cString: text).utf8)
            guard let params = (try? JSONSerialization.jsonObject(with: json)) as? [String: Any] else { continue }
            events.append(MokEvent(type: Int(sqlite3_column_int(statement, 0)), params: params))
        }
        return events
    }
}

private enum MokEventType: Int {
    case transactionAdded = 10
    case transactionEdited = 11
    case transactionDeleted = 12
    case groupAdded = 30
    case categoryAdded = 40
    case categoryEdited = 41
    case categoryDeleted = 42
    case itemMoved = 45
}

private struct MokEvent {
    let type: Int
    let params: [String: Any]

    func int(_ key: String) -> Int? {
        (params[key] as? NSNumber)?.intValue
    }

    func double(_ key: String) -> Double? {
        (params[key] as? NSNumber)?.doubleValue
    }

    func string(_ key: String) -> String? {
        params[key] as? String
    }

    var isExpense: Bool {
        int("opType") == MokState.expenseType
    }
}

private struct MokGroup {
    var name: String
}

private struct MokCategory {
    var name: String
    var icon: String?
    var color: Int?
    var groupUid: Int
    var isExpense: Bool
    var isDeleted = false
}

private struct MokTransaction {
    var categoryUid: Int?
    var money: Double
    var date: Date?
    var note: String?
    var isExpense: Bool
}

private enum MokItem: Equatable {
    case group(Int)
    case category(Int)
}

private struct MokState {
    static let expenseType = 1
    static let expenseRootUid = 1
    static let incomeRootUid = 2

    private var groups: [Int: MokGroup] = [:]
    private var categories: [Int: MokCategory] = [:]
    private var transactions: [Int: MokTransaction] = [:]
    private var order: [Int: [MokItem]] = [expenseRootUid: [], incomeRootUid: []]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return formatter
    }()

    mutating func apply(_ event: MokEvent) {
        guard let type = MokEventType(rawValue: event.type), let uid = event.int("uid") else { return }

        switch type {
        case .groupAdded:
            groups[uid] = MokGroup(name: event.string("name") ?? "")
            order[uid] = []
            order[event.isExpense ? Self.expenseRootUid : Self.incomeRootUid, default: []].append(.group(uid))

        case .categoryAdded:
            let groupUid = event.int("groupUid") ?? Self.expenseRootUid
            categories[uid] = MokCategory(
                name: event.string("name") ?? "",
                icon: event.string("icon"),
                color: event.int("color"),
                groupUid: groupUid,
                isExpense: event.isExpense
            )
            order[groupUid, default: []].append(.category(uid))

        case .categoryEdited:
            if let name = event.string("name") { categories[uid]?.name = name }
            if let icon = event.string("icon") { categories[uid]?.icon = icon }
            if let color = event.int("color") { categories[uid]?.color = color }

        case .categoryDeleted:
            categories[uid]?.isDeleted = true
            removeFromOrder(.category(uid))

        case .itemMoved:
            move(uid: uid, event: event)

        case .transactionAdded:
            transactions[uid] = MokTransaction(
                categoryUid: event.int("catUid"),
                money: event.double("money") ?? 0,
                date: event.string("date").flatMap(dateFormatter.date(from:)),
                note: event.string("note"),
                isExpense: event.isExpense
            )

        case .transactionEdited:
            if let categoryUid = event.int("catUid") { transactions[uid]?.categoryUid = categoryUid }
            if let money = event.double("money") { transactions[uid]?.money = money }
            if let date = event.string("date").flatMap(dateFormatter.date(from:)) { transactions[uid]?.date = date }
            if let note = event.string("note") { transactions[uid]?.note = note }

        case .transactionDeleted:
            transactions[uid] = nil
        }
    }

    private mutating func removeFromOrder(_ item: MokItem) {
        for key in order.keys {
            order[key]?.removeAll { $0 == item }
        }
    }

    private mutating func move(uid: Int, event: MokEvent) {
        guard let targetUid = event.int("newGroupUid"), let targetItems = order[targetUid] else { return }

        let item: MokItem
        if event.int("isGroup") == 1 {
            guard groups[uid] != nil else { return }
            item = .group(uid)
        } else {
            guard let category = categories[uid], !category.isDeleted else { return }
            item = .category(uid)
            categories[uid]?.groupUid = targetUid
        }

        removeFromOrder(item)
        let index = min(max(event.int("toIndex") ?? targetItems.count, 0), order[targetUid]?.count ?? 0)
        order[targetUid]?.insert(item, at: index)
    }

    func makeBackup() -> ImportedBackup {
        let kept = transactions
            .filter { _, transaction in
                guard transaction.isExpense, transaction.date != nil, let categoryUid = transaction.categoryUid else { return false }
                return categories[categoryUid]?.isExpense == true
            }
            .sorted { $0.key < $1.key }

        let usedCategoryUids = Set(kept.compactMap(\.value.categoryUid))
        var result: [BackupCategory] = []

        func appendCategory(_ uid: Int, parent: UUID?) {
            guard let category = categories[uid], category.isExpense else { return }
            let icon = MokIcon(category: category)
            result.append(BackupCategory(
                uuid: MokIdentifier.category.uuid(uid),
                name: category.name,
                iconName: icon.name,
                iconColor: icon.color,
                customColorHex: icon.customColorHex,
                isDirectory: false,
                parentUuid: parent,
                sortIndex: result.count
            ))
        }

        for item in order[Self.expenseRootUid] ?? [] {
            switch item {
            case let .category(uid):
                appendCategory(uid, parent: nil)

            case let .group(uid):
                guard let group = groups[uid] else { continue }
                let children = (order[uid] ?? []).compactMap { child -> Int? in
                    if case let .category(childUid) = child { return childUid }
                    return nil
                }
                let icon = children.first.flatMap { categories[$0] }.map(MokIcon.init(category:)) ?? .folder
                let groupUuid = MokIdentifier.group.uuid(uid)
                result.append(BackupCategory(
                    uuid: groupUuid,
                    name: group.name,
                    iconName: icon.name,
                    iconColor: icon.color,
                    customColorHex: icon.customColorHex,
                    isDirectory: true,
                    parentUuid: nil,
                    sortIndex: result.count
                ))
                for childUid in children {
                    appendCategory(childUid, parent: groupUuid)
                }
            }
        }

        let deletedButUsed = categories
            .filter { $0.value.isDeleted && usedCategoryUids.contains($0.key) }
            .keys
            .sorted()
        for uid in deletedButUsed {
            let groupUid = categories[uid]?.groupUid ?? Self.expenseRootUid
            appendCategory(uid, parent: groups[groupUid] == nil ? nil : MokIdentifier.group.uuid(groupUid))
        }

        let backupTransactions = kept.compactMap { uid, transaction -> BackupTransaction? in
            guard let date = transaction.date, let categoryUid = transaction.categoryUid else { return nil }
            let note = transaction.note?.trimmingCharacters(in: .whitespacesAndNewlines)
            return BackupTransaction(
                id: MokIdentifier.transaction.uuid(uid),
                amount: Int((transaction.money * 100).rounded()),
                date: date,
                comment: note?.isEmpty == false ? note : nil,
                categoryUuid: MokIdentifier.category.uuid(categoryUid)
            )
        }

        return ImportedBackup(
            snapshot: BackupSnapshot(categories: result, transactions: backupTransactions, balance: nil),
            source: .mok,
            skippedTransactions: transactions.count - backupTransactions.count
        )
    }
}

private enum MokIdentifier: Int {
    case group = 1
    case category = 2
    case transaction = 3

    func uuid(_ uid: Int) -> UUID {
        UUID(uuidString: String(format: "4D4F4B%02X-0000-4000-8000-%012X", rawValue, uid)) ?? UUID()
    }
}

private struct MokIcon {
    static let folder = MokIcon(name: "folder.fill", color: "yellow", customColorHex: nil)

    private static let symbols: [String: String] = [
        "itemBasket": "basket.fill",
        "itemCafe": "mug.fill",
        "itemCar2": "car.fill",
        "itemCarRepairing": "wrench.and.screwdriver.fill",
        "itemClothes": "tshirt.fill",
        "itemCocktail": "wineglass.fill",
        "itemDog": "dog.fill",
        "itemDumbbells": "dumbbell.fill",
        "itemFamily": "stroller.fill",
        "itemFood": "fork.knife",
        "itemGame": "gamecontroller.fill",
        "itemGift": "gift.fill",
        "itemGirl": "person.fill",
        "itemHeart": "heart.fill",
        "itemHome": "house.fill",
        "itemIPhone": "iphone",
        "itemInternet": "wifi",
        "itemJob": "briefcase.fill",
        "itemMedicine": "cross.case.fill",
        "itemMoney": "dollarsign.circle.fill",
        "itemPants": "tshirt.fill",
        "itemPiggybank": "banknote.fill",
        "itemRefuelling": "fuelpump.fill",
        "itemRepair": "hammer.fill",
        "itemRest": "popcorn.fill",
        "itemTaxi": "car.side.fill",
        "itemTv": "tv.fill",
        "otherItem": "star.fill",
    ]

    let name: String
    let color: String
    let customColorHex: String?

    init(name: String, color: String, customColorHex: String?) {
        self.name = name
        self.color = color
        self.customColorHex = customColorHex
    }

    init(category: MokCategory) {
        let key = category.icon
            .map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent } ?? ""
        self.name = Self.symbols[key] ?? "tag.fill"

        if let color = category.color, color >= 0 {
            self.color = "yellow"
            self.customColorHex = String(format: "#%06X", color & 0xFFFFFF)
        } else {
            self.color = "gray"
            self.customColorHex = nil
        }
    }
}
