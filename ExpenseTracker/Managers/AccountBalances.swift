import Observation
import SwiftData
import SwiftUI

@Observable
final class AccountBalances {
    static let shared = AccountBalances()

    private var values: [UUID: Int] = [:]

    private init() {}

    func current(of account: Account) -> Int {
        values[account.uuid] ?? account.amount
    }

    func total(of accounts: [Account]) -> Int {
        accounts.reduce(0) { $0 + current(of: $1) }
    }

    func update(_ balance: Int, for accountUuid: UUID) {
        guard values[accountUuid] != balance else { return }
        values[accountUuid] = balance
    }
}

struct AccountBalanceTracker: View {
    @Query(filter: Account.notDeleted) private var accounts: [Account]

    var body: some View {
        ForEach(accounts, id: \.uuid) { account in
            AccountBalanceProbe(accountUuid: account.uuid, amount: account.amount, checkpointDate: account.checkpointDate)
        }
    }
}

struct AccountBalanceProbe: View {
    let accountUuid: UUID
    let amount: Int
    let checkpointDate: Date

    @Query private var income: [Transaction]
    @Query private var outcome: [Transaction]

    init(accountUuid: UUID, amount: Int, checkpointDate: Date) {
        self.accountUuid = accountUuid
        self.amount = amount
        self.checkpointDate = checkpointDate
        _income = Query(filter: Transaction.counted(for: accountUuid, after: checkpointDate, of: .income))
        _outcome = Query(filter: Transaction.counted(for: accountUuid, after: checkpointDate, of: .outcome))
    }

    private var balance: Int {
        amount + income.reduce(0) { $0 + $1.amount } - outcome.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onChange(of: balance, initial: true) { _, balance in
                AccountBalances.shared.update(balance, for: accountUuid)
            }
    }
}

extension AccountBalanceProbe: Equatable {
    nonisolated static func == (lhs: AccountBalanceProbe, rhs: AccountBalanceProbe) -> Bool { lhs.accountUuid == rhs.accountUuid && lhs.amount == rhs.amount && lhs.checkpointDate == rhs.checkpointDate }
}
