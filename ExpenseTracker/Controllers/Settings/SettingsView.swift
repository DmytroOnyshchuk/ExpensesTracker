import SwiftUI

struct SettingsView: View {
    @StoredSettings private var appSettings

    @Inject private var themeManager: ThemeManager
    @Inject private var feedbackManager: FeedbackManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.settingsAppearance)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ThemePreset.allCases) { preset in
                            ThemePresetCell(preset: preset, isSelected: preset == themeManager.preset) {
                                select(preset)
                            }
                        }
                    }
                    .padding(16)
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                }

                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.menuSectionGeneral)

                    VStack(spacing: 0) {
                        toggleRow(L10n.settingsSounds, systemImage: "speaker.wave.2", isOn: $appSettings.feedback.soundsEnabled)

                        MenuRowDivider()

                        toggleRow(L10n.settingsHaptic, systemImage: "iphone.radiowaves.left.and.right", isOn: $appSettings.feedback.hapticEnabled)

                        MenuRowDivider()

                        toggleRow(
                            L10n.settingsHideCategories,
                            subtitle: L10n.settingsHideCategoriesDescription,
                            systemImage: "square.grid.2x2.fill",
                            isOn: $appSettings.hideCategories
                        )
                    }
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuSettings)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleRow(_ title: String, subtitle: String? = nil, systemImage: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 17))
                    .foregroundColor(.appPrimary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appLight(16))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if let subtitle {
                        Text(subtitle)
                            .font(.appLight(12))
                            .foregroundColor(.appLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(minHeight: 46)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { isOn.wrappedValue.toggle() }
        }
    }

    private func select(_ preset: ThemePreset) {
        guard preset != themeManager.preset else { return }
        feedbackManager.buttonTapped()
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
        let theme = preset.theme(for: ThemeManager.shared.systemColorScheme)

        Button(action: action) {
            VStack(spacing: 10) {
                preview(theme)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? theme.appPrimary : theme.appLabel.opacity(0.4), lineWidth: isSelected ? 3 : 1)
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

    @ViewBuilder
    private func preview(_ theme: Theme) -> some View {
        if preset == .system {
            ZStack {
                Theme.light.appMain
                Theme.dark.appMain
                    .clipShape(DiagonalHalf())
                DiagonalLine()
                    .stroke(Theme.dark.appGray, lineWidth: 1.5)
            }
        } else {
            HStack(spacing: 6) {
                ForEach(Array([theme.appPrimary, theme.appWhite, theme.appLabel].enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color)
                        .frame(width: 16, height: 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.appMain)
        }
    }
}

struct DiagonalHalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct DiagonalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
}
