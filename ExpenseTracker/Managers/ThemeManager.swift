import Observation
import SwiftUI

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    @ObservationIgnored
    @UserDefault(.theme, defaultValue: nil) private var storedPreset: String?

    var preset: ThemePreset {
        didSet {
            guard preset != oldValue else { return }
            storedPreset = preset.rawValue
        }
    }

    var theme: Theme { preset.theme }

    var colorScheme: ColorScheme { theme.colorScheme }

    private init() {
        self.preset = .classic
        if let storedPreset, let saved = ThemePreset(rawValue: storedPreset) {
            self.preset = saved
        }
    }
}
