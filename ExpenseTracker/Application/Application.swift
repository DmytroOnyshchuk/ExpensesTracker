//
//  Application.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import RealmSwift
import SwiftUI

@main
struct ExpenseTracker: SwiftUI.App {
    init() {
        _ = Realm.shared
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modifier(SystemColorSchemeObserver())
                .preferredColorScheme(ThemeManager.shared.preferredColorScheme)
        }
    }
}

struct AppRootView: View {
    @Environment(\.realm) private var realm
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
                realm.runAutoPayments()
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
    @Environment(\.realm) private var realm
    let onFinish: () -> Void

    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                do {
                    try UserManager.shared.logout(realm: realm)
                } catch {
                    Logger.default.logError("Reset failed", error: error, category: "Application")
                }
                onFinish()
            }
    }
}
