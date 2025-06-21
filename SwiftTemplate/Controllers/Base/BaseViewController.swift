//
//  NavBarConfig.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toast
import Photos
import AVFoundation

enum NavBarConfig {
    case defaultBackground
    case transparentBackground
}

class BaseViewController: UIViewController {
    
    @Inject var coordinator: AppCoordinator
    
    var basePresenter: BasePresenterProtocol? { nil }
    var isKeyboardObserving: Bool { false }
    var textFieldSequence: [UIView] { [] }
    
    var isNavigationBarVisible: Bool { true }
    var isAppNavigationBarVisible: Bool { true }
    
    var navigationBarConfig: NavBarConfig? { .transparentBackground }
    var navigationBarColor: UIColor? { nil }
    
    var navigationBarTitle: String? { nil }
    var navigationBarTitleColor: UIColor? { .appBlack }
    
    var navigationBarBackButtonColor: UIColor? { .appBlack }
    var navigationBarHideBackButton: Bool { false }
    
    var hideBottomBar: Bool { false }
    override var preferredStatusBarStyle: UIStatusBarStyle { navigationBarColor != nil ? .lightContent : .default}
    
    var parameters: Any?
    var isVisible: Bool = false
    
    lazy var textFieldToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(image: UIImage(named: "ic_arrow_up"), style: .plain, target: self, action: #selector(toolbarPrevButtonPressed)),
            UIBarButtonItem(image: UIImage(named: "ic_arrow_down"), style: .plain, target: self, action: #selector(toolbarNextButtonPressed)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "DONE".localized, style: .plain, target: self, action: #selector(toolbarDoneButtonPressed))
        ]
        toolbar.items?.forEach { $0.tintColor = .appDarkGreen }
        toolbar.sizeToFit()
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.default.logMessage("viewDidLoad", category: className)
        configureNavigationBar()
        if let navigationBarTitle {
            title = navigationBarTitle
        }
        configureUI()
        basePresenter?.viewDidLoad()
        
        for item in textFieldSequence {
            switch item {
            case let textFiels as UITextField:
                textFiels.inputAccessoryView = textFieldToolbar
            case let textView as UITextView:
                textView.inputAccessoryView = textFieldToolbar
            default:
                break
            }
        }
        if isKeyboardObserving {
            beginKeyboardObserving()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        basePresenter?.runtimeConfigureUI(animated)
        if isKeyboardObserving {
            beginKeyboardObserving()
        }
        
        if hideBottomBar {
            tabBarController?.tabBar.isHidden = true
        }
        
        if let navigationController = navigationController, parent == navigationController {
            navigationController.navigationBar.alpha = 1
            navigationController.navigationBar.isHidden = !isNavigationBarVisible
            navigationController.setNavigationBarHidden(!isNavigationBarVisible, animated: false)
        }
        coordinator.appNavigationController.setNavigationBarHidden(!isAppNavigationBarVisible, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
        basePresenter?.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        basePresenter?.viewWillDisappear(animated)
        if isKeyboardObserving {
            endKeyboardObserving()
        }
        
        if hideBottomBar {
            tabBarController?.tabBar.isHidden = false
        }
        isVisible = false
    }
    
    func configureUI() {
    }
    
    deinit {
        Logger.default.logMessage("deinit", category: className)
    }
    
}

extension BaseViewController {
    
    // MARK: - Keyboard Toolbar
    @objc private func toolbarNextButtonPressed(_ sender: Any) {
        guard let index = textFieldSequence.compactMap({ $0 as? UITextField }).firstIndex(where: { $0.isEditing }), textFieldSequence.count - 1 > index else { return }
        let texfField = textFieldSequence[index + 1]
        if !texfField.isHidden {
            texfField.becomeFirstResponder()
        }
    }
    
    @objc private func toolbarPrevButtonPressed(_ sender: Any) {
        guard let index = textFieldSequence.compactMap({ $0 as? UITextField }).firstIndex(where: { $0.isEditing }), index > 0 else { return }
        textFieldSequence[index - 1].becomeFirstResponder()
    }
    
    @objc func toolbarDoneButtonPressed(_ sender: Any) {
        view.endEditing(true)
    }
}

extension BaseViewController {
    
    func show(title: String?, message: String?) {
        show(title: title, message: message) {
            $0.doneAction()
        }
    }
    
    func show(title: String?, message: String?, config: ((UIAlertController) -> ())? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        config?(vc)
        
        present(vc, animated: true, completion: nil)
    }
    
    func showError(message: String, handler: (() -> Void)? = nil) {
        show(title: "ERROR".localized, message: message) {
            $0.doneAction { [weak self] in
                handler?()
            }
        }
    }
    
    func showError(error: Error?, handler: (() -> Void)? = nil) {
        if let err = error {
            switch err {
            case let apiError as API.ApiError:
                showApiError(apiError, handler: handler)
            default:
                //String(describing: err)
                showError(message: err.localizedDescription, handler: handler)
            }
        }else{
            showError(message: error?.localizedDescription ?? "BASEVC_TRY_AGAIN_LATTER".localized, handler: handler)
        }
    }
    
    private func showApiError(_ error: API.ApiError?, handler: (() -> Void)? = nil) {
        switch error {
        case .errorType(let typeError):
            switch typeError {
            case .incorrectPin:
                show(title: "BASEVC_WRONG_CODE_TITLE".localized, message: "BASEVC_WRONG_CODE_SECRIPTION".localized)
            case .userIsBlocked, .deviceIsBlocked:
                showUserBlockedMessage()
            case .versionError:
                showAppUpdateMessage()
            default:
                showError(message: error?.localizedDescription ?? "BASEVC_TRY_AGAIN_LATTER".localized, handler: handler)
            }
        case .other(let error) where (error.asAFError?.isExplicitlyCancelledError ?? false):
            break
        default:
            showError(message: error?.localizedDescription ?? "BASEVC_TRY_AGAIN_LATTER".localized, handler: handler)
        }
        
    }
    
}

extension BaseViewController {
    
    func setAttributedTitle(_ text: NSAttributedString) {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.attributedText = text
        navigationItem.titleView = label
    }
    
}

extension BaseViewController: UIGestureRecognizerDelegate { }

extension BaseViewController {
    
    func configureNavigationBar() {
        guard let navigationController = navigationController else { return }
        
        if navigationBarHideBackButton {
            navigationItem.hidesBackButton = true
        } else if navigationController.viewControllers.count > 1 {
            let backButton: UIButton = getBackButton()
            if navigationBarBackButtonColor == nil {
                if let _ = navigationBarColor {
                    backButton.imageView?.tintColor = .white
                } else {
                    backButton.imageView?.tintColor = .appBlack
                }
            } else {
                backButton.imageView?.tintColor = navigationBarBackButtonColor
            }
            
            navigationItem.leftBarButtonItem = .init(customView: backButton)
            navigationController.interactivePopGestureRecognizer?.delegate = self
        }
        
        
        let app = UINavigationBarAppearance()
        
        switch navigationBarConfig {
        case .defaultBackground:
            app.configureWithDefaultBackground()
        default:
            app.configureWithTransparentBackground()
        }
        
        app.titleTextAttributes = [.foregroundColor : navigationBarTitleColor,
                                   .font : UIFont.appRegularFont(ofSize: 14)]
        
        app.backgroundColor = navigationBarColor
        navigationItem.standardAppearance = app
        navigationItem.scrollEdgeAppearance = app
        
        view.layoutIfNeeded()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    func getBackButton() -> UIButton {
        let backImage = UIImage(named: "ic_arrow_left")!
        let backButton = UIButton(frame: .init(origin: .zero, size: CGSize(width: 48, height: 48)))
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        backButton.setImage(backImage.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.imageView?.tintColor = .appBlack
        return backButton
    }
    
    func share(_ urlLink: String?) {
        guard let urlString = urlLink, let url = URL(string: urlString) else { return }
        share(url)
    }
    
    func share(_ url: URL?) {
        if let urlLink = url {
            
            showLoadingIndicator()
            
            let activityViewController = UIActivityViewController(activityItems: [ urlLink ], applicationActivities: nil)
            
            // avoiding to crash on iPad
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                popoverController.sourceView = view
                popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
            
            hideLoadingIndicator()
            
            present(activityViewController, animated: true, completion: nil)
            
        }
    }
    
}

extension BaseViewController {
    
    func checkPhotoLibraryPermission(_ completion: @escaping () -> ()) {
        
        func configPhotoLibrary() {
            show(title: "BASEVC_PERMISSION".localized, message: "BASEVC_PERMISSION_GALLERY".localized) {
                $0.addAction(withTitle: "BASEVC_PERMISSION_SETTINGS".localized, UIApplication.shared.openSettings)
                $0.noAction()
            }
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { [weak self] status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        completion()
                    }
                default: break
                }
            }
        default: configPhotoLibrary()
        }
    }
    
    func checkCameraPermission(_ completion: ((Bool) -> ())? = nil) {
        
        func configCamera() {
            show(title: "BASEVC_PERMISSION".localized, message: "BASEVC_PERMISSION_CAMERA".localized) {
                $0.addAction(withTitle: "BASEVC_PERMISSION_SETTINGS".localized, UIApplication.shared.openSettings)
                $0.noAction{ [weak self] in
                    completion?(false)
                }
            }
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: completion?(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        completion?(success)
                    }
                }
            }
        default: configCamera()
        }
    }
    
}

