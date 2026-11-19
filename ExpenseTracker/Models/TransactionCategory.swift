//
//  TransactionCategory.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftUI

final class TransactionCategory: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: UUID = UUID()
    @Persisted var nameRaw: String = String()
    @Persisted var iconName: String = String()
    @Persisted var iconColorRaw: String = IconColor.yellow.rawValue
    @Persisted var customColorHex: String?
    @Persisted var isDirectory: Bool = false
    @Persisted var parentUuid: UUID?
    @Persisted var sortIndex: Int = 0
    @Persisted var budget: Int = 0
    @Persisted var deletedAt: Date?
    @Persisted var operationTypeRaw: String = OperationType.outcome.rawValue

    var id: UUID { uuid }

    var name: TransactionCategoryName {
        get { TransactionCategoryName(rawValue: nameRaw) }
        set { nameRaw = newValue.rawValue }
    }

    var categoryIcon: CategoryIcon {
        get {
            var icon = CategoryIcon(name: iconName, iconColor: IconColor(rawValue: iconColorRaw) ?? .yellow)
            icon.customColorHex = customColorHex
            return icon
        }
        set {
            iconName = newValue.name
            iconColorRaw = newValue.iconColor.rawValue
            customColorHex = newValue.customColorHex
        }
    }

    var operationType: OperationType {
        get { OperationType(rawValue: operationTypeRaw) ?? .outcome }
        set { operationTypeRaw = newValue.rawValue }
    }

    convenience init(name: TransactionCategoryName, categoryIcon: CategoryIcon, isDirectory: Bool = false, parentUuid: UUID? = nil, sortIndex: Int = .zero, operationType: OperationType = .outcome) {
        self.init()
        self.name = name
        self.categoryIcon = categoryIcon
        self.isDirectory = isDirectory
        self.parentUuid = parentUuid
        self.sortIndex = sortIndex
        self.operationTypeRaw = operationType.rawValue
    }

    var isMainCategory: Bool {
        parentUuid == nil
    }

    func parent(from allCategories: [TransactionCategory]) -> TransactionCategory? {
        allCategories.first { $0.uuid == parentUuid }
    }

    func allSubcategories(from allCategories: [TransactionCategory]) -> [TransactionCategory] {
        allCategories.filter { !$0.isDirectory }.filter { $0.parentUuid == uuid }
    }
}

extension TransactionCategory {
    static let notDeleted: (Query<TransactionCategory>) -> Query<Bool> = { $0.deletedAt == nil }
    static let directories: (Query<TransactionCategory>) -> Query<Bool> = { $0.deletedAt == nil && $0.isDirectory == true }
    static let nonDirectories: (Query<TransactionCategory>) -> Query<Bool> = { $0.deletedAt == nil && $0.isDirectory == false }
    static let inTrash: (Query<TransactionCategory>) -> Query<Bool> = { $0.deletedAt != nil }
}

extension Sequence<TransactionCategory> {
    func of(_ operationType: OperationType) -> [TransactionCategory] {
        filter { $0.operationType == operationType }
    }

    var inDisplayOrder: [TransactionCategory] {
        sorted {
            if $0.isDirectory != $1.isDirectory {
                return $0.isDirectory
            }
            if $0.sortIndex != $1.sortIndex {
                return $0.sortIndex < $1.sortIndex
            }
            return $0.name.localized < $1.name.localized
        }
    }

    var topLevel: [TransactionCategory] {
        let all = Array(self)
        return all.filter { !($0.parent(from: all)?.isDirectory ?? false) }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }
}

extension [TransactionCategory] {
    func reorder(fromOffsets source: IndexSet, toOffset destination: Int, among allCategories: [TransactionCategory]) {
        let ordered = allCategories.inDisplayOrder.compactMap { $0.live }
        if Set(ordered.map(\.sortIndex)).count != ordered.count {
            for (index, category) in ordered.enumerated() {
                category.sortIndex = index
            }
        }

        var reordered = compactMap { $0.live }
        let slots = reordered.map(\.sortIndex).sorted()
        reordered.move(fromOffsets: source, toOffset: destination)
        for (category, slot) in zip(reordered, slots) {
            category.sortIndex = slot
        }
    }
}

enum IconColor: String, Codable, CaseIterable {
    case red, pink, blue, yellow, orange, purple, green, brown, white, cyan, indigo, gray, black, mint, teal
    
    static let primary: [IconColor] = [.red, .blue, .yellow, .purple]
    
    var color: Color {
        baseColor.softened
    }

    private var baseColor: Color {
        switch self {
        case .red: .red
        case .yellow: .yellow
        case .cyan: .cyan
        case .purple: .purple
        case .pink: .pink
        case .brown:.brown
        case .orange: .orange
        case .green: .green
        case .blue: .blue
        case .indigo: .indigo
        case .white: .white
        case .gray: .gray
        case .black: .black
        case .mint: .mint
        case .teal: .teal
        }
    }
}
