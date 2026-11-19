import SwiftUI

struct SettingsView: View {
    @StoredSettings private var appSettings

    @Inject private var themeManager: ThemeManager
    @Inject private var feedbackManager: FeedbackManager

    @State private var passcodeFlow: PasscodeFlow?

    private let passcodeManager = PasscodeManager.shared

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.settingsAppearance)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ThemePreset.allCases) { preset in
                            ThemePresetCell(preset: preset, isSelected: preset == themeManager.preset) {
                                select(preset)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                }

                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.menuSectionGeneral)

                    VStack(spacing: 0) {
                        SettingsToggleRow(title: L10n.settingsSounds, systemImage: "speaker.wave.2", isOn: $appSettings.feedback.soundsEnabled)

                        MenuRowDivider()

                        SettingsToggleRow(title: L10n.settingsHaptic, systemImage: "iphone.radiowaves.left.and.right", isOn: $appSettings.feedback.hapticEnabled)

                        MenuRowDivider()

                        SettingsToggleRow(
                            title: L10n.settingsHideCategories,
                            subtitle: L10n.settingsHideCategoriesDescription,
                            systemImage: "square.grid.2x2.fill",
                            isOn: $appSettings.hideCategories
                        )
                    }
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                }

                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.settingsSecurity)

                    VStack(spacing: 0) {
                        SettingsToggleRow(title: L10n.settingsPasscode, systemImage: "lock", isOn: passcodeEnabled)

                        if passcodeManager.isPasscodeEnabled {
                            MenuRowDivider()

                            MenuRow(title: L10n.settingsPasscodeChange, systemImage: "key") {
                                passcodeFlow = .change
                            }
                        }

                        MenuRowDivider()

                        SettingsToggleRow(
                            title: passcodeManager.biometryType.title,
                            systemImage: passcodeManager.biometryType.systemImage,
                            isOn: $appSettings.security.biometricsEnabled
                        )
                        .disabled(!isBiometricsConfigurable)
                        .opacity(isBiometricsConfigurable ? 1 : 0.5)
                    }
                    .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                    .animation(.default, value: passcodeManager.isPasscodeEnabled)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuSettings)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $passcodeFlow) { flow in
            PasscodeSetupView(flow: flow)
        }
    }

    private var passcodeEnabled: Binding<Bool> {
        Binding(
            get: { passcodeManager.isPasscodeEnabled },
            set: { passcodeFlow = $0 ? .create : .disable }
        )
    }

    private var isBiometricsConfigurable: Bool {
        passcodeManager.isPasscodeEnabled && passcodeManager.isBiometryAvailable
    }

    private func select(_ preset: ThemePreset) {
        guard preset != themeManager.preset else { return }
        feedbackManager.buttonTapped()
        withAnimation(.easeInOut(duration: 0.25)) {
            themeManager.preset = preset
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
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
        .padding(.vertical, 12)
        .frame(minHeight: 46)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { isOn.toggle() }
            FeedbackManager.shared.buttonTapped()
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
            VStack(spacing: 6) {
                preview(theme)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? theme.appPrimary : theme.appLabel.opacity(0.4), lineWidth: isSelected ? 2 : 1)
                    }

                Text(preset.title)
                    .font(.appLight(12))
                    .foregroundColor(isSelected ? .appWhite : .appLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
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
                    .stroke(Theme.dark.appGray, lineWidth: 1)
            }
        } else {
            HStack(spacing: 4) {
                ForEach(Array([theme.appPrimary, theme.appWhite, theme.appLabel].enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(color)
                        .frame(width: 8, height: 8)
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
