//
//  CategoryRulesTests.swift
//  ExpenseTrackerTests
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

@testable import ExpenseTracker
import SwiftData
import XCTest

final class CategoryRulesTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Transaction.self, TransactionCategory.self, configurations: configuration)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
    }

    private func makeCategory(
        _ name: String,
        icon: CategoryIcon = CategoryIcon(name: "star", iconColor: .blue),
        isDirectory: Bool = false,
        in parent: TransactionCategory? = nil
    ) -> TransactionCategory {
        let category = TransactionCategory(name: .custom(name), categoryIcon: icon, isDirectory: isDirectory, parentUuid: parent?.uuid)
        context.insert(category)
        return category
    }

    // MARK: - Order and hierarchy

    func testDisplayOrderPutsFoldersFirstThenSortsByName() {
        let categories = [
            makeCategory("Transport"),
            makeCategory("Food", isDirectory: true),
            makeCategory("Clothing"),
            makeCategory("Car", isDirectory: true),
        ]

        XCTAssertEqual(categories.inDisplayOrder.map(\.name), ["Car", "Food", "Clothing", "Transport"])
    }

    func testTopLevelHidesCategoriesInsideFolders() {
        let food = makeCategory("Food", isDirectory: true)
        let categories = [
            food,
            makeCategory("Restaurants", in: food),
            makeCategory("Clothing"),
        ]

        XCTAssertEqual(Set(categories.topLevel.map(\.name)), ["Food", "Clothing"])
    }

    func testTopLevelKeepsCategoryWhoseFolderIsGone() {
        let deletedFolder = makeCategory("Food", isDirectory: true)
        let categories = [makeCategory("Restaurants", in: deletedFolder)]

        XCTAssertEqual(categories.topLevel.map(\.name), ["Restaurants"])
    }

    // MARK: - Draft

    func testNewDraftHasDefaults() {
        let draft = CategoryDraft()

        XCTAssertEqual(draft.name, L10n.editCategoryDefaultName)
        XCTAssertEqual(draft.icon.name, "cart")
        XCTAssertEqual(draft.icon.iconColor, .yellow)
        XCTAssertNil(draft.parentUuid)
    }

    func testDraftCopiesCategory() {
        let food = makeCategory("Food", isDirectory: true)
        let category = makeCategory("Restaurants", icon: CategoryIcon(name: "wineglass", iconColor: .blue), in: food)

        let draft = CategoryDraft(category)

        XCTAssertEqual(draft.name, "Restaurants")
        XCTAssertEqual(draft.icon.name, "wineglass")
        XCTAssertEqual(draft.icon.iconColor, .blue)
        XCTAssertEqual(draft.parentUuid, food.uuid)
    }

    func testEditingDraftLeavesCategoryUntouchedUntilApplied() {
        let food = makeCategory("Food", isDirectory: true)
        let category = makeCategory("Restaurants", icon: CategoryIcon(name: "wineglass", iconColor: .blue))

        var draft = CategoryDraft(category)
        draft.name = "Cafe"
        draft.icon.name = "cup.and.saucer"
        draft.icon.iconColor = .red
        draft.parentUuid = food.uuid

        XCTAssertEqual(category.name, "Restaurants")
        XCTAssertEqual(category.categoryIcon.name, "wineglass")
        XCTAssertEqual(category.categoryIcon.iconColor, .blue)
        XCTAssertNil(category.parentUuid)

        draft.apply(to: category)

        XCTAssertEqual(category.name, "Cafe")
        XCTAssertEqual(category.categoryIcon.name, "cup.and.saucer")
        XCTAssertEqual(category.categoryIcon.iconColor, .red)
        XCTAssertEqual(category.parentUuid, food.uuid)
    }

    func testPredefinedNameStaysPredefinedUntilRenamed() {
        let category = TransactionCategory(name: .food, categoryIcon: CategoryIcon(name: "fork.knife", iconColor: .yellow))
        context.insert(category)

        var draft = CategoryDraft(category)
        XCTAssertEqual(draft.name, L10n.defaultCategoryFood)

        draft.icon.iconColor = .red
        draft.apply(to: category)
        XCTAssertEqual(category.name, .food)

        draft.name = "Cafe"
        draft.apply(to: category)
        XCTAssertEqual(category.name, .custom("Cafe"))
    }

    func testNameRawValueRoundTrips() {
        for name in TransactionCategoryName.predefined + [.custom("Cafe")] {
            XCTAssertEqual(TransactionCategoryName(rawValue: name.rawValue), name)
        }
        XCTAssertEqual(Set(TransactionCategoryName.predefined.map(\.rawValue)).count, TransactionCategoryName.predefined.count)
    }

    func testMakeCategoryCreatesPlainCategoryFromDraft() {
        let food = makeCategory("Food", isDirectory: true)

        var draft = CategoryDraft()
        draft.name = "Cafe"
        draft.icon = CategoryIcon(name: "cup.and.saucer", iconColor: .red)
        draft.parentUuid = food.uuid

        let category = draft.makeCategory()

        XCTAssertEqual(category.name, "Cafe")
        XCTAssertEqual(category.categoryIcon.name, "cup.and.saucer")
        XCTAssertEqual(category.categoryIcon.iconColor, .red)
        XCTAssertEqual(category.parentUuid, food.uuid)
        XCTAssertFalse(category.isDirectory)
    }

    func testDraftCanBeSavedOnlyWithName() {
        var draft = CategoryDraft()
        XCTAssertTrue(draft.canSave)

        draft.name = ""
        XCTAssertFalse(draft.canSave)
    }

    func testDropMissingParentKeepsExistingFolder() {
        let food = makeCategory("Food", isDirectory: true)
        let category = makeCategory("Restaurants", in: food)

        var draft = CategoryDraft(category)
        draft.dropMissingParent(in: [food, category])

        XCTAssertEqual(draft.parentUuid, food.uuid)
    }

    func testDropMissingParentClearsDeletedFolder() {
        let deletedFolder = makeCategory("Food", isDirectory: true)
        let category = makeCategory("Restaurants", in: deletedFolder)

        var draft = CategoryDraft(category)
        draft.dropMissingParent(in: [category])

        XCTAssertNil(draft.parentUuid)
    }
}
