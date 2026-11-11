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
        let category = TransactionCategory(name: name, categoryIcon: icon, isDirectory: isDirectory, parentUuid: parent?.uuid)
        context.insert(category)
        return category
    }

    // MARK: - Порядок и иерархия

    func testDisplayOrderPutsFoldersFirstThenSortsByName() {
        let categories = [
            makeCategory("Транспорт"),
            makeCategory("Еда", isDirectory: true),
            makeCategory("Одежда"),
            makeCategory("Авто", isDirectory: true),
        ]

        XCTAssertEqual(categories.inDisplayOrder.map(\.name), ["Авто", "Еда", "Одежда", "Транспорт"])
    }

    func testTopLevelHidesCategoriesInsideFolders() {
        let food = makeCategory("Еда", isDirectory: true)
        let categories = [
            food,
            makeCategory("Рестораны", in: food),
            makeCategory("Одежда"),
        ]

        XCTAssertEqual(Set(categories.topLevel.map(\.name)), ["Еда", "Одежда"])
    }

    func testTopLevelKeepsCategoryWhoseFolderIsGone() {
        let deletedFolder = makeCategory("Еда", isDirectory: true)
        let categories = [makeCategory("Рестораны", in: deletedFolder)]

        XCTAssertEqual(categories.topLevel.map(\.name), ["Рестораны"])
    }

    // MARK: - Черновик

    func testNewDraftHasDefaults() {
        let draft = CategoryDraft()

        XCTAssertEqual(draft.name, L10n.editCategoryDefaultName)
        XCTAssertEqual(draft.icon.name, "cart")
        XCTAssertEqual(draft.icon.iconColor, .yellow)
        XCTAssertNil(draft.parentUuid)
    }

    func testDraftCopiesCategory() {
        let food = makeCategory("Еда", isDirectory: true)
        let category = makeCategory("Рестораны", icon: CategoryIcon(name: "wineglass", iconColor: .blue), in: food)

        let draft = CategoryDraft(category)

        XCTAssertEqual(draft.name, "Рестораны")
        XCTAssertEqual(draft.icon.name, "wineglass")
        XCTAssertEqual(draft.icon.iconColor, .blue)
        XCTAssertEqual(draft.parentUuid, food.uuid)
    }

    func testEditingDraftLeavesCategoryUntouchedUntilApplied() {
        let food = makeCategory("Еда", isDirectory: true)
        let category = makeCategory("Рестораны", icon: CategoryIcon(name: "wineglass", iconColor: .blue))

        var draft = CategoryDraft(category)
        draft.name = "Кафе"
        draft.icon.name = "cup.and.saucer"
        draft.icon.iconColor = .red
        draft.parentUuid = food.uuid

        XCTAssertEqual(category.name, "Рестораны")
        XCTAssertEqual(category.categoryIcon.name, "wineglass")
        XCTAssertEqual(category.categoryIcon.iconColor, .blue)
        XCTAssertNil(category.parentUuid)

        draft.apply(to: category)

        XCTAssertEqual(category.name, "Кафе")
        XCTAssertEqual(category.categoryIcon.name, "cup.and.saucer")
        XCTAssertEqual(category.categoryIcon.iconColor, .red)
        XCTAssertEqual(category.parentUuid, food.uuid)
    }

    func testMakeCategoryCreatesPlainCategoryFromDraft() {
        let food = makeCategory("Еда", isDirectory: true)

        var draft = CategoryDraft()
        draft.name = "Кафе"
        draft.icon = CategoryIcon(name: "cup.and.saucer", iconColor: .red)
        draft.parentUuid = food.uuid

        let category = draft.makeCategory()

        XCTAssertEqual(category.name, "Кафе")
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
        let food = makeCategory("Еда", isDirectory: true)
        let category = makeCategory("Рестораны", in: food)

        var draft = CategoryDraft(category)
        draft.dropMissingParent(in: [food, category])

        XCTAssertEqual(draft.parentUuid, food.uuid)
    }

    func testDropMissingParentClearsDeletedFolder() {
        let deletedFolder = makeCategory("Еда", isDirectory: true)
        let category = makeCategory("Рестораны", in: deletedFolder)

        var draft = CategoryDraft(category)
        draft.dropMissingParent(in: [category])

        XCTAssertNil(draft.parentUuid)
    }
}
