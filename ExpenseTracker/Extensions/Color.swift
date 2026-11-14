import SwiftUI

extension Color {
    init(hex: String?, opacity: Double = 1) {
        guard let hex else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: opacity)
            return
        }

        var red: Double = .zero
        var green: Double = .zero
        var blue: Double = .zero
        var opacity: Double = opacity

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            var hexNumber: UInt64 = .zero
            let scanner = Scanner(string: hexColor)
            scanner.scanHexInt64(&hexNumber)

            if hexColor.count == 8 {
                red = Double((hexNumber & 0xFF00_0000) >> 24) / 255.0
                green = Double((hexNumber & 0x00FF_0000) >> 16) / 255.0
                blue = Double((hexNumber & 0x0000_FF00) >> 8) / 255.0
                opacity = Double(hexNumber & 0x0000_00FF) / 255.0
            } else if hexColor.count == 6 {
                red = Double((hexNumber >> 16) & 0xFF) / 255.0
                green = Double((hexNumber >> 8) & 0xFF) / 255.0
                blue = Double(hexNumber & 0xFF) / 255.0
            }
        }
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    init(red: Int, green: Int, blue: Int) {
        precondition(0 ... 255 ~= red &&
            0 ... 255 ~= green &&
            0 ... 255 ~= blue, "input range is out of range 0...255")

        self.init(.sRGB, red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0, opacity: 1)
    }

    init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    static func random() -> Color {
        let red = Int.random(in: 0 ... 255)
        let green = Int.random(in: 0 ... 255)
        let blue = Int.random(in: 0 ... 255)

        return Color(red: red, green: green, blue: blue)
    }
}

extension Color {
    static var appMain: Color { ThemeManager.shared.theme.appMain }
    static var appSecond: Color { ThemeManager.shared.theme.appSecond }
    static var appLabel: Color { ThemeManager.shared.theme.appLabel }

    static var appWhite: Color { ThemeManager.shared.theme.appWhite }
    static var appBlack: Color { ThemeManager.shared.theme.appBlack }
    static var appLightGrey: Color { ThemeManager.shared.theme.appLightGrey }

    static var appPrimary: Color { ThemeManager.shared.theme.appPrimary }
    static var appDarkGreen: Color { ThemeManager.shared.theme.appDarkGreen }

    static var appGray: Color { ThemeManager.shared.theme.appGray }
    static var appYellow: Color { ThemeManager.shared.theme.appYellow }
    static var appRed: Color { ThemeManager.shared.theme.appRed }
    static var appOverlay: Color { ThemeManager.shared.theme.appOverlay }
}

extension ShapeStyle where Self == Color {
    static var appMain: Color { Color.appMain }
    static var appSecond: Color { Color.appSecond }
    static var appLabel: Color { Color.appLabel }

    static var appWhite: Color { Color.appWhite }
    static var appBlack: Color { Color.appBlack }
    static var appLightGrey: Color { Color.appLightGrey }

    static var appPrimary: Color { Color.appPrimary }
    static var appDarkGreen: Color { Color.appDarkGreen }

    static var appGray: Color { Color.appGray }
    static var appYellow: Color { Color.appYellow }
    static var appRed: Color { Color.appRed }
    static var appOverlay: Color { Color.appOverlay }
}
