//
//  UIViewController.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 17.12.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if let navigationController = navigationController, navigationController.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if let tabBarController = tabBarController, tabBarController.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
	
}

extension UIViewController {
    
    func showActionSheet(title: String? = nil, message: String? = nil, config: ((UIAlertController) -> ())? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        config?(vc)
        
        present(vc, animated: true, completion: nil)
    }
    
    @objc func backButton() -> UIBarButtonItem {
        let image =  #imageLiteral(resourceName: "icon_back_clear")
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.setImage(image, for: .normal)
        
        return UIBarButtonItem.init(customView: button)
    }
    
    @objc func back() {
        if isModal{
            dismiss(animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController.isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
    
}

//import AVFoundation
//extension UIViewController {
//    
//    func checkCameraPermission(_ completion: @escaping () -> ()) {
//        
//        func configCamera() {
//            show(title: "Attention", message: "To continue, you must allow the application to use the Camera") { [weak self] in
//                $0.cancelAction()
//                $0.addAction(withTitle: "Settings", UIApplication.shared.openSettings)
//            }
//        }
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//            case .authorized: completion()
//            case .notDetermined:
//                AVCaptureDevice.requestAccess(for: .video) { success in
//                    if success {
//                        DispatchQueue.main.async { completion() }
//                    } else {
//                        DispatchQueue.main.async { configCamera() }
//                    }
//                }
//            default: configCamera()
//        }
//    }
//    
//}
//
//import Photos
//extension UIViewController {
//    
//    func checkPhotoLibraryPermission(_ completion: @escaping () -> ()) {
//        
//        func configPhotoLibrary() {
//            showEx(
//                title: "Attention",
//                message: "To continue, you must allow the application to use the Gallery"
//            ) { [weak self] in
//                $0.cancelAction()
//                $0.addAction(withTitle: "Settings", UIApplication.shared.openSettings)
//            }
//        }
//        
//        let status = PHPhotoLibrary.authorizationStatus()
//        switch status {
//            case .authorized: completion()
//            case .notDetermined:
//                PHPhotoLibrary.requestAuthorization { status in
//                    switch status {
//                        case .authorized: DispatchQueue.main.async { completion() }
//                        default: break
//                    }
//                }
//            default: configPhotoLibrary()
//        }
//    }
//    
//}
//
//extension UIViewController {
//    
//    func checkMicrophonePermission(_ completion: @escaping (Bool) -> ()) {
//        
//        func configMicrophone() {
//            showEx(title: "Permission", message: "To continue, you should allow the application to use the Microphone") { [weak self] in
//                $0.addAction(withTitle: "Settings", UIApplication.shared.openSettings)
//                $0.noAction(){
//                    completion(false)
//                }
//            }
//        }
//        
//        switch AVAudioSession.sharedInstance().recordPermission {
//            case .granted:
//                completion(true)
//            case .undetermined:
//                AVAudioSession.sharedInstance().requestRecordPermission({ granted in
//                    if granted {
//                        DispatchQueue.main.async { completion(true) }
//                    } else {
//                        DispatchQueue.main.async { configMicrophone() }
//                    }
//                })
//            default:
//                configMicrophone()
//        }
//        
//    }
//    
//}

internal extension UIViewController {
    // Get ViewController in top present level
    var topPresentedViewController: UIViewController? {
        var target: UIViewController? = self
        while (target?.presentedViewController != nil) {
            target = target?.presentedViewController
        }
        return target
    }
    
    // Get top VisibleViewController from ViewController stack in same present level.
    // It should be visibleViewController if self is a UINavigationController instance
    // It should be selectedViewController if self is a UITabBarController instance
    var topVisibleViewController: UIViewController? {
        if let navigation = self as? UINavigationController {
            if let visibleViewController = navigation.visibleViewController {
                return visibleViewController.topVisibleViewController
            }
        }
        if let tab = self as? UITabBarController {
            if let selectedViewController = tab.selectedViewController {
                return selectedViewController.topVisibleViewController
            }
        }
        return self
    }
    
    // Combine both topPresentedViewController and topVisibleViewController methods, to get top visible viewcontroller in top present level
    var topMostViewController: UIViewController? {
        return self.topPresentedViewController?.topVisibleViewController
    }
    
    func showTextViewAlert(title: String, message: String? = nil, attributedText: NSAttributedString? = nil, withoutAttributedText: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        if attributedText != nil {
            textView.attributedText = attributedText
        } else {
            textView.text = withoutAttributedText
        }
        textView.isEditable = false
        textView.font = UIFont.appRegularFont(ofSize: 14)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        
        alert.view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            textView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
            textView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
}
