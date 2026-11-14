import SwiftUI

enum LiquidGlass {
    static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
}

struct GlassContainer<Content: View>: View {
    var spacing: CGFloat?
    @ViewBuilder let content: Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func glassSurface(
        in shape: some Shape,
        tint: Color? = nil,
        isInteractive: Bool = false,
        fallback: some ShapeStyle
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(tint).interactive(isInteractive), in: shape)
        } else {
            background(fallback, in: shape)
        }
    }

    @ViewBuilder
    func legacyShadow(color: Color, radius: CGFloat, y: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            shadow(color: color, radius: radius, y: y)
        }
    }

    @ViewBuilder
    func legacyPresentationBackground(_ style: some ShapeStyle) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            presentationBackground(style)
        }
    }
}
