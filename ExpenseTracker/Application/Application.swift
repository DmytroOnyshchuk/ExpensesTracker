//
//  Application.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct ExpenseTracker: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modifier(SystemColorSchemeObserver())
                .preferredColorScheme(ThemeManager.shared.preferredColorScheme)
        }
        .modelContainer(for: [Transaction.self, TransactionCategory.self, Account.self]) { result in
            switch result {
            case let .success(container):
                DataSeeder.seedDefaultCategories(container: container)
            case let .failure(error):
                Logger.default.logError("Failed to initialize model container:", error: error, category: "Application")
            }
        }
    }
}

struct AppRootView: View {
    @State private var isResetting = false

    var body: some View {
        Group {
            if isResetting {
                AppResetView(onFinish: finishReset)
            } else {
                RootTabView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appLogout)) { _ in
            isResetting = true
        }
    }

    private func finishReset() {
        isResetting = false
    }
}

struct AppResetView: View {
    @Environment(\.modelContext) private var modelContext
    let onFinish: () -> Void

    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .task {
                do {
                    try UserManager.shared.logout(context: modelContext)
                } catch {
                    modelContext.rollback()
                    Logger.default.logError("Reset failed", error: error, category: "Application")
                }
                onFinish()
            }
    }
}
