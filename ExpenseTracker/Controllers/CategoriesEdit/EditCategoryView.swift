//
//  EditCategoryView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 28.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

struct EditCategoryView: View {
    @Query(filter: #Predicate<TransactionCategory> { $0.isDirectory })
    private var allDirectories: [TransactionCategory]
    @Query private var allCategories: [TransactionCategory]

    /// Редактируемая категория; `nil`, когда создаётся новая.
    private let category: TransactionCategory?
    @State private var draft: CategoryDraft
    @State private var showDeleteConfirmation = false
    @State private var showCustomIconPicker = false
    @State private var selectedSubcategory: TransactionCategory?

    private var isEdit: Bool { category != nil }
    private var isDirectory: Bool { category?.isDirectory ?? false }
    private var subcategories: [TransactionCategory] {
        category?.allSubcategories(from: allCategories) ?? []
    }

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // MARK: - Constants

    private let availableIcons = [
        "cart",
        "bag.fill.badge.plus",
        "car",
        "house",
        "airplane",
        "creditcard",
        "banknote",
        "briefcase",
        "graduationcap",
        "stethoscope",
        "gamecontroller",
        "book",
        "heart",
        "star",
        "leaf",
        "flame",
        "drop",
        "gift.fill",
        "phone",
        "envelope",
        "camera",
        "display",
        "keyboard",
        "speaker.wave.2",
        "app",
        "soccerball",
        "bicycle",
        "wineglass",
        "takeoutbag.and.cup.and.straw.fill",
        "bus",
        "fork.knife",
        "steeringwheel",
        "pawprint.fill",
        "person.2",
        "tshirt.fill",
        "face.smiling",
        "clock.badge.exclamationmark",
        "cup.and.saucer",
        "figure.dance",
        "dog",
        "dumbbell",
        "powerplug",
        "person.3",
        "fish",
        "carrot",
        "guitars",
        "at",
        "iphone.gen2",
        "lightbulb",
        "person",
        "theatermasks",
        "cross.case",
        "dollarsign.circle",
        "film.fill",
        "music.note",
        "shoeprints.fill",
        "handbag",
        "hammer",
        "figure.strengthtraining.traditional",
        "scissors",
        "figure.skiing.downhill",
        "checkerboard.rectangle",
        "tv",
    ]

    // MARK: - Initializers

    init() {
        self.category = nil
        _draft = State(initialValue: CategoryDraft())
    }

    init(category: TransactionCategory) {
        self.category = category
        _draft = State(initialValue: CategoryDraft(category))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
            }
            .background(.appMain)
            .navigationTitle(isEdit ? L10n.editCategoryTitle : L10n.editCategoryNewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(isEdit ? L10n.save : L10n.editCategoryDefaultName) {
                        save()
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .disabled(!draft.canSave)
                }
            }
        }
        .onAppear {
            draft.dropMissingParent(in: allCategories)
        }
        .sheet(item: $selectedSubcategory) { subcategory in
            EditCategoryView(category: subcategory)
        }
        .sheet(isPresented: $showCustomIconPicker) {
            CustomIconPickerView(selectedIcon: $draft.icon.name)
        }
    }

    // MARK: - Main Content

    private var content: some View {
        VStack(spacing: 24) {
            previewSection
            nameInputSection

            if !isDirectory {
                parentSelectionSection
            }
            if !subcategories.isEmpty {
                subcategoriesSection
            }
            iconSelectionSection
            colorSelectionSection

            if isEdit {
                Spacer(minLength: 40)
                deleteSection
            }
        }
    }

    // MARK: - Sections

    private var previewSection: some View {
        VStack(spacing: 16) {
            // Иконка с оборачиванием в папку для каталогов
            if isDirectory {
                ZStack {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow)
                        .frame(width: 64, height: 64)

                    draft.icon.image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.appMain)
                        .frame(width: 28, height: 28)
                        .offset(y: 4)
                }
            } else {
                draft.icon.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(draft.icon.color)
                    .frame(width: 64, height: 64)
            }

            Text(draft.name.isEmpty ? (isEdit ? L10n.editCategoryDefaultName : L10n.editCategoryDefaultName) : draft.name)
                .font(.appMedium(18))
                .foregroundColor(.white)
        }
        .padding(.vertical, 24)
    }

    private var parentSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.editCategoryParentCategory)
                .font(.appMedium(16))
                .foregroundColor(.white)

            HStack {
                Picker("Выберите папку", selection: $draft.parentUuid) {
                    Text(L10n.editCategoryNoParent).tag(nil as UUID?)

                    ForEach(allDirectories, id: \.id) { directory in
                        Text(directory.name).tag(directory.uuid as UUID?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.white)
                Spacer()
            }
        }
    }

    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.editCategoryName)
                .font(.appMedium(16))
                .foregroundColor(.white)

            TextField(L10n.editCategoryNamePlaceholder, text: $draft.name)
                .padding(10)
                .background(.appMain)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.appSecond, lineWidth: 1) // цвет и толщина бордера
                )
                .font(.appRegular(16))
        }
    }

    private var subcategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.editCategorySubcategories)
                .font(.appMedium(16))
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(subcategories, id: \.id) { sub in
                    Button {
                        selectedSubcategory = sub
                    } label: {
                        VStack(spacing: 4) {
                            sub.categoryIcon.image
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(sub.categoryIcon.color)
                                .frame(width: 32, height: 32)

                            Text(sub.name)
                                .font(.appRegular(12))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.editCategoryIcon)
                    .font(.appMedium(16))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showCustomIconPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text(L10n.editCategoryMoreIcons)
                    }
                    .font(.appRegular(14))
                    .foregroundColor(.yellow)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconButton(icon)
                }
            }
        }
    }

    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.editCategoryColor)
                .font(.appMedium(16))
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(IconColor.allCases, id: \.self) { color in
                    colorButton(color)
                }
            }
        }
    }

    private var deleteSection: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Text(isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory)
                .font(.appMedium(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
        }
        .alert(isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory, isPresented: $showDeleteConfirmation) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.remove, role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text(L10n.editCategoryDeleteConfirmation)
        }
    }

    // MARK: - Buttons

    private func iconButton(_ icon: String) -> some View {
        Button {
            draft.icon.name = icon
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(draft.icon.name == icon ? draft.icon.color : .white.opacity(0.6))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(draft.icon.name == icon ? Color.white.opacity(0.2) : Color.clear)
                )
        }
    }

    private func colorButton(_ color: IconColor) -> some View {
        Button {
            draft.icon.iconColor = color
        } label: {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.color)
                    .frame(height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color.white, lineWidth: draft.icon.iconColor == color ? 3 : 0)
                    )

                Text(color.rawValue.capitalized).font(.appRegular(12)).foregroundColor(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Actions

    private func save() {
        if let category {
            draft.apply(to: category)
        } else {
            modelContext.insert(draft.makeCategory())
        }
        try? modelContext.save()
    }

    private func deleteCategory() {
        guard let category else { return }

        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
}