// MARK: Toasts
extension BaseViewController {
    
    func showErrorToast(_ message: String) {
        showToast(title: "ERROR".localized, msg: message)
    }
    
    public func showToast(title: String? = nil, msg: String, position: ToastPosition = .bottom) {
        view.hideAllToasts()
        if position == .top {
            let top: Double = view.bounds.size.height / 6.0
            let center = CGPoint(x: view.bounds.size.width / 2.0, y: top)
            view.makeToast(msg, duration: 1.5, point: center, title: title, image: nil, completion: nil)
        } else if position == .bottom {
            let bottom: Double = (view.bounds.size.height / 4.0) * 3.0
            let center = CGPoint(x: view.bounds.size.width / 2.0, y: bottom)
            view.makeToast(msg, duration: 1.5, point: center, title: title, image: nil, completion: nil)
        }
    }
    
}

// MARK: Messsages
extension BaseViewController {
    
    private func showUserBlockedMessage() {
        show(title: "ATTENTION".localized, message: "BASEVC_BLOCKED_ALERT".localized) {
            $0.addAction(withTitle: "SUPPORT".localized){ [weak self] in
               // SupportRequestViewController.push(in: self?.navigationController)
            }
        }
    }
    
    private func showAppUpdateMessage() {
        show(title: nil, message: "BASEVC_PLEASE_UPDATE".localized) {
            $0.addAction(withTitle: "UPDATE".localized){ [weak self] in
                //UIApplication.shared.open(Constants.appStore)
                self?.showAppUpdateMessage()
            }
        }
    }
    
}

