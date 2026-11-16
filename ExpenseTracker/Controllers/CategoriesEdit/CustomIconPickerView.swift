//
//  CustomIconPickerView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 31.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CustomIconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var filteredIcons: [String] = []

    private let allSFSymbols = [
        // Everyday city expenses — ordered by likely use
        "cart.fill", "basket.fill", "carrot.fill", "takeoutbag.and.cup.and.straw.fill", "cup.and.saucer.fill",
        "fork.knife.circle.fill", "mug.fill", "wineglass.fill", "fuelpump.fill", "car.fill", "tram.fill",
        "bus.fill", "train.side.front.car", "parkingsign.circle.fill", "bolt.car.fill", "bicycle", "scooter",
        "steeringwheel", "house.fill", "building.2.fill", "key.fill", "sofa.fill", "washer.fill", "dryer.fill",
        "dishwasher.fill", "microwave.fill", "wifi", "antenna.radiowaves.left.and.right", "powerplug.fill",
        "bolt.fill", "trash.fill", "bag.fill", "shippingbox.fill", "creditcard.fill", "dollarsign.circle.fill",
        "percent", "shield.fill", "stethoscope", "pills.fill", "syringe.fill", "figure.run", "figure.walk",
        "ticket.fill", "film.fill", "play.rectangle.fill", "music.note.list", "iphone.gen2", "laptopcomputer",
        "bed.double.fill", "suitcase.fill", "airplane.departure", "airplane.arrival", "building.columns.fill",
        "doc.text.fill", "books.vertical.fill", "backpack.fill", "stroller.fill", "teddybear.fill", "birthday.cake.fill",
        "cat.fill", "dog.fill", "heart.circle.fill", "leaf.fill", "globe", "map.fill", "camera.fill",

        // Transportation & travel
        "ferry.fill", "sailboat.fill", "truck.box.fill", "suv.side.fill", "tent.fill", "location.fill",
        "compass.drawing", "globe.americas.fill",

        // Shopping, money & work
        "bag.badge.plus", "bag.badge.minus", "eurosign.circle.fill", "yensign.circle.fill", "sterlingsign.circle.fill",
        "bitcoinsign.circle.fill", "arrow.left.arrow.right", "chart.line.uptrend.xyaxis", "chart.bar.fill", "chart.pie.fill",
        "building.fill", "envelope.fill", "person.fill", "person.3.fill", "person.badge.plus.fill", "at",

        // Home, food & personal care
        "chair.fill", "chair.lounge.fill", "lamp.table.fill", "fan.fill", "air.conditioner.horizontal.fill",
        "apple.logo", "eyeglasses", "comb.fill", "sunglasses.fill", "shoe.fill", "shoe.2.fill", "shoeprints.fill",

        // Health, family & activities
        "lungs.fill", "brain.head.profile.fill", "figure.strengthtraining.traditional", "figure.yoga", "figure.dance",
        "figure.2.arms.open", "face.smiling.fill", "face.dashed.fill", "hands.clap.fill", "hands.sparkles.fill",
        "fish.fill", "soccerball", "sportscourt.fill", "basketball.fill", "football.fill", "tennis.racket",
        "hockey.puck.fill", "skateboard.fill", "surfboard.fill", "figure.surfing", "figure.snowboarding",
        "figure.skating", "figure.skiing.downhill", "guitars.fill", "dice.fill", "puzzlepiece.fill", "popcorn.fill",

        // Technology, education & tools
        "iphone", "iphone.gen3", "ipad", "ipad.gen2", "macbook", "applewatch", "airpods", "airpods.gen3",
        "display", "display.2", "keyboard.fill", "printer.fill", "video.fill", "speaker.fill", "speaker.wave.2.fill",
        "headphones", "headphones.circle.fill", "app.fill", "pencil", "pencil.circle.fill", "pencil.and.outline",
        "note.text", "doc.fill", "folder.fill", "wrench.and.screwdriver.fill", "wrench.fill", "screwdriver.fill",
        "scissors.badge.ellipsis", "paintbrush.fill", "ruler.fill", "level.fill", "flashlight.on.fill", "flashlight.off.fill",

        // Nature, weather & general symbols
        "sun.max.fill", "moon.fill", "cloud.fill", "cloud.rain.fill", "cloud.snow.fill", "tornado", "hurricane",
        "thermometer", "snowflake", "leaf.arrow.circlepath", "tree.fill", "bird.fill", "tortoise.fill", "ladybug.fill",
        "ant.fill", "hare.fill", "crown.fill", "clock.badge.exclamationmark.fill", "message.fill", "questionmark.circle.fill",
        "checkmark.circle.fill", "xmark.circle.fill", "plus.circle.fill", "minus.circle.fill", "exclamationmark.triangle.fill",
        "info.circle.fill", "gear", "gear.circle.fill", "checkerboard.rectangle", "plusminus", "divide", "multiply", "equal", "scale.3d",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                iconGrid
            }
            .appBackground()
            .navigationTitle("Choose icon")
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
                        dismiss()
                    }
                    .foregroundColor(.appWhite)
                }
            }
        }
        .onAppear {
            filteredIcons = allSFSymbols
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appWhite.opacity(0.6))

            TextField("Search icons...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.appWhite)
                .onChange(of: searchText) { _, newValue in
                    filterIcons(searchText: newValue)
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    filteredIcons = allSFSymbols
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appWhite.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassSurface(
            in: RoundedRectangle(cornerRadius: LiquidGlass.isAvailable ? 22 : 10, style: .continuous),
            fallback: .appWhite.opacity(0.1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Icon Grid

    private var iconGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(filteredIcons, id: \.self) { icon in
                    iconButton(icon)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Icon Button

    private func iconButton(_ icon: String) -> some View {
        Button {
            selectedIcon = icon
            dismiss()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 34))
                .foregroundColor(selectedIcon == icon ? .appYellow : .appWhite)
                .frame(width: 68, height: 68)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedIcon == icon ? Color.appYellow : Color.clear, lineWidth: 2)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Filter Icons

    private func filterIcons(searchText: String) {
        if searchText.isEmpty {
            filteredIcons = allSFSymbols
        } else {
            filteredIcons = allSFSymbols.filter { icon in
                icon.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedIcon = "cart.fill"

    CustomIconPickerView(selectedIcon: $selectedIcon)
}
