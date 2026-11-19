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
    @Query(filter: TransactionCategory.directories) private var storedDirectories: [TransactionCategory]
    @Query(filter: TransactionCategory.notDeleted) private var allCategories: [TransactionCategory]

    private var allDirectories: [TransactionCategory] { storedDirectories.of(draft.operationType) }

    private let category: TransactionCategory?
    @State private var draft: CategoryDraft
    @State private var showDeleteConfirmation = false
    @State private var showCustomIconPicker = false
    @State private var showColorPicker = false
    @State private var selectedSubcategory: TransactionCategory?
    @FocusState private var isNameFocused: Bool

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
        "handbag.fill",
        "house.fill",
        "lightbulb.fill",
        "drop.fill",
        "flame.fill",
        "hammer.fill",
        "phone.fill",
        "car.side.fill",
        "bus.fill",
        "bicycle",
        "airplane",
        "tshirt.fill",
        "scissors",
        "cross.fill",
        "dumbbell.fill",
        "pawprint.fill",
        "person.2.fill",
        "heart.fill",
        "gamecontroller.fill",
        "theatermasks.fill",
        "music.note",
        "tv.fill",
        "book.fill",
        "graduationcap.fill",
        "gift.fill",
        "briefcase.fill",
        "banknote.fill",
        "star.fill",
    ]

    // MARK: - Initializers

    init(operationType: OperationType = .outcome) {
        self.category = nil
        _draft = State(initialValue: CategoryDraft(operationType: operationType))
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
                    .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if isNameFocused {
                    KeyboardDoneButton {
                        isNameFocused = false
                    }
                    .transition(.opacity)
                }
            }
            .animation(.appStandard, value: isNameFocused)
            .appBackground()
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
                    Button(isEdit ? L10n.save : L10n.editCategoryCreate) {
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
        .undoToast(isEnabled: isDirectory)
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
                deleteSection
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Sections

    private var previewSection: some View {
        VStack(spacing: 12) {
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
        .padding(.vertical, 8)
    }

    private var parentSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionHeader(title: L10n.editCategoryParentCategory)

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
            .padding(.horizontal, 4)
            .frame(height: 48)
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        }
    }

    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionHeader(title: L10n.editCategoryName)

            TextField(L10n.editCategoryNamePlaceholder, text: $draft.name)
                .focused($isNameFocused)
                .font(.appRegular(16))
                .foregroundColor(.appWhite)
                .tint(.appPrimary)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
        }
    }

    private var subcategoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionHeader(title: L10n.editCategorySubcategories)

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
                        .glassSurface(in: RoundedRectangle(cornerRadius: 12, style: .continuous), isInteractive: true, fallback: .appLabel.opacity(0.1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MenuSectionHeader(title: L10n.editCategoryIcon)

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
                    .padding(.trailing, 16)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MenuSectionHeader(title: L10n.editCategoryColor)

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
                    .padding(.trailing, 16)
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

                    ForEach(IconColor.primary, id: \.self) { color in
                        colorButton(color)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }

    private var deleteSection: some View {
        RoundIconButton(systemImage: "trash", color: .appRed, tint: .appRed) {
            showDeleteConfirmation = true
        }
        .accessibilityLabel(isDirectory ? L10n.editCategoryDeleteFolder : L10n.editCategoryDeleteCategory)
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
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(draft.icon.name == icon ? Color.appWhite.opacity(0.25) : Color.clear)
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

        modelContext.deleteWithUndo(category)
        dismiss()
    }
}

extension EditCategoryView: Equatable {
    nonisolated static func == (lhs: EditCategoryView, rhs: EditCategoryView) -> Bool { lhs.category?.persistentModelID == rhs.category?.persistentModelID }
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
