//
//  CategoryEditView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 29.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI
import SwiftData

//struct CategoryEditView: View {
//    @Bindable var category: TransactionCategory
//    @State private var name: String = ""
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var modelContext
//    
//    @State private var showDeleteConfirmation = false
//    
//    private let availableIcons = [
//        "cart", "bag", "car", "house", "airplane", "gamecontroller",
//        "book", "heart", "star", "moon", "sun.max", "cloud",
//        "leaf", "flame", "drop", "bolt", "gift", "music.note",
//        "phone", "envelope", "camera", "photo", "video", "tv",
//        "display", "keyboard", "mouse", "headphones", "speaker.wave.2",
//        "creditcard", "banknote", "briefcase", "graduationcap", "stethoscope"
//    ]
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                // Превью категории
//                VStack(spacing: 16) {
//                    category.categoryIcon.image
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(category.categoryIcon.color)
//                        .frame(width: 64, height: 64)
//                    
//                    Text(name.isEmpty ? "Название категории" : name)
//                        .font(.appMedium(18))
//                        .foregroundColor(.white)
//                }
//                .padding(.vertical, 24)
//                
//                // Поле ввода названия
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Название")
//                        .font(.appMedium(16))
//                        .foregroundColor(.white)
//                    
//                    TextField("Введите название категории", text: $name)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .font(.appRegular(16))
//                }
//                
//                // Выбор иконки
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Иконка")
//                        .font(.appMedium(16))
//                        .foregroundColor(.white)
//                    
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
//                        ForEach(availableIcons, id: \.self) { icon in
//                            Button {
//                                category.categoryIcon = icon
//                            } label: {
//                                Image(systemName: icon)
//                                    .font(.system(size: 24))
//                                    .foregroundColor(category.categoryIcon == icon ? category.categoryIcon.color : .white.opacity(0.6))
//                                    .frame(width: 40, height: 40)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .fill(category.categoryIcon == icon ? Color.white.opacity(0.2) : Color.clear)
//                                    )
//                            }
//                        }
//                    }
//                }
//                
//                // Выбор цвета
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Цвет")
//                        .font(.appMedium(16))
//                        .foregroundColor(.white)
//                    
//                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
//                        ForEach(IconColor.allCases, id: \.self) { iconColor in
//                            Button {
//                                category.categoryIcon.iconColor = iconColor
//                            } label: {
//                                VStack(spacing: 4) {
//                                    Circle()
//                                        .fill(iconColor.color)
//                                        .frame(width: 32, height: 32)
//                                        .overlay(
//                                            Circle()
//                                                .stroke(Color.white, lineWidth: category.categoryIcon.iconColor == iconColor ? 3 : 0)
//                                        )
//                                    
//                                    Text(iconColor.rawValue.capitalized)
//                                        .font(.appRegular(12))
//                                        .foregroundColor(.white.opacity(0.8))
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                Spacer(minLength: 40)
//                
//                // Кнопка удаления
//                Button {
//                    showDeleteConfirmation = true
//                } label: {
//                    Text("Удалить категорию")
//                        .font(.appMedium(16))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 50)
//                        .background(Color.red.opacity(0.8))
//                        .cornerRadius(12)
//                }
//            }
//            .padding(.horizontal, 24)
//            .padding(.vertical, 16)
//        }
//        .background(.appMain)
//        .navigationTitle("Редактирование")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Сохранить") {
//                    saveChanges()
//                    dismiss()
//                }
//                .foregroundColor(.white)
//                .disabled(categoryName.isEmpty)
//            }
//        }
//        .onAppear {
//            categoryName = category.name
//            selectedIcon = category.icon
//            // Получаем CategoryColor из приватного свойства через вычисляемое свойство
//            selectedCategoryColor = CategoryColor.allCases.first { $0.color == category.color } ?? .blue
//        }
//        .alert("Удалить категорию?", isPresented: $showDeleteConfirmation) {
//            Button("Отмена", role: .cancel) { }
//            Button("Удалить", role: .destructive) {
//                deleteCategory()
//            }
//        } message: {
//            Text("Это действие нельзя отменить. Все транзакции с этой категорией будут удалены.")
//        }
//    }
//    
//    private func saveChanges() {
//        category.name = categoryName
//        category.icon = selectedIcon
//        // Создаем новую категорию с обновленными данными
//        let updatedCategory = TransactionCategory(
//            name: categoryName,
//            icon: selectedIcon,
//            color: selectedCategoryColor,
//            parent: category.parent
//        )
//        
//        // Удаляем старую и добавляем новую
//        modelContext.delete(category)
//        modelContext.insert(updatedCategory)
//        
//        try? modelContext.save()
//    }
//    
//    private func deleteCategory() {
//        modelContext.delete(category)
//        try? modelContext.save()
//        dismiss()
//    }
//}
