//
//  SceneDelegate.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseCore
import FirebaseCrashlytics
import Toast
import VersionTracker
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

var currentScene: UIScene?

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    @Inject private var userManager: UserManager
    @Inject private var notificationManager: NotificationManager
    @Inject private var apiManager: API.Manager
    @Inject private var coordinator: AppCoordinator
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        currentScene = scene
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
#if DEBUG
        // wake a developer up if he fall asleep during long compilaton
        debounce(delay: 1) {
            AudioServicesPlayAlertSound(SystemSoundID(1016))
        }
#endif
        Logger.default.logMessage("Version \"\(Bundle.main.appVersionNumber)\". Build \"\(Bundle.main.appBuildNumber)\"", category: self.className)
        Logger.default.logMessage("API Token: \(userManager.apiToken ?? "NONE")", category: self.className)
        checkAppEnvironment()
        configureServices()
        
        coordinator.start()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

private extension SceneDelegate {
    
    private func configureServices() {
        userManager.currentLanguage = Language(rawValue: LanguageManager.getSystemLanguage().rawValue)
        VersionTracker.shared.track()
        configureIQKeyboard()
        configureToastUI()
        setupNotifications()
    }
    
    private func setupNotifications() {
        
        NotificationCenter.default.addObserver(forName: .appLogin, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            
            apiManager.regenerateSession()
            
//            if let token = userManager.fcmToken {
//                apiManager.request(type: API.Request.UpdatePushToken(token: token)).cauterize()
//            }
        }
        
        NotificationCenter.default.addObserver(forName: .appLogout, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
//            apiManager.request(type: API.Request.UpdatePushToken(token: ""))
//                .done { [weak self] result in
//                }
//                .ensure {
//                    self.apiManager.regenerateSession()
//                    UIApplication.showMain()
//                }
//                .cauterize()
        }
        
    }
    private func checkAppEnvironment() {
        guard AppEnvironment.current != userManager.lastApplicationEnvironment else { return }
        userManager.logout()
        userManager.lastApplicationEnvironment = AppEnvironment.current
    }
    
    private func configureIQKeyboard() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor = .white
        IQKeyboardToolbarManager.shared.toolbarConfiguration.barTintColor = .white
        IQKeyboardToolbarManager.shared.toolbarConfiguration.placeholderConfiguration.color = .white
    }
    
    private func configureToastUI() {
        var style = ToastManager.shared.style
        style.titleAlignment = .center
        style.messageAlignment = .center
        ToastManager.shared.style = style
    }
    
}
