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
        "car", "car.fill", "bus", "bus.fill", "airplane", "airplane.departure", "airplane.arrival",
        "bicycle", "scooter", "train.side.front.car", "tram", "ferry", "sailboat",
        "truck.box", "truck.box.fill", "suv.side", "suv.side.fill",

        // Shopping & Money
        "cart", "cart.fill", "bag", "bag.fill", "basket", "basket.fill", "creditcard", "creditcard.fill",
        "banknote", "banknote.fill", "dollarsign.circle", "dollarsign.circle.fill", "eurosign.circle",
        "yensign.circle", "sterlingsign.circle", "bitcoinsign.circle", "bag.badge.plus", "bag.badge.minus",

        // Home & Living
        "house", "house.fill", "building", "building.fill", "bed.double", "bed.double.fill",
        "sofa", "chair", "chair.lounge", "lamp.table", "lamp.table.fill", "lightbulb", "lightbulb.fill",
        "fan", "air.conditioner.horizontal", "washer", "dryer", "dishwasher", "microwave",

        // Food & Drink
        "fork.knife", "fork.knife.circle", "cup.and.saucer", "cup.and.saucer.fill", "wineglass",
        "wineglass.fill", "mug", "mug.fill", "takeoutbag.and.cup.and.straw", "takeoutbag.and.cup.and.straw.fill",
        "carrot", "carrot.fill", "apple.logo", "leaf", "leaf.fill", "birthday.cake", "birthday.cake.fill",

        // Health & Fitness
        "heart", "heart.fill", "stethoscope", "cross.case", "cross.case.fill",
        "pills", "pills.fill", "syringe", "syringe.fill", "lungs", "lungs.fill", "brain.head.profile",
        "dumbbell", "dumbbell.fill", "figure.walk", "figure.run", "figure.strengthtraining.traditional",
        "figure.yoga", "figure.dance", "figure.skiing.downhill", "bicycle", "soccerball",

        // Technology
        "iphone", "iphone.gen2", "iphone.gen3", "ipad", "ipad.gen2", "macbook", "applewatch",
        "airpods", "airpods.gen3", "keyboard", "keyboard.fill", "display",
        "display.2", "printer", "printer.fill", "camera", "camera.fill", "video", "video.fill",
        "speaker", "speaker.fill", "speaker.wave.2", "speaker.wave.2.fill", "headphones", "headphones.circle",

        // Education & Work
        "book", "book.fill", "books.vertical", "books.vertical.fill", "graduationcap", "graduationcap.fill",
        "pencil", "pencil.circle", "pencil.and.outline", "note.text", "doc", "doc.fill", "folder",
        "folder.fill", "briefcase", "briefcase.fill", "building.2", "building.2.fill", "person.badge.plus",

        // Entertainment
        "gamecontroller", "gamecontroller.fill", "dice", "dice.fill", "puzzlepiece", "puzzlepiece.fill",
        "tv", "tv.fill", "film", "film.fill", "music.note", "music.note.list", "guitars", "guitars.fill",
        "theatermasks", "theatermasks.fill", "ticket", "ticket.fill",

        // Nature & Weather
        "sun.max", "sun.max.fill", "moon", "moon.fill", "cloud", "cloud.fill", "cloud.rain",
        "cloud.snow", "bolt", "bolt.fill", "tornado", "hurricane", "thermometer", "drop", "drop.fill",
        "flame", "flame.fill", "snowflake", "leaf.arrow.circlepath", "tree", "tree.fill",

        // People & Social
        "person", "person.fill", "person.2", "person.2.fill", "person.3", "person.3.fill",
        "face.smiling", "face.dashed", "hands.clap", "hands.sparkles", "figure.2.arms.open",
        "message", "message.fill", "phone", "phone.fill", "envelope", "envelope.fill",

        // Transportation & Travel
        "suitcase", "suitcase.fill", "backpack", "backpack.fill", "tent", "tent.fill", "map",
        "map.fill", "location", "location.fill", "compass.drawing", "globe", "globe.americas",

        // Sports & Activities
        "sportscourt", "sportscourt.fill", "basketball", "basketball.fill", "football", "football.fill",
        "tennis.racket", "hockey.puck", "skateboard", "skateboard.fill", "surfboard", "surfboard.fill",
        "figure.surfing", "figure.snowboarding", "figure.skating",

        // Tools & Utilities
        "hammer", "hammer.fill", "wrench", "wrench.fill", "screwdriver", "screwdriver.fill",
        "scissors", "scissors.badge.ellipsis", "paintbrush", "paintbrush.fill", "ruler", "ruler.fill",
        "level", "level.fill", "flashlight.on.fill", "flashlight.off.fill", "key", "key.fill",

        // Fashion & Style
        "tshirt", "tshirt.fill", "handbag", "handbag.fill", "eyeglasses", "sunglasses", "crown",
        "crown.fill", "shoeprints.fill", "shoe", "shoe.2",

        // Symbols & Icons
        "star", "star.fill", "heart.circle", "heart.circle.fill", "checkmark.circle", "checkmark.circle.fill",
        "xmark.circle", "xmark.circle.fill", "plus.circle", "plus.circle.fill", "minus.circle",
        "exclamationmark.triangle", "questionmark.circle", "info.circle", "gear", "gear.circle",

        // Animals & Pets
        "dog", "dog.fill", "cat", "cat.fill", "bird", "bird.fill",
        "fish", "fish.fill", "tortoise", "tortoise.fill", "ladybug", "ladybug.fill", "ant",
        "ant.fill", "pawprint", "pawprint.fill", "hare", "hare.fill",

        // Business & Finance
        "chart.line.uptrend.xyaxis", "chart.bar", "chart.bar.fill", "chart.pie", "chart.pie.fill",
        "percent", "plusminus", "divide", "multiply", "equal",
        "scale.3d", "banknote.fill", "building.columns", "building.columns.fill",
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar
                iconGrid
            }
            .background(.appMain)
            .navigationTitle("Выбор иконки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(.white)
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
                .foregroundColor(.white.opacity(0.6))

            TextField("Поиск иконок...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
                .onChange(of: searchText) { _, newValue in
                    filterIcons(searchText: newValue)
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    filteredIcons = allSFSymbols
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
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
                    .foregroundColor(selectedIcon == icon ? .yellow : .white)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedIcon == icon ? Color.yellow : Color.clear, lineWidth: 2)
                    )

                Text(icon)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
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
