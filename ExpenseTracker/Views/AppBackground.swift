import SwiftUI

struct AppBackground: View {
    var body: some View {
        let isDark = ThemeManager.shared.theme.colorScheme == .dark

        LinearGradient(
            stops: [
                .init(color: .appMain.mix(with: .appPrimary, by: isDark ? 0.22 : 0.1), location: 0),
                .init(color: .appMain.mix(with: .appPrimary, by: isDark ? 0.06 : 0.03), location: 0.45),
                .init(color: isDark ? .appMain.mix(with: .appBlack, by: 0.35) : .appMain, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func appBackground() -> some View {
        background {
            AppBackground()
        }
    }
}

#Preview {
    AppBackground()
}
