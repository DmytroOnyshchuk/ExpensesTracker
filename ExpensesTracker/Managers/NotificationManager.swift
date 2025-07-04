//
//  NotificationManager.swift
//  Orovera
//
//  Created by Denis Kuznetsov on 27.08.2021.
//

import UIKit

final class NotificationManager: NSObject {
	
	@Inject private var userManager: UserManager
	@Inject private var apiManager: API.Manager
	
    func config(_ application: UIApplication, completionOfRequest: @escaping () -> Void = {  }){
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            if error == nil {
                if success {
                    DispatchQueue.main.async {
                        let application = UIApplication.shared
                        application.registerForRemoteNotifications()
                    }
                }
                completionOfRequest()
            } else {
				Logger.default.logMessage("Error: \(String(describing: error))", category: "NotificationManager", type: .error)
            }
            
        }
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound, .badge])
    }
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
			handleNotification(userInfo: userInfo)
		}
		
		completionHandler()
	}
	
	func handleNotification(userInfo: [AnyHashable: Any]) {
	}
    
}

extension NotificationManager {
	
	func createLocalNotification(dateComponent: DateComponents, notificationId: String, title: String, body: String){
		
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = body
		content.sound = UNNotificationSound.default
		content.userInfo = ["notificationId": notificationId]
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
		let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) { error in
			if let err = error {
				Logger.default.logMessage("Error: \(err)", category: "NotificationManager", type: .error)
			}
		}
	}
	
	func removeAllLocalNotifications(){
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
}