// MARK: Indicator
extension BaseViewController {
    
    func showLoadingIndicator() {
        showLoadingIndicator(withGraceTime: 0.5)
    }
    
    private func showLoadingIndicator(withGraceTime graceTime: Double) {
        guard getLoadingIndicator() == nil else { return }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        view.addSubview(hud)
        hud.graceTime = graceTime
        hud.show(animated: true)
    }
    
    func hideLoadingIndicator() {
        let indicators = view.subviews.filter{$0 is MBProgressHUD}
        for indicator in indicators {
            indicator.removeFromSuperview()
        }
    }
    
    private func getLoadingIndicator() -> MBProgressHUD? {
        let result: MBProgressHUD? = nil
        
        let indicators = view.subviews.filter{ $0 is MBProgressHUD }
        for indicator in indicators {
            return indicator as? MBProgressHUD
        }
        return result
    }
    
}

extension BaseViewController {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
#if DEBUG
        guard motion == .motionShake, UIApplication.shared.visibleViewController == self else { return }
#else
        guard motion == .motionShake, UIApplication.shared.visibleViewController == self, Logger.default.isTestFlight else { return }
#endif
        let alert = UIAlertController(title: "BASEVC_EXPORT_LOG".localized, message: "BASEVC_EXPORT_LOG_VERSION".localized + " \(Bundle.main.appVersionNumber)(\(Bundle.main.appBuildNumber))", preferredStyle: .alert)
        alert.addAction(.init(title: "BASEVC_EXPORT_LOG_TITLE".localized, style: .default, handler: { [weak self] _ in
            self?.exportDebugLog()
        }))
        alert.addAction(.init(title: "CANCEL".localized, style: .cancel))
        present(alert, animated: true)
    }
    
    private func exportDebugLog() {
        guard let fileUrl = Logger.default.fileUrl else { return }
        let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
}

extension BaseViewController {
    
    func isKeyboardExtensionEnabled() -> Bool {
        guard let appBundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("isKeyboardExtensionEnabled(): Cannot retrieve bundle identifier.")
        }
        guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else {
            return false
        }
        
        let keyboardExtensionBundleIdentifierPrefix = appBundleIdentifier + "."
        return keyboards.contains { $0.hasPrefix(keyboardExtensionBundleIdentifierPrefix) }
    }
    
    func isKeyboardExtensionHasFullAccess() -> Bool {
        return UIInputViewController().hasFullAccess
    }
    
    func isKeyboardAdded() -> Bool {
        return isKeyboardExtensionEnabled() && isKeyboardExtensionHasFullAccess()
    }
    
}
