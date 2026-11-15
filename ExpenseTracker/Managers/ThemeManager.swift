import Observation
import SwiftUI
import UIKit

@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    
    var preset: ThemePreset {
        didSet {
            guard preset != oldValue else { return }
            UserManager.shared.appSettings.theme = preset
            systemColorScheme = Self.currentSystemColorScheme
        }
    }

    private(set) var systemColorScheme: ColorScheme

    var theme: Theme { preset.theme(for: systemColorScheme) }

    var preferredColorScheme: ColorScheme? {
        preset == .system ? nil : theme.colorScheme
    }

    private static var currentSystemColorScheme: ColorScheme {
        UIScreen.main.traitCollection.userInterfaceStyle == .light ? .light : .dark
    }

    private init() {
        self.preset = .system
        self.systemColorScheme = Self.currentSystemColorScheme
        self.preset = UserManager.shared.appSettings.theme
    }

    func updateSystemColorScheme(_ colorScheme: ColorScheme) {
        guard preset == .system, colorScheme != systemColorScheme else { return }
        systemColorScheme = colorScheme
    }
}

struct SystemColorSchemeObserver: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.onChange(of: colorScheme, initial: true) { _, colorScheme in
            ThemeManager.shared.updateSystemColorScheme(colorScheme)
        }
    }
}
