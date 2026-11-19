import SwiftUI

struct InsetDivider: View {
    var leading: CGFloat = 16

    var body: some View {
        Rectangle()
            .fill(.appLabel.opacity(0.25))
            .frame(height: 0.5)
            .padding(.leading, leading)
            .padding(.trailing, 16)
    }
}

struct RoundIconButton: View {
    let systemImage: String
    var color: Color = .appPrimary
    var tint: Color?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .glassSurface(in: Circle(), tint: tint?.opacity(0.15), isInteractive: true, fallback: (tint ?? .appLabel).opacity(tint == nil ? 0.1 : 0.15))
        }
        .buttonStyle(.plain)
    }
}

struct PeriodArrowButton: View {
    let systemImage: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.appPrimary.opacity(isEnabled ? 1 : 0.4))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .glassSurface(in: Circle(), isInteractive: isEnabled, fallback: Color.clear)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview("Design components") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            PeriodArrowButton(systemImage: "chevron.left", isEnabled: true, action: {})
            PeriodArrowButton(systemImage: "chevron.right", isEnabled: false, action: {})
        }

        InsetDivider()

        HStack(spacing: 16) {
            RoundIconButton(systemImage: "chevron.down", action: {})
            RoundIconButton(systemImage: "trash", color: .appRed, tint: .appRed, action: {})
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .appBackground()
}
