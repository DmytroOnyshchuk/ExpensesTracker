//
//  TransactionCategoryName.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// Category name.
///
/// Default categories store their case instead of text, so they are shown in the current app language.
/// A name entered by the user is stored as is in `.custom`.
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
    case digitalServices
    case other
    case transport
    case family
    case taxi
    case publicTransit
    case taxes
    case repair
    case electronics
    case carParking
    case pets
    case savings
    case salary

    case custom(String)

    /// All default names.
    static let predefined: [TransactionCategoryName] = [
        .car, .carFuel, .carMaintenance, .charity, .clothing, .food, .foodGroceries, .foodRestaurants,
        .healthBeauty, .home, .homeHousehold, .homeUtilities, .digitalServices, .other, .transport,
        .family, .taxi, .publicTransit, .taxes, .repair, .electronics, .carParking, .pets, .savings, .salary,
    ]

    /// Display text in the current app language.
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
        case .digitalServices: L10n.defaultCategoryDigitalServices
        case .other: L10n.defaultCategoryOther
        case .transport: L10n.defaultCategoryTransport
        case .family: L10n.defaultCategoryFamily
        case .taxi: L10n.defaultCategoryTaxi
        case .publicTransit: L10n.defaultCategoryPublicTransit
        case .taxes: L10n.defaultCategoryTaxes
        case .repair: L10n.defaultCategoryRepair
        case .electronics: L10n.defaultCategoryElectronics
        case .carParking: L10n.defaultCategoryCarParking
        case .pets: L10n.defaultCategoryPets
        case .savings: L10n.defaultCategorySavings
        case .salary: L10n.defaultCategorySalary
        case let .custom(text): text
        }
    }

    /// The name after editing in the form.
    ///
    /// If the text has not changed, a default name stays default and keeps being translated.
    func renamed(to text: String) -> TransactionCategoryName {
        text == localized ? self : .custom(text)
    }
}

// MARK: - Storage

/// The name is stored as a single string: the localization key for default names, the text itself for custom ones.
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
        case .digitalServices: "DEFAULT_CATEGORY_DIGITAL_SERVICES"
        case .other: "DEFAULT_CATEGORY_OTHER"
        case .transport: "DEFAULT_CATEGORY_TRANSPORT"
        case .family: "DEFAULT_CATEGORY_FAMILY"
        case .taxi: "DEFAULT_CATEGORY_TAXI"
        case .publicTransit: "DEFAULT_CATEGORY_PUBLIC_TRANSIT"
        case .taxes: "DEFAULT_CATEGORY_TAXES"
        case .repair: "DEFAULT_CATEGORY_REPAIR"
        case .electronics: "DEFAULT_CATEGORY_ELECTRONICS"
        case .carParking: "DEFAULT_CATEGORY_CAR_PARKING"
        case .pets: "DEFAULT_CATEGORY_PETS"
        case .savings: "DEFAULT_CATEGORY_SAVINGS"
        case .salary: "DEFAULT_CATEGORY_SALARY"
        case let .custom(text): text
        }
    }
}

// MARK: - Literals

/// Allows writing `TransactionCategory(name: "Cafe", …)` in previews and tests.
extension TransactionCategoryName: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .custom(value)
    }
}
