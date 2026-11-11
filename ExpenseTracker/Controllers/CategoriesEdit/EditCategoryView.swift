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
    @State private var selectedParent: TransactionCategory?

    @Bindable var category: TransactionCategory
    var isEdit: Bool = false
    @State private var name: String = ""
    @State private var showDeleteConfirmation = false
    @State private var showCustomIconPicker = false
    private var subcategories: [TransactionCategory] {
        category.allSubcategories(from: allCategories)
    }

    @State private var selectedSubcategory: TransactionCategory?
    @State private var showSubcategoryEditor = false

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

    init(isEdit: Bool = false) {
        self.isEdit = isEdit
        _category = Bindable(wrappedValue: TransactionCategory(name: L10n.editCategoryDefaultName, categoryIcon: CategoryIcon(name: "cart", iconColor: .yellow)))
    }

    init(category: TransactionCategory, isEdit: Bool = true) {
        self.isEdit = isEdit
        _category = Bindable(wrappedValue: category)
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
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
                        if isEdit {
                            saveChanges()
                        } else {
                            createCategory()
                        }
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            name = category.name
            selectedParent = category.parent(from: allCategories)
        }
        .sheet(item: $selectedSubcategory) { subcategory in
            EditCategoryView(category: subcategory, isEdit: true)
        }
        .sheet(isPresented: $showCustomIconPicker) {
            CustomIconPickerView(selectedIcon: $category.categoryIcon.name)
        }
    }

    // MARK: - Main Content

    private var content: some View {
        VStack(spacing: 24) {
            previewSection
            nameInputSection

            if !category.isDirectory {
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
            if category.isDirectory {
                ZStack {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow)
                        .frame(width: 64, height: 64)

                    category.categoryIcon.image
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.appMain)
                        .frame(width: 28, height: 28)
                        .offset(y: 4)
                }
            } else {
                category.categoryIcon.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(category.categoryIcon.color)
                    .frame(width: 64, height: 64)
            }

            Text(name.isEmpty ? (isEdit ? L10n.editCategoryDefaultName : L10n.editCategoryDefaultName) : name)
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
                Picker("Выберите папку", selection: $selectedParent) {
                    Text(L10n.editCategoryNoParent).tag(nil as TransactionCategory?)

                    ForEach(allDirectories, id: \.id) { directory in
                        Text(directory.name).tag(directory as TransactionCategory?)
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

            TextField(L10n.editCategoryNamePlaceholder, text: $name)
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
                        showSubcategoryEditor = true
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

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
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
            Text(category.isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory)
                .font(.appMedium(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
        }
        .alert(category.isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory, isPresented: $showDeleteConfirmation) {
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
            category.categoryIcon.name = icon
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(category.categoryIcon.name == icon ? category.categoryIcon.color : .white.opacity(0.6))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.categoryIcon.name == icon ? Color.white.opacity(0.2) : Color.clear)
                )
        }
    }

    private func colorButton(_ color: IconColor) -> some View {
        Button {
            category.categoryIcon.iconColor = color
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(color.color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: category.categoryIcon.iconColor == color ? 3 : 0)
                    )

                Text(color.rawValue.capitalized)
                    .font(.appRegular(12))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    // MARK: - Actions

    private func createCategory() {
        category.name = name
        category.parentUuid = selectedParent?.uuid
        modelContext.insert(category)
        try? modelContext.save()
    }

    private func saveChanges() {
        category.name = name
        category.parentUuid = selectedParent?.uuid
        try? modelContext.save()
    }

    private func deleteCategory() {
        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
}
