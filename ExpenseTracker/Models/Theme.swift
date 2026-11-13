import SwiftUI

struct Theme {
    let colorScheme: ColorScheme

    let appMain: Color
    let appSecond: Color
    let appLabel: Color

    let appWhite: Color
    let appBlack: Color
    let appLightGrey: Color

    let appBlue: Color
    let appDarkGreen: Color
}

enum ThemePreset: String, CaseIterable, Identifiable, Codable {
    case classic
    case midnight
    case forest
    case light

    var id: String { rawValue }

    var theme: Theme {
        switch self {
        case .classic: .classic
        case .midnight: .midnight
        case .forest: .forest
        case .light: .light
        }
    }
}

extension Theme {
    static let classic = Theme(
        colorScheme: .dark,
        appMain: Color(.appMain),
        appSecond: Color(.appSecond),
        appLabel: Color(.appLabel),
        appWhite: Color(.appWhite),
        appBlack: Color(.appBlack),
        appLightGrey: Color(.appLightGrey),
        appBlue: Color(.appBlue),
        appDarkGreen: Color(.appDarkGreen)
    )

    static let midnight = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#12141C"),
        appSecond: Color(hex: "#1F2330"),
        appLabel: Color(hex: "#8A91A6"),
        appWhite: Color(hex: "#F2F4F8"),
        appBlack: Color(hex: "#000000"),
        appLightGrey: Color(hex: "#E3E6EE"),
        appBlue: Color(hex: "#6C8CFF"),
        appDarkGreen: Color(hex: "#2FA36B")
    )

    static let forest = Theme(
        colorScheme: .dark,
        appMain: Color(hex: "#1F2E28"),
        appSecond: Color(hex: "#2F443B"),
        appLabel: Color(hex: "#9DB3A6"),
        appWhite: Color(hex: "#F4F7F2"),
        appBlack: Color(hex: "#0B120F"),
        appLightGrey: Color(hex: "#E6ECE6"),
        appBlue: Color(hex: "#5FD19A"),
        appDarkGreen: Color(hex: "#349C5D")
    )

    static let light = Theme(
        colorScheme: .light,
        appMain: Color(hex: "#F6F6FB"),
        appSecond: Color(hex: "#E2E2EC"),
        appLabel: Color(hex: "#6E6C82"),
        appWhite: Color(hex: "#1E1D29"),
        appBlack: Color(hex: "#141414"),
        appLightGrey: Color(hex: "#403E50"),
        appBlue: Color(hex: "#2E8FB5"),
        appDarkGreen: Color(hex: "#2A7F4B")
    )
}
