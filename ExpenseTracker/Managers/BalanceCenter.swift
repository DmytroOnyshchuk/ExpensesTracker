import CoreData
import Foundation
import Observation
import SwiftData

@Observable
final class BalanceCenter {
    static let shared = BalanceCenter()

    private(set) var changes: [UUID: Int]?

    @ObservationIgnored private var isScheduled = false
    @ObservationIgnored private var isRefreshing = false
    @ObservationIgnored private var needsRefresh = false
    @ObservationIgnored private var observers = [NSObjectProtocol]()

    private init() {
        for name in [ModelContext.didSave, Notification.Name.NSManagedObjectContextDidSave] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.schedule()
            })
        }
        refresh()
    }

    func add(_ transaction: Transaction) {
        guard let account = transaction.account, transaction.deletedAt == nil, transaction.date > account.checkpointDate else { return }
        changes?[account.uuid, default: .zero] += transaction.signedAmount
    }

    private func schedule() {
        guard !isRefreshing else {
            needsRefresh = true
            return
        }
        guard !isScheduled else { return }
        isScheduled = true
        DispatchQueue.main.async {
            self.isScheduled = false
            self.refresh()
        }
    }

    private func refresh() {
        guard !isRefreshing else {
            needsRefresh = true
            return
        }
        isRefreshing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let changes = BalanceCenter.fetchChanges()
            DispatchQueue.main.async {
                self.finish(with: changes)
            }
        }
    }

    private func finish(with changes: [UUID: Int]) {
        isRefreshing = false
        guard !needsRefresh else {
            needsRefresh = false
            refresh()
            return
        }
        if self.changes != changes {
            self.changes = changes
        }
    }

    private static func fetchChanges() -> [UUID: Int] {
        let context = ModelContext(ModelContainer.shared)
        let transactions = (try? context.fetch(FetchDescriptor<Transaction>(predicate: Transaction.notDeleted))) ?? []
        return transactions.balanceChanges
    }
}
