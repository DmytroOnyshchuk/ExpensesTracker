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
        .modelContainer(ModelContainer.shared)
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var isResetting = false

    var body: some View {
        Group {
            if isResetting {
                AppResetView(onFinish: finishReset)
            } else {
                RootTabView()
            }
        }
        .onAppear(perform: PasscodeManager.shared.start)
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active, !isResetting {
                modelContext.runAutoPayments()
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
                try? await Task.sleep(for: .milliseconds(500))
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
