// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Rate app
  internal static let aboutRate = L10n.tr("Localizable", "ABOUT_RATE", fallback: "Rate app")
  /// Share app
  internal static let aboutShare = L10n.tr("Localizable", "ABOUT_SHARE", fallback: "Share app")
  /// Version %@
  internal static func aboutVersion(_ p1: Any) -> String {
    return L10n.tr("Localizable", "ABOUT_VERSION", String(describing: p1), fallback: "Version %@")
  }
  /// Expenses accounting
  internal static let accountingExpenses = L10n.tr("Localizable", "ACCOUNTING_EXPENSES", fallback: "Expenses accounting")
  /// Income accounting
  internal static let accountingIncome = L10n.tr("Localizable", "ACCOUNTING_INCOME", fallback: "Income accounting")
  /// Multiple accounts
  internal static let accountingMultipleAccounts = L10n.tr("Localizable", "ACCOUNTING_MULTIPLE_ACCOUNTS", fallback: "Multiple accounts")
  /// Wallet
  internal static let accountsDefaultName = L10n.tr("Localizable", "ACCOUNTS_DEFAULT_NAME", fallback: "Wallet")
  /// Account deleted
  internal static let accountsDeleted = L10n.tr("Localizable", "ACCOUNTS_DELETED", fallback: "Account deleted")
  /// Disable account
  internal static let accountsDisable = L10n.tr("Localizable", "ACCOUNTS_DISABLE", fallback: "Disable account")
  /// Edit account
  internal static let accountsEdit = L10n.tr("Localizable", "ACCOUNTS_EDIT", fallback: "Edit account")
  /// Name
  internal static let accountsName = L10n.tr("Localizable", "ACCOUNTS_NAME", fallback: "Name")
  /// New account
  internal static let accountsNew = L10n.tr("Localizable", "ACCOUNTS_NEW", fallback: "New account")
  /// Accounts
  internal static let accountsTitle = L10n.tr("Localizable", "ACCOUNTS_TITLE", fallback: "Accounts")
  /// Total
  internal static let accountsTotal = L10n.tr("Localizable", "ACCOUNTS_TOTAL", fallback: "Total")
  /// Localizable.strings
  ///   SwiftTemplate
  /// 
  ///   Created by Dmytro Onyshchuk on 20.06.2025.
  ///   Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
  internal static let appName = L10n.tr("Localizable", "APP_NAME", fallback: "Expense Tracker")
  /// Attention
  internal static let attention = L10n.tr("Localizable", "ATTENTION", fallback: "Attention")
  /// No autopayments
  internal static let autopaymentsEmpty = L10n.tr("Localizable", "AUTOPAYMENTS_EMPTY", fallback: "No autopayments")
  /// New autopayment
  internal static let autopaymentsNewTitle = L10n.tr("Localizable", "AUTOPAYMENTS_NEW_TITLE", fallback: "New autopayment")
  /// Period
  internal static let autopaymentsPeriod = L10n.tr("Localizable", "AUTOPAYMENTS_PERIOD", fallback: "Period")
  /// Start date
  internal static let autopaymentsStartDate = L10n.tr("Localizable", "AUTOPAYMENTS_START_DATE", fallback: "Start date")
  /// Back
  internal static let back = L10n.tr("Localizable", "BACK", fallback: "Back")
  /// Categories: %d
  internal static func backupsCategoriesCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "BACKUPS_CATEGORIES_COUNT", p1, fallback: "Categories: %d")
  }
  /// Folder
  internal static let backupsCsvFolder = L10n.tr("Localizable", "BACKUPS_CSV_FOLDER", fallback: "Folder")
  /// Note
  internal static let backupsCsvNote = L10n.tr("Localizable", "BACKUPS_CSV_NOTE", fallback: "Note")
  /// In the app
  internal static let backupsCurrentData = L10n.tr("Localizable", "BACKUPS_CURRENT_DATA", fallback: "In the app")
  /// The file is damaged or cannot be read.
  internal static let backupsErrorCorrupted = L10n.tr("Localizable", "BACKUPS_ERROR_CORRUPTED", fallback: "The file is damaged or cannot be read.")
  /// This backup was made by a newer version of the app.
  internal static let backupsErrorNewerVersion = L10n.tr("Localizable", "BACKUPS_ERROR_NEWER_VERSION", fallback: "This backup was made by a newer version of the app.")
  /// This file format is not supported.
  internal static let backupsErrorUnsupported = L10n.tr("Localizable", "BACKUPS_ERROR_UNSUPPORTED", fallback: "This file format is not supported.")
  /// All accounts
  internal static let backupsExportAllAccounts = L10n.tr("Localizable", "BACKUPS_EXPORT_ALL_ACCOUNTS", fallback: "All accounts")
  /// All history
  internal static let backupsExportAllHistory = L10n.tr("Localizable", "BACKUPS_EXPORT_ALL_HISTORY", fallback: "All history")
  /// Custom period
  internal static let backupsExportCustomPeriod = L10n.tr("Localizable", "BACKUPS_EXPORT_CUSTOM_PERIOD", fallback: "Custom period")
  /// Last %d days
  internal static func backupsExportLastDays(_ p1: Int) -> String {
    return L10n.tr("Localizable", "BACKUPS_EXPORT_LAST_DAYS", p1, fallback: "Last %d days")
  }
  /// Period
  internal static let backupsExportPeriod = L10n.tr("Localizable", "BACKUPS_EXPORT_PERIOD", fallback: "Period")
  /// Export
  internal static let backupsExportSection = L10n.tr("Localizable", "BACKUPS_EXPORT_SECTION", fallback: "Export")
  /// Export settings
  internal static let backupsExportSettings = L10n.tr("Localizable", "BACKUPS_EXPORT_SETTINGS", fallback: "Export settings")
  /// View only
  internal static let backupsFormatCsv = L10n.tr("Localizable", "BACKUPS_FORMAT_CSV", fallback: "View only")
  /// Full backup
  internal static let backupsFormatJson = L10n.tr("Localizable", "BACKUPS_FORMAT_JSON", fallback: "Full backup")
  /// Export format
  internal static let backupsFormatTitle = L10n.tr("Localizable", "BACKUPS_FORMAT_TITLE", fallback: "Export format")
  /// Import from file
  internal static let backupsImportAction = L10n.tr("Localizable", "BACKUPS_IMPORT_ACTION", fallback: "Import from file")
  /// Added transactions: %d, categories: %d
  internal static func backupsImportDone(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "BACKUPS_IMPORT_DONE", p1, p2, fallback: "Added transactions: %d, categories: %d")
  }
  /// Add to current data
  internal static let backupsImportMerge = L10n.tr("Localizable", "BACKUPS_IMPORT_MERGE", fallback: "Add to current data")
  /// Period: %@
  internal static func backupsImportPeriod(_ p1: Any) -> String {
    return L10n.tr("Localizable", "BACKUPS_IMPORT_PERIOD", String(describing: p1), fallback: "Period: %@")
  }
  /// Found in file
  internal static let backupsImportPreviewTitle = L10n.tr("Localizable", "BACKUPS_IMPORT_PREVIEW_TITLE", fallback: "Found in file")
  /// Replace all data
  internal static let backupsImportReplace = L10n.tr("Localizable", "BACKUPS_IMPORT_REPLACE", fallback: "Replace all data")
  /// All current transactions and categories will be deleted. This cannot be undone.
  internal static let backupsImportReplaceWarning = L10n.tr("Localizable", "BACKUPS_IMPORT_REPLACE_WARNING", fallback: "All current transactions and categories will be deleted. This cannot be undone.")
  /// Import
  internal static let backupsImportSection = L10n.tr("Localizable", "BACKUPS_IMPORT_SECTION", fallback: "Import")
  /// Income skipped: %d
  internal static func backupsImportSkipped(_ p1: Int) -> String {
    return L10n.tr("Localizable", "BACKUPS_IMPORT_SKIPPED", p1, fallback: "Income skipped: %d")
  }
  /// Delete all and reset
  internal static let backupsResetAction = L10n.tr("Localizable", "BACKUPS_RESET_ACTION", fallback: "Delete all and reset")
  /// All transactions, categories and settings will be deleted. This cannot be undone.
  internal static let backupsResetWarning = L10n.tr("Localizable", "BACKUPS_RESET_WARNING", fallback: "All transactions, categories and settings will be deleted. This cannot be undone.")
  /// Export data
  internal static let backupsShareAction = L10n.tr("Localizable", "BACKUPS_SHARE_ACTION", fallback: "Export data")
  /// Transactions: %d
  internal static func backupsTransactionsCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "BACKUPS_TRANSACTIONS_COUNT", p1, fallback: "Transactions: %d")
  }
  /// Available
  internal static let budgetAvailable = L10n.tr("Localizable", "BUDGET_AVAILABLE", fallback: "Available")
  /// Exceeded by %@
  internal static func budgetExceeded(_ p1: Any) -> String {
    return L10n.tr("Localizable", "BUDGET_EXCEEDED", String(describing: p1), fallback: "Exceeded by %@")
  }
  /// Budget for %@
  internal static func budgetForCategory(_ p1: Any) -> String {
    return L10n.tr("Localizable", "BUDGET_FOR_CATEGORY", String(describing: p1), fallback: "Budget for %@")
  }
  /// Budget for month
  internal static let budgetForMonth = L10n.tr("Localizable", "BUDGET_FOR_MONTH", fallback: "Budget for month")
  /// Left: %@
  internal static func budgetLeft(_ p1: Any) -> String {
    return L10n.tr("Localizable", "BUDGET_LEFT", String(describing: p1), fallback: "Left: %@")
  }
  /// No limit
  internal static let budgetNoLimit = L10n.tr("Localizable", "BUDGET_NO_LIMIT", fallback: "No limit")
  /// Set
  internal static let budgetSet = L10n.tr("Localizable", "BUDGET_SET", fallback: "Set")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "CANCEL", fallback: "Cancel")
  /// Cancel
  internal static let categoriesEditCancel = L10n.tr("Localizable", "CATEGORIES_EDIT_CANCEL", fallback: "Cancel")
  /// Create
  internal static let categoriesEditCreate = L10n.tr("Localizable", "CATEGORIES_EDIT_CREATE", fallback: "Create")
  /// Enter name
  internal static let categoriesEditNewFolderAlertPlaceholder = L10n.tr("Localizable", "CATEGORIES_EDIT_NEW_FOLDER_ALERT_PLACEHOLDER", fallback: "Enter name")
  /// New folder category
  internal static let categoriesEditNewFolderAlertTitle = L10n.tr("Localizable", "CATEGORIES_EDIT_NEW_FOLDER_ALERT_TITLE", fallback: "New folder category")
  /// Edit categories
  internal static let categoriesEditTitle = L10n.tr("Localizable", "CATEGORIES_EDIT_TITLE", fallback: "Edit categories")
  /// Clear
  internal static let clear = L10n.tr("Localizable", "CLEAR", fallback: "Clear")
  /// Close
  internal static let close = L10n.tr("Localizable", "CLOSE", fallback: "Close")
  /// Continue
  internal static let `continue` = L10n.tr("Localizable", "CONTINUE", fallback: "Continue")
  /// Car
  internal static let defaultCategoryCar = L10n.tr("Localizable", "DEFAULT_CATEGORY_CAR", fallback: "Car")
  /// Gas
  internal static let defaultCategoryCarFuel = L10n.tr("Localizable", "DEFAULT_CATEGORY_CAR_FUEL", fallback: "Gas")
  /// Maintenance
  internal static let defaultCategoryCarMaintenance = L10n.tr("Localizable", "DEFAULT_CATEGORY_CAR_MAINTENANCE", fallback: "Maintenance")
  /// Parking
  internal static let defaultCategoryCarParking = L10n.tr("Localizable", "DEFAULT_CATEGORY_CAR_PARKING", fallback: "Parking")
  /// Charity
  internal static let defaultCategoryCharity = L10n.tr("Localizable", "DEFAULT_CATEGORY_CHARITY", fallback: "Charity")
  /// Clothing
  internal static let defaultCategoryClothing = L10n.tr("Localizable", "DEFAULT_CATEGORY_CLOTHING", fallback: "Clothing")
  /// Digital services
  internal static let defaultCategoryDigitalServices = L10n.tr("Localizable", "DEFAULT_CATEGORY_DIGITAL_SERVICES", fallback: "Digital services")
  /// Electronics
  internal static let defaultCategoryElectronics = L10n.tr("Localizable", "DEFAULT_CATEGORY_ELECTRONICS", fallback: "Electronics")
  /// Family
  internal static let defaultCategoryFamily = L10n.tr("Localizable", "DEFAULT_CATEGORY_FAMILY", fallback: "Family")
  /// Food
  internal static let defaultCategoryFood = L10n.tr("Localizable", "DEFAULT_CATEGORY_FOOD", fallback: "Food")
  /// Groceries
  internal static let defaultCategoryFoodGroceries = L10n.tr("Localizable", "DEFAULT_CATEGORY_FOOD_GROCERIES", fallback: "Groceries")
  /// Restaurants
  internal static let defaultCategoryFoodRestaurants = L10n.tr("Localizable", "DEFAULT_CATEGORY_FOOD_RESTAURANTS", fallback: "Restaurants")
  /// Health & beauty
  internal static let defaultCategoryHealthBeauty = L10n.tr("Localizable", "DEFAULT_CATEGORY_HEALTH_BEAUTY", fallback: "Health & beauty")
  /// Home
  internal static let defaultCategoryHome = L10n.tr("Localizable", "DEFAULT_CATEGORY_HOME", fallback: "Home")
  /// Household
  internal static let defaultCategoryHomeHousehold = L10n.tr("Localizable", "DEFAULT_CATEGORY_HOME_HOUSEHOLD", fallback: "Household")
  /// Utilities
  internal static let defaultCategoryHomeUtilities = L10n.tr("Localizable", "DEFAULT_CATEGORY_HOME_UTILITIES", fallback: "Utilities")
  /// Other
  internal static let defaultCategoryOther = L10n.tr("Localizable", "DEFAULT_CATEGORY_OTHER", fallback: "Other")
  /// Pets
  internal static let defaultCategoryPets = L10n.tr("Localizable", "DEFAULT_CATEGORY_PETS", fallback: "Pets")
  /// Public transit
  internal static let defaultCategoryPublicTransit = L10n.tr("Localizable", "DEFAULT_CATEGORY_PUBLIC_TRANSIT", fallback: "Public transit")
  /// Repairs
  internal static let defaultCategoryRepair = L10n.tr("Localizable", "DEFAULT_CATEGORY_REPAIR", fallback: "Repairs")
  /// Salary
  internal static let defaultCategorySalary = L10n.tr("Localizable", "DEFAULT_CATEGORY_SALARY", fallback: "Salary")
  /// Savings
  internal static let defaultCategorySavings = L10n.tr("Localizable", "DEFAULT_CATEGORY_SAVINGS", fallback: "Savings")
  /// Taxes
  internal static let defaultCategoryTaxes = L10n.tr("Localizable", "DEFAULT_CATEGORY_TAXES", fallback: "Taxes")
  /// Taxi & rideshare
  internal static let defaultCategoryTaxi = L10n.tr("Localizable", "DEFAULT_CATEGORY_TAXI", fallback: "Taxi & rideshare")
  /// Transportation
  internal static let defaultCategoryTransport = L10n.tr("Localizable", "DEFAULT_CATEGORY_TRANSPORT", fallback: "Transportation")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "DELETE", fallback: "Delete")
  /// Done
  internal static let done = L10n.tr("Localizable", "DONE", fallback: "Done")
  /// Color
  internal static let editCategoryColor = L10n.tr("Localizable", "EDIT_CATEGORY_COLOR", fallback: "Color")
  /// Create
  internal static let editCategoryCreate = L10n.tr("Localizable", "EDIT_CATEGORY_CREATE", fallback: "Create")
  /// Category name
  internal static let editCategoryDefaultName = L10n.tr("Localizable", "EDIT_CATEGORY_DEFAULT_NAME", fallback: "Category name")
  /// Remove category
  internal static let editCategoryDeleteCategory = L10n.tr("Localizable", "EDIT_CATEGORY_DELETE_CATEGORY", fallback: "Remove category")
  /// The category and all its transactions will be moved to the Trash.
  internal static let editCategoryDeleteConfirmation = L10n.tr("Localizable", "EDIT_CATEGORY_DELETE_CONFIRMATION", fallback: "The category and all its transactions will be moved to the Trash.")
  /// Remove folder
  internal static let editCategoryDeleteFolder = L10n.tr("Localizable", "EDIT_CATEGORY_DELETE_FOLDER", fallback: "Remove folder")
  /// Icon
  internal static let editCategoryIcon = L10n.tr("Localizable", "EDIT_CATEGORY_ICON", fallback: "Icon")
  /// More
  internal static let editCategoryMoreIcons = L10n.tr("Localizable", "EDIT_CATEGORY_MORE_ICONS", fallback: "More")
  /// Name
  internal static let editCategoryName = L10n.tr("Localizable", "EDIT_CATEGORY_NAME", fallback: "Name")
  /// Enter category name
  internal static let editCategoryNamePlaceholder = L10n.tr("Localizable", "EDIT_CATEGORY_NAME_PLACEHOLDER", fallback: "Enter category name")
  /// New category
  internal static let editCategoryNewDefaultName = L10n.tr("Localizable", "EDIT_CATEGORY_NEW_DEFAULT_NAME", fallback: "New category")
  /// New category
  internal static let editCategoryNewTitle = L10n.tr("Localizable", "EDIT_CATEGORY_NEW_TITLE", fallback: "New category")
  /// No parent
  internal static let editCategoryNoParent = L10n.tr("Localizable", "EDIT_CATEGORY_NO_PARENT", fallback: "No parent")
  /// Parent category
  internal static let editCategoryParentCategory = L10n.tr("Localizable", "EDIT_CATEGORY_PARENT_CATEGORY", fallback: "Parent category")
  /// Subcategories
  internal static let editCategorySubcategories = L10n.tr("Localizable", "EDIT_CATEGORY_SUBCATEGORIES", fallback: "Subcategories")
  /// Edit
  internal static let editCategoryTitle = L10n.tr("Localizable", "EDIT_CATEGORY_TITLE", fallback: "Edit")
  /// Error
  internal static let error = L10n.tr("Localizable", "ERROR", fallback: "Error")
  /// History
  internal static let historyTitle = L10n.tr("Localizable", "HISTORY_TITLE", fallback: "History")
  /// Everyday city expenses
  internal static let iconPickerSectionEveryday = L10n.tr("Localizable", "ICON_PICKER_SECTION_EVERYDAY", fallback: "Everyday city expenses")
  /// Health, family & activities
  internal static let iconPickerSectionHealth = L10n.tr("Localizable", "ICON_PICKER_SECTION_HEALTH", fallback: "Health, family & activities")
  /// Home, food & personal care
  internal static let iconPickerSectionHome = L10n.tr("Localizable", "ICON_PICKER_SECTION_HOME", fallback: "Home, food & personal care")
  /// Shopping, money & work
  internal static let iconPickerSectionMoney = L10n.tr("Localizable", "ICON_PICKER_SECTION_MONEY", fallback: "Shopping, money & work")
  /// Nature, weather & general symbols
  internal static let iconPickerSectionNature = L10n.tr("Localizable", "ICON_PICKER_SECTION_NATURE", fallback: "Nature, weather & general symbols")
  /// Technology, education & tools
  internal static let iconPickerSectionTech = L10n.tr("Localizable", "ICON_PICKER_SECTION_TECH", fallback: "Technology, education & tools")
  /// Transportation & travel
  internal static let iconPickerSectionTravel = L10n.tr("Localizable", "ICON_PICKER_SECTION_TRAVEL", fallback: "Transportation & travel")
  /// About
  internal static let menuAbout = L10n.tr("Localizable", "MENU_ABOUT", fallback: "About")
  /// Accounting settings
  internal static let menuAccountingSettings = L10n.tr("Localizable", "MENU_ACCOUNTING_SETTINGS", fallback: "Accounting settings")
  /// Autopayments
  internal static let menuAutopayments = L10n.tr("Localizable", "MENU_AUTOPAYMENTS", fallback: "Autopayments")
  /// Backups
  internal static let menuBackups = L10n.tr("Localizable", "MENU_BACKUPS", fallback: "Backups")
  /// Budget
  internal static let menuBudget = L10n.tr("Localizable", "MENU_BUDGET", fallback: "Budget")
  /// Categories
  internal static let menuCategories = L10n.tr("Localizable", "MENU_CATEGORIES", fallback: "Categories")
  /// Language
  internal static let menuLanguage = L10n.tr("Localizable", "MENU_LANGUAGE", fallback: "Language")
  /// App
  internal static let menuSectionApp = L10n.tr("Localizable", "MENU_SECTION_APP", fallback: "App")
  /// Data
  internal static let menuSectionData = L10n.tr("Localizable", "MENU_SECTION_DATA", fallback: "Data")
  /// General
  internal static let menuSectionGeneral = L10n.tr("Localizable", "MENU_SECTION_GENERAL", fallback: "General")
  /// Settings
  internal static let menuSettings = L10n.tr("Localizable", "MENU_SETTINGS", fallback: "Settings")
  /// Spent in %@
  internal static func menuSpentInMonth(_ p1: Any) -> String {
    return L10n.tr("Localizable", "MENU_SPENT_IN_MONTH", String(describing: p1), fallback: "Spent in %@")
  }
  /// Menu
  internal static let menuTitle = L10n.tr("Localizable", "MENU_TITLE", fallback: "Menu")
  /// Trash
  internal static let menuTrash = L10n.tr("Localizable", "MENU_TRASH", fallback: "Trash")
  /// Next
  internal static let next = L10n.tr("Localizable", "NEXT", fallback: "Next")
  /// No
  internal static let no = L10n.tr("Localizable", "NO", fallback: "No")
  /// OK
  internal static let ok = L10n.tr("Localizable", "OK", fallback: "OK")
  /// Unlock the app
  internal static let passcodeBiometricsReason = L10n.tr("Localizable", "PASSCODE_BIOMETRICS_REASON", fallback: "Unlock the app")
  /// Enter passcode
  internal static let passcodeEnter = L10n.tr("Localizable", "PASSCODE_ENTER", fallback: "Enter passcode")
  /// Enter current passcode
  internal static let passcodeEnterCurrent = L10n.tr("Localizable", "PASSCODE_ENTER_CURRENT", fallback: "Enter current passcode")
  /// Enter new passcode
  internal static let passcodeEnterNew = L10n.tr("Localizable", "PASSCODE_ENTER_NEW", fallback: "Enter new passcode")
  /// Passcodes don’t match
  internal static let passcodeMismatch = L10n.tr("Localizable", "PASSCODE_MISMATCH", fallback: "Passcodes don’t match")
  /// Repeat passcode
  internal static let passcodeRepeat = L10n.tr("Localizable", "PASSCODE_REPEAT", fallback: "Repeat passcode")
  /// Wrong passcode
  internal static let passcodeWrong = L10n.tr("Localizable", "PASSCODE_WRONG", fallback: "Wrong passcode")
  /// Remove
  internal static let remove = L10n.tr("Localizable", "REMOVE", fallback: "Remove")
  /// Repeat
  internal static let `repeat` = L10n.tr("Localizable", "REPEAT", fallback: "Repeat")
  /// RETRY
  internal static let retry = L10n.tr("Localizable", "RETRY", fallback: "RETRY")
  /// Save
  internal static let save = L10n.tr("Localizable", "SAVE", fallback: "Save")
  /// Appearance
  internal static let settingsAppearance = L10n.tr("Localizable", "SETTINGS_APPEARANCE", fallback: "Appearance")
  /// Haptic
  internal static let settingsHaptic = L10n.tr("Localizable", "SETTINGS_HAPTIC", fallback: "Haptic")
  /// Hide categories
  internal static let settingsHideCategories = L10n.tr("Localizable", "SETTINGS_HIDE_CATEGORIES", fallback: "Hide categories")
  /// Categories appear when you enter an amount
  internal static let settingsHideCategoriesDescription = L10n.tr("Localizable", "SETTINGS_HIDE_CATEGORIES_DESCRIPTION", fallback: "Categories appear when you enter an amount")
  /// Passcode
  internal static let settingsPasscode = L10n.tr("Localizable", "SETTINGS_PASSCODE", fallback: "Passcode")
  /// Change passcode
  internal static let settingsPasscodeChange = L10n.tr("Localizable", "SETTINGS_PASSCODE_CHANGE", fallback: "Change passcode")
  /// Security
  internal static let settingsSecurity = L10n.tr("Localizable", "SETTINGS_SECURITY", fallback: "Security")
  /// Sounds
  internal static let settingsSounds = L10n.tr("Localizable", "SETTINGS_SOUNDS", fallback: "Sounds")
  /// Dark
  internal static let settingsThemeDark = L10n.tr("Localizable", "SETTINGS_THEME_DARK", fallback: "Dark")
  /// Ember
  internal static let settingsThemeEmber = L10n.tr("Localizable", "SETTINGS_THEME_EMBER", fallback: "Ember")
  /// Forest
  internal static let settingsThemeForest = L10n.tr("Localizable", "SETTINGS_THEME_FOREST", fallback: "Forest")
  /// Gray
  internal static let settingsThemeGray = L10n.tr("Localizable", "SETTINGS_THEME_GRAY", fallback: "Gray")
  /// Indigo
  internal static let settingsThemeIndigo = L10n.tr("Localizable", "SETTINGS_THEME_INDIGO", fallback: "Indigo")
  /// Light
  internal static let settingsThemeLight = L10n.tr("Localizable", "SETTINGS_THEME_LIGHT", fallback: "Light")
  /// Liquid black
  internal static let settingsThemeLiquidBlack = L10n.tr("Localizable", "SETTINGS_THEME_LIQUID_BLACK", fallback: "Liquid black")
  /// Midnight
  internal static let settingsThemeMidnight = L10n.tr("Localizable", "SETTINGS_THEME_MIDNIGHT", fallback: "Midnight")
  /// Orange
  internal static let settingsThemeOrange = L10n.tr("Localizable", "SETTINGS_THEME_ORANGE", fallback: "Orange")
  /// Slate
  internal static let settingsThemeSlate = L10n.tr("Localizable", "SETTINGS_THEME_SLATE", fallback: "Slate")
  /// System
  internal static let settingsThemeSystem = L10n.tr("Localizable", "SETTINGS_THEME_SYSTEM", fallback: "System")
  /// Share
  internal static let share = L10n.tr("Localizable", "SHARE", fallback: "Share")
  /// Something went wrong...
  internal static let somethingWentWrong = L10n.tr("Localizable", "SOMETHING_WENT_WRONG", fallback: "Something went wrong...")
  /// Balance
  internal static let startviewBalance = L10n.tr("Localizable", "STARTVIEW_BALANCE", fallback: "Balance")
  /// Enter the amount first
  internal static let startviewEnterAmountFirst = L10n.tr("Localizable", "STARTVIEW_ENTER_AMOUNT_FIRST", fallback: "Enter the amount first")
  /// Enter expense
  internal static let startviewEnterExpense = L10n.tr("Localizable", "STARTVIEW_ENTER_EXPENSE", fallback: "Enter expense")
  /// Enter income
  internal static let startviewEnterIncome = L10n.tr("Localizable", "STARTVIEW_ENTER_INCOME", fallback: "Enter income")
  /// average: %@ per day
  internal static func statisticsAveragePerDay(_ p1: Any) -> String {
    return L10n.tr("Localizable", "STATISTICS_AVERAGE_PER_DAY", String(describing: p1), fallback: "average: %@ per day")
  }
  /// average: %@ per month
  internal static func statisticsAveragePerMonth(_ p1: Any) -> String {
    return L10n.tr("Localizable", "STATISTICS_AVERAGE_PER_MONTH", String(describing: p1), fallback: "average: %@ per month")
  }
  /// average: %@ per year
  internal static func statisticsAveragePerYear(_ p1: Any) -> String {
    return L10n.tr("Localizable", "STATISTICS_AVERAGE_PER_YEAR", String(describing: p1), fallback: "average: %@ per year")
  }
  /// Chart
  internal static let statisticsChart = L10n.tr("Localizable", "STATISTICS_CHART", fallback: "Chart")
  /// Day
  internal static let statisticsDay = L10n.tr("Localizable", "STATISTICS_DAY", fallback: "Day")
  /// Income
  internal static let statisticsIncomeTitle = L10n.tr("Localizable", "STATISTICS_INCOME_TITLE", fallback: "Income")
  /// Month
  internal static let statisticsMonth = L10n.tr("Localizable", "STATISTICS_MONTH", fallback: "Month")
  /// Expenses
  internal static let statisticsTitle = L10n.tr("Localizable", "STATISTICS_TITLE", fallback: "Expenses")
  /// Total spent
  internal static let statisticsTotalSpent = L10n.tr("Localizable", "STATISTICS_TOTAL_SPENT", fallback: "Total spent")
  /// Year
  internal static let statisticsYear = L10n.tr("Localizable", "STATISTICS_YEAR", fallback: "Year")
  /// Support
  internal static let support = L10n.tr("Localizable", "SUPPORT", fallback: "Support")
  /// Home
  internal static let tabHome = L10n.tr("Localizable", "TAB_HOME", fallback: "Home")
  /// Statistics
  internal static let tabStatistics = L10n.tr("Localizable", "TAB_STATISTICS", fallback: "Statistics")
  /// By amount
  internal static let transactionDetailsSortByAmount = L10n.tr("Localizable", "TRANSACTION_DETAILS_SORT_BY_AMOUNT", fallback: "By amount")
  /// By date
  internal static let transactionDetailsSortByDate = L10n.tr("Localizable", "TRANSACTION_DETAILS_SORT_BY_DATE", fallback: "By date")
  /// Add note
  internal static let transactionEditAddNote = L10n.tr("Localizable", "TRANSACTION_EDIT_ADD_NOTE", fallback: "Add note")
  /// Amount
  internal static let transactionEditAmount = L10n.tr("Localizable", "TRANSACTION_EDIT_AMOUNT", fallback: "Amount")
  /// Account
  internal static let transactionEditBalance = L10n.tr("Localizable", "TRANSACTION_EDIT_BALANCE", fallback: "Account")
  /// Categories
  internal static let transactionEditCategoriesTitle = L10n.tr("Localizable", "TRANSACTION_EDIT_CATEGORIES_TITLE", fallback: "Categories")
  /// Category
  internal static let transactionEditCategory = L10n.tr("Localizable", "TRANSACTION_EDIT_CATEGORY", fallback: "Category")
  /// Date
  internal static let transactionEditDate = L10n.tr("Localizable", "TRANSACTION_EDIT_DATE", fallback: "Date")
  /// Delete transaction
  internal static let transactionEditDelete = L10n.tr("Localizable", "TRANSACTION_EDIT_DELETE", fallback: "Delete transaction")
  /// Delete transaction?
  internal static let transactionEditDeleteConfirmation = L10n.tr("Localizable", "TRANSACTION_EDIT_DELETE_CONFIRMATION", fallback: "Delete transaction?")
  /// Time
  internal static let transactionEditTime = L10n.tr("Localizable", "TRANSACTION_EDIT_TIME", fallback: "Time")
  /// Edit
  internal static let transactionEditTitle = L10n.tr("Localizable", "TRANSACTION_EDIT_TITLE", fallback: "Edit")
  /// Delete
  internal static let transactionsListDelete = L10n.tr("Localizable", "TRANSACTIONS_LIST_DELETE", fallback: "Delete")
  /// Moved to Trash
  internal static let transactionsListMovedToTrash = L10n.tr("Localizable", "TRANSACTIONS_LIST_MOVED_TO_TRASH", fallback: "Moved to Trash")
  /// No transactions
  internal static let transactionsListNoTransactions = L10n.tr("Localizable", "TRANSACTIONS_LIST_NO_TRANSACTIONS", fallback: "No transactions")
  /// Received today
  internal static let transactionsListReceivedToday = L10n.tr("Localizable", "TRANSACTIONS_LIST_RECEIVED_TODAY", fallback: "Received today")
  /// Received yesterday
  internal static let transactionsListReceivedYesterday = L10n.tr("Localizable", "TRANSACTIONS_LIST_RECEIVED_YESTERDAY", fallback: "Received yesterday")
  /// Spent today
  internal static let transactionsListSpentToday = L10n.tr("Localizable", "TRANSACTIONS_LIST_SPENT_TODAY", fallback: "Spent today")
  /// Spent yesterday
  internal static let transactionsListSpentYesterday = L10n.tr("Localizable", "TRANSACTIONS_LIST_SPENT_YESTERDAY", fallback: "Spent yesterday")
  /// Transaction added
  internal static let transactionsListTransactionAdded = L10n.tr("Localizable", "TRANSACTIONS_LIST_TRANSACTION_ADDED", fallback: "Transaction added")
  /// Transaction updated
  internal static let transactionsListTransactionUpdated = L10n.tr("Localizable", "TRANSACTIONS_LIST_TRANSACTION_UPDATED", fallback: "Transaction updated")
  /// All items in the Trash will be permanently deleted. This action cannot be undone.
  internal static let trashClearConfirmation = L10n.tr("Localizable", "TRASH_CLEAR_CONFIRMATION", fallback: "All items in the Trash will be permanently deleted. This action cannot be undone.")
  /// Delete account?
  internal static let trashDeleteAccountConfirmation = L10n.tr("Localizable", "TRASH_DELETE_ACCOUNT_CONFIRMATION", fallback: "Delete account?")
  /// Delete autopayment?
  internal static let trashDeleteAutopaymentConfirmation = L10n.tr("Localizable", "TRASH_DELETE_AUTOPAYMENT_CONFIRMATION", fallback: "Delete autopayment?")
  /// Delete category?
  internal static let trashDeleteCategoryConfirmation = L10n.tr("Localizable", "TRASH_DELETE_CATEGORY_CONFIRMATION", fallback: "Delete category?")
  /// This action cannot be undone.
  internal static let trashDeleteMessage = L10n.tr("Localizable", "TRASH_DELETE_MESSAGE", fallback: "This action cannot be undone.")
  /// Trash is empty
  internal static let trashEmpty = L10n.tr("Localizable", "TRASH_EMPTY", fallback: "Trash is empty")
  /// Restore account?
  internal static let trashRestoreAccountConfirmation = L10n.tr("Localizable", "TRASH_RESTORE_ACCOUNT_CONFIRMATION", fallback: "Restore account?")
  /// Restore autopayment?
  internal static let trashRestoreAutopaymentConfirmation = L10n.tr("Localizable", "TRASH_RESTORE_AUTOPAYMENT_CONFIRMATION", fallback: "Restore autopayment?")
  /// Restore category?
  internal static let trashRestoreCategoryConfirmation = L10n.tr("Localizable", "TRASH_RESTORE_CATEGORY_CONFIRMATION", fallback: "Restore category?")
  /// Restore transaction?
  internal static let trashRestoreTransactionConfirmation = L10n.tr("Localizable", "TRASH_RESTORE_TRANSACTION_CONFIRMATION", fallback: "Restore transaction?")
  /// Undo
  internal static let undo = L10n.tr("Localizable", "UNDO", fallback: "Undo")
  /// Update
  internal static let update = L10n.tr("Localizable", "UPDATE", fallback: "Update")
  /// Yes
  internal static let yes = L10n.tr("Localizable", "YES", fallback: "Yes")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
