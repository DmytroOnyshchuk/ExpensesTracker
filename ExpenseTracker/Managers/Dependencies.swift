import Foundation

extension DependencyManager {
    static func makeDefault() -> DependencyManager {
        let userManager = UserManager.shared
        let themeManager = ThemeManager.shared
        let feedbackManager = FeedbackManager.shared

        return DependencyManager {
            Module { userManager }
            Module { themeManager }
            Module { feedbackManager }
        }
    }
}
