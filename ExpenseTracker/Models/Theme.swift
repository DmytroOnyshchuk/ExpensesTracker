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

    var iconColors: [IconColor: Color] = Theme.systemIconColors

    func color(for iconColor: IconColor) -> Color {
        iconColors[iconColor] ?? Theme.systemIconColors[iconColor] ?? .gray
    }
}

enum ThemePreset: String, CaseIterable, Identifiable, Codable {
    case classic
    case ember
    case midnight
    case forest
    case gray
    case liquidBlack
    case slate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: L10n.settingsThemeClassic
        case .ember: L10n.settingsThemeEmber
        case .midnight: L10n.settingsThemeMidnight
        case .forest: L10n.settingsThemeForest
        case .gray: L10n.settingsThemeGray
        case .liquidBlack: L10n.settingsThemeIndigo
        case .slate: L10n.settingsThemeSlate
        }
    }

    var theme: Theme {
        switch self {
        case .classic: .classic
        case .ember: .ember
        case .midnight: .midnight
        case .forest: .forest
        case .gray: .gray
        case .liquidBlack: .liquidBlack
        case .slate: .slate
        }
    }
}

extension Theme {
    static let systemIconColors: [IconColor: Color] = [
        .red: .red,
        .pink: .pink,
        .blue: .blue,
        .yellow: .yellow,
        .orange: .orange,
        .purple: .purple,
        .green: .green,
        .brown: .brown,
        .white: .white,
        .cyan: .cyan,
        .indigo: .indigo,
        .gray: .gray,
        .black: .black,
    ]

    static let classic = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#0F0F10"),
        appSecond: Color(hex: "#1F1F21"),
        appLabel: Color(hex: "#A0B3BC"),
        appWhite: Color(hex: "#F7F7F8"),
        appBlack: Color(hex: "#000000"),
        appLightGrey: Color(hex: "#E6EAEC"),
        appPrimary: Color(hex: "#E6E6E8"),
        appDarkGreen: Color(hex: "#35B98D"),
        appGray: Color(hex: "#85878B"),
        appYellow: Color(hex: "#FFD000"),
        appRed: Color(hex: "#FF625C"),
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
}
