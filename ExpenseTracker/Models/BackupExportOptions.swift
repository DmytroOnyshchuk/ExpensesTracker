import Foundation

enum BackupExportPeriod: CaseIterable, Identifiable {
    case last30Days
    case last90Days
    case last365Days
    case allHistory
    case custom

    var id: Self { self }

    var days: Int? {
        switch self {
        case .last30Days: 30
        case .last90Days: 90
        case .last365Days: 365
        case .allHistory, .custom: nil
        }
    }

    var title: String {
        switch self {
        case .last30Days, .last90Days, .last365Days: L10n.backupsExportLastDays(days ?? .zero)
        case .allHistory: L10n.backupsExportAllHistory
        case .custom: L10n.backupsExportCustomPeriod
        }
    }
}

struct BackupExportOptions {
    var includesAllAccounts = true
    var accountUuids: Set<UUID> = []
    var period = BackupExportPeriod.allHistory
    var customStart: Date
    var customEnd: Date

    init(now: Date = Date(), calendar: Calendar = .current) {
        self.customEnd = now
        self.customStart = calendar.date(byAdding: .month, value: -1, to: now) ?? now
    }

    func isSelected(_ account: Account) -> Bool {
        !includesAllAccounts && accountUuids.contains(account.uuid)
    }

    mutating func toggle(_ account: Account) {
        if includesAllAccounts {
            includesAllAccounts = false
            accountUuids = [account.uuid]
        } else if accountUuids.contains(account.uuid) {
            accountUuids.remove(account.uuid)
        } else {
            accountUuids.insert(account.uuid)
        }
    }

    mutating func selectAllAccounts() {
        includesAllAccounts = true
        accountUuids = []
    }

    func dateRange(now: Date = Date(), calendar: Calendar = .current) -> Range<Date>? {
        switch period {
        case .allHistory:
            return nil
        case .custom:
            let start = calendar.startOfDay(for: min(customStart, customEnd))
            return start ..< dayEnd(max(customStart, customEnd), calendar: calendar)
        case .last30Days, .last90Days, .last365Days:
            let today = calendar.startOfDay(for: now)
            let start = calendar.date(byAdding: .day, value: 1 - (period.days ?? 1), to: today) ?? today
            return start ..< dayEnd(now, calendar: calendar)
        }
    }

    func filter(_ transactions: [Transaction], now: Date = Date(), calendar: Calendar = .current) -> [Transaction] {
        let range = dateRange(now: now, calendar: calendar)
        return transactions.filter { transaction in
            if let range, !range.contains(transaction.date) {
                return false
            }
            if !includesAllAccounts {
                guard let uuid = transaction.account?.uuid, accountUuids.contains(uuid) else { return false }
            }
            return true
        }
    }

    private func dayEnd(_ date: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? date
    }
}
