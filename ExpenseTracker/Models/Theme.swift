import SwiftUI

struct Theme {
    let colorScheme: ColorScheme

    let appMain: Color
    let appSecond: Color
    let appLabel: Color

    let appWhite: Color
    let appBlack: Color
    let appLightGrey: Color

    let appPrimary: Color
    let appDarkGreen: Color

    let appGray: Color
    let appYellow: Color
    let appRed: Color
    let appOverlay: Color
}

enum ThemePreset: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark
    case ember
    case orange
    case indigo
    case gray
    case midnight
    case forest
    case slate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: L10n.settingsThemeSystem
        case .dark: L10n.settingsThemeDark
        case .ember: L10n.settingsThemeEmber
        case .midnight: L10n.settingsThemeMidnight
        case .forest: L10n.settingsThemeForest
        case .gray: L10n.settingsThemeGray
        case .indigo: L10n.settingsThemeIndigo
        case .slate: L10n.settingsThemeSlate
        case .orange: L10n.settingsThemeOrange
        case .light: L10n.settingsThemeLight
        }
    }

    func theme(for systemColorScheme: ColorScheme) -> Theme {
        switch self {
        case .system: systemColorScheme == .dark ? .dark : .light
        case .dark: .dark
        case .ember: .ember
        case .midnight: .midnight
        case .forest: .forest
        case .gray: .gray
        case .indigo: .liquidBlack
        case .slate: .slate
        case .orange: .orange
        case .light: .light
        }
    }
}

extension Theme {
    static let dark = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#111416"),
        appSecond: Color(hex: "#1F1F21"),
        appLabel: Color(hex: "#A0B3BC"),
        appWhite: Color(hex: "#F7F7F8"),
        appBlack: Color(hex: "#000000"),
        appLightGrey: Color(hex: "#E6EAEC"),
        appPrimary: Color(hex: "#E6E6E8"),
        appDarkGreen: Color(hex: "#35B98D"),
        appGray: Color(hex: "#85878B"),
        appYellow: Color(hex: "#FFD000"),
        appRed: Color(hex: "#F33F4D"),
        appOverlay: .black
    )

    static let ember = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#1B1715"),
        appSecond: Color(hex: "#2B2421"),
        appLabel: Color(hex: "#B7A69B"),
        appWhite: Color(hex: "#F5F0ED"),
        appBlack: Color(hex: "#100D0B"),
        appLightGrey: Color(hex: "#E9DFD9"),
        appPrimary: Color(hex: "#D58B63"),
        appDarkGreen: Color(hex: "#75966B"),
        appGray: Color(hex: "#88776D"),
        appYellow: Color(hex: "#E9B96E"),
        appRed: Color(hex: "#D96F63"),
        appOverlay: .black
    )

    static let midnight = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#12141C"),
        appSecond: Color(hex: "#1F2330"),
        appLabel: Color(hex: "#8A91A6"),
        appWhite: Color(hex: "#F2F4F8"),
        appBlack: Color(hex: "#000000"),
        appLightGrey: Color(hex: "#E3E6EE"),
        appPrimary: Color(hex: "#6C8CFF"),
        appDarkGreen: Color(hex: "#2FA36B"),
        appGray: Color(hex: "#6B7183"),
        appYellow: Color(hex: "#FFD166"),
        appRed: Color(hex: "#FF5C6C"),
        appOverlay: .black
    )

    static let forest = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#1F2E28"),
        appSecond: Color(hex: "#2F443B"),
        appLabel: Color(hex: "#9DB3A6"),
        appWhite: Color(hex: "#F4F7F2"),
        appBlack: Color(hex: "#0B120F"),
        appLightGrey: Color(hex: "#E6ECE6"),
        appPrimary: Color(hex: "#5FD19A"),
        appDarkGreen: Color(hex: "#349C5D"),
        appGray: Color(hex: "#7C8F84"),
        appYellow: Color(hex: "#F2C14E"),
        appRed: Color(hex: "#F2665C"),
        appOverlay: .black
    )

    static let gray = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#2C2C2E"),
        appSecond: Color(hex: "#3A3A3C"),
        appLabel: Color(hex: "#98989F"),
        appWhite: Color(hex: "#F2F2F7"),
        appBlack: Color(hex: "#111111"),
        appLightGrey: Color(hex: "#E5E5EA"),
        appPrimary: Color(hex: "#8FB0CC"),
        appDarkGreen: Color(hex: "#4E9E73"),
        appGray: Color(hex: "#7C7C80"),
        appYellow: Color(hex: "#D9B95B"),
        appRed: Color(hex: "#E0666A"),
        appOverlay: .black
    )

    static let liquidBlack = Theme(
        colorScheme: .dark,
        appMain: Color(.appMain),
        appSecond: Color(.appSecond),
        appLabel: Color(.appLabel),
        appWhite: Color(.appWhite),
        appBlack: Color(.appBlack),
        appLightGrey: Color(.appLightGrey),
        appPrimary: Color(.appPrimary),
        appDarkGreen: Color(.appDarkGreen),
        appGray: .gray,
        appYellow: .yellow,
        appRed: .red,
        appOverlay: .black
    )

    static let slate = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#202020"),
        appSecond: Color(hex: "#303030"),
        appLabel: Color(hex: "#8B8D91"),
        appWhite: Color(hex: "#E8E8E8"),
        appBlack: Color(hex: "#121212"),
        appLightGrey: Color(hex: "#D8D8D8"),
        appPrimary: Color(hex: "#8BAFC6"),
        appDarkGreen: Color(hex: "#45B98A"),
        appGray: Color(hex: "#85878B"),
        appYellow: Color(hex: "#FFD44A"),
        appRed: Color(hex: "#FF625C"),
        appOverlay: .black
    )

    static let orange = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#15130F"),
        appSecond: Color(hex: "#24201A"),
        appLabel: Color(hex: "#B3A791"),
        appWhite: Color(hex: "#F8F5EF"),
        appBlack: Color(hex: "#0B0906"),
        appLightGrey: Color(hex: "#ECE6DA"),
        appPrimary: Color(hex: "#FFA200"),
        appDarkGreen: Color(hex: "#4CB782"),
        appGray: Color(hex: "#8A8172"),
        appYellow: Color(hex: "#FFD23F"),
        appRed: Color(hex: "#F2554A"),
        appOverlay: .black
    )

    static let light = Theme(
        colorScheme: .light,
        appMain: Color(hex: "#ECEFF1"),
        appSecond: Color(hex: "#F6F8F9"),
        appLabel: Color(hex: "#6E7B8A"),
        appWhite: Color(hex: "#14263D"),
        appBlack: Color(hex: "#0E1A2B"),
        appLightGrey: Color(hex: "#3A4A5E"),
        appPrimary: Color(hex: "#1F3A5F"),
        appDarkGreen: Color(hex: "#17A34A"),
        appGray: Color(hex: "#9AA5B1"),
        appYellow: Color(hex: "#F5B82E"),
        appRed: Color(hex: "#E8424F"),
        appOverlay: Color(hex: "#0E1A2B")
    )
}
