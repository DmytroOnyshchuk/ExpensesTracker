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
        // Transportation
        "car.fill", "bus.fill", "airplane", "airplane.departure", "airplane.arrival", "bicycle", "scooter",
        "train.side.front.car", "tram.fill", "ferry.fill", "sailboat.fill", "truck.box.fill", "suv.side.fill",

        // Shopping & Money
        "cart.fill", "bag.fill", "basket.fill", "creditcard.fill", "banknote.fill", "dollarsign.circle.fill",
        "eurosign.circle.fill", "yensign.circle.fill", "sterlingsign.circle.fill", "bitcoinsign.circle.fill",
        "bag.badge.plus", "bag.badge.minus",

        // Home & Living
        "house.fill", "building.fill", "bed.double.fill", "sofa.fill", "chair.fill", "chair.lounge.fill",
        "lamp.table.fill", "lightbulb.fill", "fan.fill", "air.conditioner.horizontal.fill", "washer.fill",
        "dryer.fill", "dishwasher.fill", "microwave.fill",

        // Food & Drink
        "fork.knife", "fork.knife.circle.fill", "cup.and.saucer.fill", "wineglass.fill", "mug.fill",
        "takeoutbag.and.cup.and.straw.fill", "carrot.fill", "apple.logo", "leaf.fill", "birthday.cake.fill",

        // Health & Fitness
        "heart.fill", "stethoscope", "cross.case.fill", "pills.fill", "syringe.fill", "lungs.fill",
        "brain.head.profile.fill", "dumbbell.fill", "figure.walk", "figure.run",
        "figure.strengthtraining.traditional", "figure.yoga", "figure.dance", "figure.skiing.downhill",
        "soccerball",

        // Technology
        "iphone", "iphone.gen2", "iphone.gen3", "ipad", "ipad.gen2", "macbook", "applewatch", "airpods",
        "airpods.gen3", "keyboard.fill", "display", "display.2", "printer.fill", "camera.fill", "video.fill",
        "speaker.fill", "speaker.wave.2.fill", "headphones", "headphones.circle.fill",

        // Education & Work
        "book.fill", "books.vertical.fill", "graduationcap.fill", "pencil", "pencil.circle.fill",
        "pencil.and.outline", "note.text", "doc.fill", "folder.fill", "briefcase.fill", "building.2.fill",
        "person.badge.plus.fill",

        // Entertainment
        "gamecontroller.fill", "dice.fill", "puzzlepiece.fill", "tv.fill", "film.fill", "music.note",
        "music.note.list", "guitars.fill", "theatermasks.fill", "ticket.fill",

        // Nature & Weather
        "sun.max.fill", "moon.fill", "cloud.fill", "cloud.rain.fill", "cloud.snow.fill", "bolt.fill", "tornado",
        "hurricane", "thermometer", "drop.fill", "flame.fill", "snowflake", "leaf.arrow.circlepath",
        "tree.fill",

        // People & Social
        "person.fill", "person.2.fill", "person.3.fill", "face.smiling.fill", "face.dashed.fill",
        "hands.clap.fill", "hands.sparkles.fill", "figure.2.arms.open", "message.fill", "phone.fill",
        "envelope.fill",

        // Transportation & Travel
        "suitcase.fill", "backpack.fill", "tent.fill", "map.fill", "location.fill", "compass.drawing", "globe",
        "globe.americas.fill",

        // Sports & Activities
        "sportscourt.fill", "basketball.fill", "football.fill", "tennis.racket", "hockey.puck.fill",
        "skateboard.fill", "surfboard.fill", "figure.surfing", "figure.snowboarding", "figure.skating",

        // Tools & Utilities
        "hammer.fill", "wrench.fill", "screwdriver.fill", "scissors", "scissors.badge.ellipsis",
        "paintbrush.fill", "ruler.fill", "level.fill", "flashlight.on.fill", "flashlight.off.fill", "key.fill",

        // Fashion & Style
        "tshirt.fill", "handbag.fill", "eyeglasses", "sunglasses.fill", "crown.fill", "shoeprints.fill",
        "shoe.fill", "shoe.2.fill",

        // Symbols & Icons
        "star.fill", "heart.circle.fill", "checkmark.circle.fill", "xmark.circle.fill", "plus.circle.fill",
        "minus.circle.fill", "exclamationmark.triangle.fill", "questionmark.circle.fill", "info.circle.fill",
        "gear", "gear.circle.fill",

        // Animals & Pets
        "dog.fill", "cat.fill", "bird.fill", "fish.fill", "tortoise.fill", "ladybug.fill", "ant.fill",
        "pawprint.fill", "hare.fill",

        // Business & Finance
        "chart.line.uptrend.xyaxis", "chart.bar.fill", "chart.pie.fill", "percent", "plusminus", "divide",
        "multiply", "equal", "scale.3d", "building.columns.fill",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                iconGrid
            }
            .background(.appMain)
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
        .background(.appWhite.opacity(0.1))
        .cornerRadius(10)
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
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedIcon == icon ? .appYellow : .appWhite)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedIcon == icon ? Color.appYellow : Color.clear, lineWidth: 2)
                    )

                Text(icon)
                    .font(.caption2)
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 24)
            }
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
