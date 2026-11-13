import SwiftUI

struct SettingsView: View {
    private let themeManager = ThemeManager.shared

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.settingsAppearance)
                    .font(.appLight(15))
                    .foregroundColor(.appLabel)
                    .padding(.horizontal, 6)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ThemePreset.allCases) { preset in
                        ThemePresetCell(preset: preset, isSelected: preset == themeManager.preset) {
                            select(preset)
                        }
                    }
                }
                .padding(16)
                .background(.appLabel.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .navigationTitle(L10n.menuSettings)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func select(_ preset: ThemePreset) {
        guard preset != themeManager.preset else { return }
        FeedbackManager.buttonTapped()
        withAnimation(.easeInOut(duration: 0.25)) {
            themeManager.preset = preset
        }
    }
}

struct ThemePresetCell: View {
    let preset: ThemePreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let theme = preset.theme

        Button(action: action) {
            VStack(spacing: 10) {
                HStack(spacing: 6) {
                    ForEach(Array([theme.appBlue, theme.appWhite, theme.appLabel].enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(color)
                            .frame(width: 16, height: 16)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(theme.appMain)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? theme.appBlue : theme.appLabel.opacity(0.4), lineWidth: isSelected ? 3 : 1)
                }

                Text(preset.title)
                    .font(.appLight(15))
                    .foregroundColor(isSelected ? .appWhite : .appLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
}
