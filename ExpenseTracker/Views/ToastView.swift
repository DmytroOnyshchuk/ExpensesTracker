//
//  ToastView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

enum ToastIcon {
    case success
    case error
    case warning
    case info

    var systemImage: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .error: "xmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: .appDarkGreen
        case .error: .appRed
        case .warning: .appYellow
        case .info: .appPrimary
        }
    }
}

struct ToastView: View {
    let message: String
    var icon: ToastIcon?

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(icon.color)
            }

            Text(message)
                .font(.appRegular(16))
                .foregroundColor(LiquidGlass.isAvailable ? .appWhite : .appMain)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassSurface(in: Capsule(), fallback: .appWhite)
        .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var message: String?
    let icon: ToastIcon?
    let duration: Duration

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    ToastView(message: message, icon: icon)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onTapGesture {
                            self.message = nil
                        }
                        .task {
                            try? await Task.sleep(for: duration)
                            guard !Task.isCancelled else { return }
                            self.message = nil
                        }
                }
            }
            .animation(.appSpring, value: message)
    }
}

extension View {
    func toast(_ message: Binding<String?>, icon: ToastIcon? = nil, duration: Duration = .seconds(2)) -> some View {
        modifier(ToastModifier(message: message, icon: icon, duration: duration))
    }
}

#Preview {
    @Previewable @State var message: String? = "Enter the amount first"

    Color.appMain
        .ignoresSafeArea()
        .toast($message)
}
