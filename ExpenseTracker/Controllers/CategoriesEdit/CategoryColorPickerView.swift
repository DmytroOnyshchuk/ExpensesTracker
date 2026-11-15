//
//  CategoryColorPickerView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CategoryColorPickerView: View {
    @Binding var icon: CategoryIcon
    @Environment(\.dismiss) private var dismiss

    @State private var hexInput: String
    @State private var hue: Double = .zero
    @State private var saturation: Double = .zero
    @State private var brightness: Double = 1

    private let palette = [
        "#FF0000", "#E57373", "#D32F2F", "#F44336", "#5D4037", "#E64A19",
        "#FF8A65", "#FF5722", "#A1887F", "#795548", "#804000", "#F57C00",
        "#FFB74D", "#FF9800", "#FFA000", "#FFA200", "#FBC02D", "#FFC107",
        "#FFD54F", "#FFF176", "#FFEB3B", "#FFFF00", "#AFB42B", "#CDDC39",
        "#DCE775", "#8BC34A", "#AED581", "#689F38", "#00FF00", "#4CAF50",
        "#81C784", "#388E3C", "#00796B", "#4DB6AC", "#009688", "#00FFFF",
        "#0097A7", "#00BCD4", "#4DD0E1", "#4FC3F7", "#03A9F4", "#455A64",
        "#607D8B", "#90A4AE", "#0288D1", "#2196F3", "#64B5F6", "#1976D2",
        "#7986CB", "#3F51B5", "#303F9F", "#0000FF", "#4000FF", "#512DA8",
        "#673AB7", "#9575CD", "#8000FF", "#7B1FA2", "#BA68C8", "#9C27B0",
        "#FF00FF", "#C2185B", "#E91E63", "#F06292", "#FFFFFF", "#E0E0E0",
        "#BDBDBD", "#9E9E9E", "#808080", "#616161", "#424242", "#000000",
    ]

    private var selectedHex: String? {
        CategoryIcon.normalizedHex(hexInput)
    }

    private var previewColor: Color {
        selectedHex.map { Color(hex: $0) } ?? icon.color
    }

    private var wheelHex: String {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
            .getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(
            format: "%02X%02X%02X",
            Int((red * 255).rounded()),
            Int((green * 255).rounded()),
            Int((blue * 255).rounded())
        )
    }

    init(icon: Binding<CategoryIcon>) {
        _icon = icon
        _hexInput = State(initialValue: String(icon.wrappedValue.customColorHex?.dropFirst() ?? ""))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    preview
                    colorWheel
                    brightnessSlider
                    hexField
                    paletteGrid
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .appBackground()
            .onAppear {
                syncWheel(with: hexInput)
            }
            .onChange(of: hexInput) { _, newValue in
                syncWheel(with: newValue)
            }
            .navigationTitle(L10n.editCategoryColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.appWhite)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) {
                        icon.customColorHex = selectedHex
                        dismiss()
                    }
                    .foregroundColor(.appWhite)
                    .disabled(selectedHex == nil)
                }
            }
        }
    }

    private var preview: some View {
        icon.image
            .resizable()
            .scaledToFit()
            .foregroundColor(previewColor)
            .frame(width: 64, height: 64)
            .padding(.vertical, 8)
    }

    private var colorWheel: some View {
        GeometryReader { geometry in
            let borderWidth = 0.5
            let borderGap = 0.5
            let outerRadius = min(geometry.size.width, geometry.size.height) / 2
            let radius = outerRadius - borderWidth - borderGap
            let angle = hue * 2 * .pi

            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: stride(from: 0.0, through: 1.0, by: 1.0 / 12).map {
                                Color(hue: $0, saturation: 1, brightness: 1)
                            },
                            center: .center
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, .white.opacity(0)],
                            center: .center,
                            startRadius: .zero,
                            endRadius: radius
                        )
                    )
                    .frame(width: radius * 2, height: radius * 2)

                Circle()
                    .fill(Color.black.opacity(1 - brightness))
                    .frame(width: radius * 2, height: radius * 2)

                Circle()
                    .strokeBorder(Color.appWhite.opacity(0.9), lineWidth: borderWidth)

                if selectedHex != nil {
                    Circle()
                        .fill(previewColor)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .offset(
                            x: cos(angle) * saturation * radius,
                            y: sin(angle) * saturation * radius
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(width: outerRadius * 2, height: outerRadius * 2)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: .zero)
                    .onChanged { value in
                        pickColor(
                            at: value.location,
                            center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                            radius: radius
                        )
                    }
            )
        }
        .frame(width: 240, height: 240)
    }

    private var brightnessSlider: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.min")
            Slider(
                value: Binding(
                    get: { brightness },
                    set: { newValue in
                        brightness = newValue
                        hexInput = wheelHex
                    }
                ),
                in: 0 ... 1
            )
            .tint(.appWhite.opacity(0.9))
            Image(systemName: "sun.max.fill")
        }
        .foregroundColor(.appWhite.opacity(0.6))
    }

    private var hexField: some View {
        HStack(spacing: 12) {
            Text("HEX")
                .font(.appMedium(16))
                .foregroundColor(.appWhite)

            HStack(spacing: 2) {
                Text("#")
                    .foregroundColor(.appGray)

                TextField("FFD000", text: $hexInput)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .foregroundColor(.appWhite)
                    .onChange(of: hexInput) { _, newValue in
                        let filtered = String(newValue.uppercased().filter { $0.isHexDigit && $0.isASCII }.prefix(6))
                        if filtered != newValue {
                            hexInput = filtered
                        }
                    }
            }
            .font(.appRegular(16))
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.appSecond, lineWidth: 1)
            )

            ColorSwatch(color: previewColor)
                .frame(width: 56)
        }
    }

    private var paletteGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
            ForEach(palette, id: \.self) { hex in
                Button {
                    hexInput = String(hex.dropFirst())
                } label: {
                    ColorSwatch(color: Color(hex: hex), isSelected: selectedHex == hex)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

extension CategoryColorPickerView {
    private func pickColor(at location: CGPoint, center: CGPoint, radius: CGFloat) {
        guard radius > .zero else { return }

        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        let turn = atan2(deltaY, deltaX) / (2 * .pi)

        hue = turn < .zero ? turn + 1 : turn
        saturation = min(hypot(deltaX, deltaY) / radius, 1)
        hexInput = wheelHex
    }

    private func syncWheel(with input: String) {
        guard let hex = CategoryIcon.normalizedHex(input), hex != "#" + wheelHex else { return }

        var newHue: CGFloat = .zero
        var newSaturation: CGFloat = .zero
        var newBrightness: CGFloat = .zero
        UIColor(Color(hex: hex)).getHue(&newHue, saturation: &newSaturation, brightness: &newBrightness, alpha: nil)

        hue = newHue
        saturation = min(max(newSaturation, 0), 1)
        brightness = min(max(newBrightness, 0), 1)
    }
}

#Preview {
    @Previewable @State var icon = CategoryIcon(name: "cart", iconColor: .green)

    CategoryColorPickerView(icon: $icon)
}
