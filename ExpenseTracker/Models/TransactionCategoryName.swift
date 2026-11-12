//
//  TransactionCategoryName.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// Название категории.
///
/// Стандартные категории хранят не текст, а свой кейс, поэтому показываются на текущем языке приложения.
/// Название, которое ввёл пользователь, хранится как есть в `.custom`.
enum TransactionCategoryName: Hashable {
    case car
    case carFuel
    case carMaintenance
    case charity
    case clothing
    case food
    case foodGroceries
    case foodRestaurants
    case healthBeauty
    case home
    case homeHousehold
    case homeUtilities
    case internet
    case other
    case transport

    case custom(String)

    /// Все стандартные названия.
    static let predefined: [TransactionCategoryName] = [
        .car, .carFuel, .carMaintenance, .charity, .clothing, .food, .foodGroceries, .foodRestaurants,
        .healthBeauty, .home, .homeHousehold, .homeUtilities, .internet, .other, .transport,
    ]

    /// Текст для показа на текущем языке приложения.
    var localized: String {
        switch self {
        case .car: L10n.defaultCategoryCar
        case .carFuel: L10n.defaultCategoryCarFuel
        case .carMaintenance: L10n.defaultCategoryCarMaintenance
        case .charity: L10n.defaultCategoryCharity
        case .clothing: L10n.defaultCategoryClothing
        case .food: L10n.defaultCategoryFood
        case .foodGroceries: L10n.defaultCategoryFoodGroceries
        case .foodRestaurants: L10n.defaultCategoryFoodRestaurants
        case .healthBeauty: L10n.defaultCategoryHealthBeauty
        case .home: L10n.defaultCategoryHome
        case .homeHousehold: L10n.defaultCategoryHomeHousehold
        case .homeUtilities: L10n.defaultCategoryHomeUtilities
        case .internet: L10n.defaultCategoryInternet
        case .other: L10n.defaultCategoryOther
        case .transport: L10n.defaultCategoryTransport
        case let .custom(text): text
        }
    }

    /// Название после редактирования в форме.
    ///
    /// Если текст не изменился, стандартное название остаётся стандартным и продолжает переводиться.
    func renamed(to text: String) -> TransactionCategoryName {
        text == localized ? self : .custom(text)
    }
}

// MARK: - Хранение

/// В базе название лежит одной строкой: ключ локализации для стандартных, сам текст для пользовательских.
extension TransactionCategoryName: RawRepresentable, Codable {
    init(rawValue: String) {
        self = Self.predefined.first { $0.rawValue == rawValue } ?? .custom(rawValue)
    }

    var rawValue: String {
        switch self {
        case .car: "DEFAULT_CATEGORY_CAR"
        case .carFuel: "DEFAULT_CATEGORY_CAR_FUEL"
        case .carMaintenance: "DEFAULT_CATEGORY_CAR_MAINTENANCE"
        case .charity: "DEFAULT_CATEGORY_CHARITY"
        case .clothing: "DEFAULT_CATEGORY_CLOTHING"
        case .food: "DEFAULT_CATEGORY_FOOD"
        case .foodGroceries: "DEFAULT_CATEGORY_FOOD_GROCERIES"
        case .foodRestaurants: "DEFAULT_CATEGORY_FOOD_RESTAURANTS"
        case .healthBeauty: "DEFAULT_CATEGORY_HEALTH_BEAUTY"
        case .home: "DEFAULT_CATEGORY_HOME"
        case .homeHousehold: "DEFAULT_CATEGORY_HOME_HOUSEHOLD"
        case .homeUtilities: "DEFAULT_CATEGORY_HOME_UTILITIES"
        case .internet: "DEFAULT_CATEGORY_INTERNET"
        case .other: "DEFAULT_CATEGORY_OTHER"
        case .transport: "DEFAULT_CATEGORY_TRANSPORT"
        case let .custom(text): text
        }
    }
}

// MARK: - Литералы

/// Позволяет писать `TransactionCategory(name: "Кафе", …)` в превью и тестах.
extension TransactionCategoryName: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .custom(value)
    }
}
