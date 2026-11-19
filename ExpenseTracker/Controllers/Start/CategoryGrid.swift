//
//  CategoryGrid.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import RealmSwift
import SwiftUI

struct CategoryGrid: View {
    @ObservedResults(TransactionCategory.self, where: TransactionCategory.nonDirectories) private var storedCategories
    var operationType: OperationType = .outcome
    var onSelect: (TransactionCategory) -> Bool

    @State private var currentPage: Int? = .zero
    @State private var showAllCategories = false
    @State private var navigateToEditCategories = false

    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    }

    private var categories: [TransactionCategory] { storedCategories.of(operationType) }

    private var chunkedCategories: [[TransactionCategory]] {
        categories.inDisplayOrder.chunked(into: 8)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(0 ..< chunkedCategories.count, id: \.self) { pageIndex in
                        VStack(alignment: .center, spacing: 0) {
                            LazyVGrid(columns: gridLayout, spacing: 0) {
                                ForEach(chunkedCategories[pageIndex], id: \.id) { category in
                                    CategoryCell(category: category) {
                                        onSelect(category)
                                    }
                                }

                                if pageIndex == chunkedCategories.count - 1 {
                                    EditCategoriesCell {
                                        showAllCategories = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, -4)
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(pageIndex)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentPage)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            // .frame(height: 176)

            if chunkedCategories.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0 ..< chunkedCategories.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.appWhite : Color.appWhite.opacity(0.4))
                            .frame(width: 6, height: 6)
                            .onTapGesture {
                                withAnimation(.appStandard) {
                                    currentPage = index
                                }
                            }
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationDestination(isPresented: $showAllCategories) {
            CategoriesEdit(operationType: operationType)
        }
    }
}

struct EditCategoriesCell: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "square.grid.2x2.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(IconColor.yellow.color)
                    .frame(width: 48, height: 56)

                Spacer(minLength: 8)

                Text(L10n.menuCategories)
                    .font(.appRegular(12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryGrid(onSelect: { _ in true })
        .padding(.vertical, 16)
        .background(.appMain)
        .environment(\.realmConfiguration, makePreviewRealm().configuration)
}

#Preview("All categories button") {
    EditCategoriesCell(action: {})
        .padding()
        .background(.appMain)
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
