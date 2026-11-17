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
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
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
            .animation(.easeInOut(duration: 0.2), value: isNameFocused)
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
                .focused($isNameFocused)
                .padding(10)
                .background(.appMain.opacity(0.5))
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
                        .glassSurface(
                            in: RoundedRectangle(cornerRadius: 8),
                            isInteractive: true,
                            fallback: .appWhite.opacity(0.1)
                        )
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

                    ForEach(IconColor.primary, id: \.self) { color in
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
                .glassSurface(
                    in: RoundedRectangle(cornerRadius: LiquidGlass.isAvailable ? 26 : 12, style: .continuous),
                    tint: .appRed,
                    isInteractive: true,
                    fallback: .appRed
                )
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
