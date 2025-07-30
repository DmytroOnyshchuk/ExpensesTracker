//
//  AddCategoryView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 28.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftData

struct EditCategoryView: View {
    
    @Bindable var category: TransactionCategory
    var isEdit: Bool = false
    @State private var name: String = ""
    @State private var showDeleteConfirmation = false
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Constants
    private let availableIcons = [
        "cart", "bag", "car", "house", "airplane", "gamecontroller",
        "book", "heart", "star", "moon", "sun.max", "cloud",
        "leaf", "flame", "drop", "bolt", "gift", "music.note",
        "phone", "envelope", "camera", "photo", "video", "tv",
        "display", "keyboard", "mouse", "headphones", "speaker.wave.2",
        "creditcard", "banknote", "briefcase", "graduationcap", "stethoscope"
    ]
    
    // MARK: - Initializers
    init(isEdit: Bool = false) {
        self.isEdit = isEdit
        self._category = Bindable(wrappedValue: TransactionCategory(name: "Новая категория", categoryIcon: CategoryIcon(name: "cart", iconColor: .yellow)))
    }
    
    init(category: TransactionCategory, isEdit: Bool = true) {
        self.isEdit = isEdit
        self._category = Bindable(wrappedValue: category)
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
            .navigationTitle(isEdit ? "Редактирование" : "Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(isEdit ? "Сохранить" : "Создать") {
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
        }
    }
    
    // MARK: - Main Content
    private var content: some View {
        VStack(spacing: 24) {
            previewSection
            nameInputSection
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
            category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .foregroundColor(category.categoryIcon.color)
                .frame(width: 64, height: 64)
            
            Text(name.isEmpty ? (isEdit ? "Название категории" : "Новая категория") : name)
                .font(.appMedium(18))
                .foregroundColor(.white)
        }
        .padding(.vertical, 24)
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Название")
                .font(.appMedium(16))
                .foregroundColor(.white)
            
            TextField("Введите название категории", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.appRegular(16))
        }
    }
    
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Иконка")
                .font(.appMedium(16))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    iconButton(icon)
                }
            }
        }
    }
    
    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Цвет")
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
            Text("Удалить категорию")
                .font(.appMedium(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
        }
        .alert("Удалить категорию?", isPresented: $showDeleteConfirmation) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text("Это действие нельзя отменить. Все транзакции с этой категорией будут удалены.")
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
        modelContext.insert(category)
        try? modelContext.save()
    }
    
    private func saveChanges() {
        category.name = name
        try? modelContext.save()
    }
    
    private func deleteCategory() {
        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
}
