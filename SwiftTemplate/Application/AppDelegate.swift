//
//  AppDelegate.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 12.06.2025.
//

import UIKit
import AppTrackingTransparency
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//#if PROD
//        let googleServiceFileName = "GoogleService-Info-Prod"
//#else
//        let googleServiceFileName = "GoogleService-Info"
//#endif
//        
//        if let path = Bundle.main.path(forResource: googleServiceFileName, ofType: "plist"), let options = FirebaseOptions(contentsOfFile: path) {
//            FirebaseApp.configure(options: options)
//#if DEBUG
//            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
//#endif
//        }

        registerDependencies()
        @Inject var notificationManager: NotificationManager
        notificationManager.config(application) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self?.requestTrackingAuthorization()
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.default.logMessage("Did Register For Remote Notifications With Device Token: \(deviceToken)", category: self.className)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

private extension AppDelegate {
    
    private func registerDependencies() {
        let databaseManager = DatabaseManager()
        let userManager = UserManager()
        let apiManager = API.Manager(userManager: userManager)
        let notificationManager = NotificationManager()
        let appTabBarController = AppTabBarController().embeddedInAppNavigationController
        let coordinator = AppCoordinator(appNavigationController: appTabBarController)
        
        DependencyManager {
            Module { databaseManager as DatabaseManagerProtocol }
            Module { userManager }
            Module { notificationManager }
            Module { coordinator }
        }.build()
    }
    
    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            switch status {
                case .authorized:
                    Logger.default.logMessage("Пользователь разрешил доступ IDFA")
                    Analytics.setAnalyticsCollectionEnabled(true)
                case .denied, .restricted:
                    Logger.default.logMessage("Пользователь запретил доступ.")
                    Analytics.setAnalyticsCollectionEnabled(false)
                case .notDetermined:
                    Logger.default.logMessage("Пользователь ещё не получил запрос на авторизацию.")
                @unknown default:
                    break
            }
        }
    }
    
}

// выводим print только для разработчиков
func print(_ items: Any...) {
#if DEBUG
    Swift.print(items.first ?? "NIL")
#endif
}

