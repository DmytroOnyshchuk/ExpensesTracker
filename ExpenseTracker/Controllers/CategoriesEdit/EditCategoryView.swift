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

    /// The category being edited; `nil` when a new one is created.
    private let category: TransactionCategory?
    @State private var draft: CategoryDraft
    @State private var showDeleteConfirmation = false
    @State private var showCustomIconPicker = false
    @State private var showColorPicker = false
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
        "cart.fill",
        "fork.knife",
        "cup.and.saucer.fill",
        "wineglass.fill",
        "takeoutbag.and.cup.and.straw.fill",
        "handbag.fill",
        "house.fill",
        "lightbulb.fill",
        "drop.fill",
        "flame.fill",
        "hammer.fill",
        "phone.fill",
        "car.fill",
        "bus.fill",
        "bicycle",
        "airplane",
        "tshirt.fill",
        "scissors",
        "cross.case.fill",
        "stethoscope",
        "dumbbell.fill",
        "pawprint.fill",
        "person.2.fill",
        "heart.fill",
        "gamecontroller.fill",
        "film.fill",
        "theatermasks.fill",
        "music.note",
        "tv.fill",
        "book.fill",
        "graduationcap.fill",
        "gift.fill",
        "briefcase.fill",
        "creditcard.fill",
        "banknote.fill",
        "star.fill",
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
                    .foregroundColor(.appWhite)
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(isEdit ? L10n.save : L10n.editCategoryDefaultName) {
                        save()
                        dismiss()
                    }
                    .foregroundColor(.appWhite)
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
        .sheet(isPresented: $showColorPicker) {
            CategoryColorPickerView(icon: $draft.icon)
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
            colorSelectionSection
            iconSelectionSection

            if isEdit {
                Spacer(minLength: 40)
                deleteSection
            }
        }
    }

    // MARK: - Sections

    private var previewSection: some View {
        VStack(spacing: 16) {
            // Icon wrapped in a folder for directories
            if isDirectory {
                ZStack {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.appYellow)
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
                .foregroundColor(.appWhite)
        }
        .padding(.vertical, 24)
    }

    private var parentSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.editCategoryParentCategory)
                .font(.appMedium(16))
                .foregroundColor(.appWhite)

            HStack {
                Picker("Choose folder", selection: $draft.parentUuid) {
                    Text(L10n.editCategoryNoParent).tag(nil as UUID?)

                    ForEach(allDirectories, id: \.id) { directory in
                        Text(directory.name.localized).tag(directory.uuid as UUID?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.appWhite)
                Spacer()
            }
        }
    }

    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.editCategoryName)
                .font(.appMedium(16))
                .foregroundColor(.appWhite)

            TextField(L10n.editCategoryNamePlaceholder, text: $draft.name)
                .padding(10)
                .background(.appMain)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.appSecond, lineWidth: 1) // border color and width
                )
                .font(.appRegular(16))
        }
    }

    private var subcategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.editCategorySubcategories)
                .font(.appMedium(16))
                .foregroundColor(.appWhite)

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

                            Text(sub.name.localized)
                                .font(.appRegular(12))
                                .foregroundColor(.appWhite)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .padding(8)
                        .background(.appWhite.opacity(0.1))
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
                    .foregroundColor(.appWhite)

                Spacer()

                Button {
                    showCustomIconPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text(L10n.editCategoryMoreIcons)
                    }
                    .font(.appRegular(14))
                    .foregroundColor(.appYellow)
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
            HStack {
                Text(L10n.editCategoryColor)
                    .font(.appMedium(16))
                    .foregroundColor(.appWhite)

                Spacer()

                Button {
                    showColorPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text(L10n.editCategoryMoreIcons)
                    }
                    .font(.appRegular(14))
                    .foregroundColor(.appYellow)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if draft.icon.customColorHex != nil {
                        Button {
                            showColorPicker = true
                        } label: {
                            colorCell(draft.icon.color, isSelected: true)
                        }
                    }

                    ForEach(IconColor.allCases, id: \.self) { color in
                        colorButton(color)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }

    private var deleteSection: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            Text(isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory)
                .font(.appMedium(16))
                .foregroundColor(.appWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.appRed)
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
                .foregroundColor(draft.icon.name == icon ? draft.icon.color : .appWhite.opacity(0.6))
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(draft.icon.name == icon ? Color.appWhite.opacity(0.2) : Color.clear)
                )
        }
    }

    private func colorButton(_ color: IconColor) -> some View {
        Button {
            draft.icon.select(color)
        } label: {
            colorCell(color.color, isSelected: draft.icon.customColorHex == nil && draft.icon.iconColor == color)
        }
    }

    private func colorCell(_ color: Color, isSelected: Bool) -> some View {
        ColorSwatch(color: color, isSelected: isSelected)
            .frame(width: 56)
    }

    // MARK: - Actions

    private func save() {
        if let category {
            draft.apply(to: category)
        } else {
            let newCategory = draft.makeCategory()
            newCategory.sortIndex = allCategories.nextSortIndex
            modelContext.insert(newCategory)
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

#Preview("New category") {
    EditCategoryView()
        .modelContainer(makePreviewModelContainer())
}

#Preview("Edit category") {
    let category = TransactionCategory(name: "Groceries", categoryIcon: CategoryIcon(name: "cart.fill", iconColor: .green))

    EditCategoryView(category: category)
        .modelContainer(makePreviewModelContainer())
}
