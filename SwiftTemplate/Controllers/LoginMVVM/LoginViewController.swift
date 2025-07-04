//
//  LoginMVVMViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 21.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import Combine
import PureLayout

final class LoginViewController: BaseViewController, InitiableViewControllerProtocol {
    
    static var initiableResource: InitiableResource { .manual }
    
    // MARK: - UI Components
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private var emailTextField: DesignableTextField = {
        let textField = DesignableTextField()
        textField.placeholder = "LOGINVC_EMAIL".localized
        textField.text = Constants.defaultCredential.login
        textField.contentPadding = 12
        textField.borderColor = .systemGray
        textField.borderWidth = 1
        textField.cornerRadius = 8
        textField.keyboardType = .emailAddress
        textField.font = .appRegularFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private var passwordTextField: DesignableTextField = {
        let textField = DesignableTextField()
        textField.placeholder = "LOGINVC_PASSWORD".localized
        textField.text = Constants.defaultCredential.password
        textField.contentPadding = 12
        textField.borderColor = .systemGray
        textField.borderWidth = 1
        textField.cornerRadius = 8
        textField.font = .appRegularFont(ofSize: 16)
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private var loginButton: DesignableButton = {
        let button = DesignableButton()
        button.setTitle("LOGINVC_ENTER".localized)
        button.titleLabel?.font = .appRegularFont(ofSize: 16)
        button.setTitleColor(.white)
        button.backgroundColor = .systemBlue
        button.borderWidth = 1
        button.roundCornerRadius = true
        return button
    }()
    
    private var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()
    
    private var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        return stackView
    }()
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .appRegularFont(ofSize: 14)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - ViewModel
    private let viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Override
    override var isKeyboardObserving: Bool { true }
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { "LOGINVC_TITLE".localized }
    
    @Inject private var userManager: UserManager
    
    override func configureUI() {
        setupUI()
        setupUI()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
}

private extension LoginViewController{
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        inputStackView.addArrangedSubview(emailTextField)
        inputStackView.addArrangedSubview(passwordTextField)
        
        buttonStackView.addArrangedSubview(loginButton)
        buttonStackView.addArrangedSubview(errorLabel)
        
        mainStackView.addArrangedSubview(UIView())
        mainStackView.addArrangedSubview(inputStackView)
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(UIView())
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        scrollView.autoPinEdgesToSuperviewEdges()
        
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.autoMatch(.width, to: .width, of: scrollView)
        
        mainStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        mainStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 32)
        mainStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 32)
        mainStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20, relation: .greaterThanOrEqual)
        
        emailTextField.autoSetDimension(.height, toSize: 42)
        passwordTextField.autoSetDimension(.height, toSize: 42)
        
        loginButton.autoSetDimension(.height, toSize: 42)
        
        let centerConstraint = mainStackView.autoAlignAxis(toSuperviewAxis: .horizontal)
        centerConstraint.priority = UILayoutPriority(250)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Bind text fields to view model
        emailTextField.textPublisher
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)
        
        passwordTextField.textPublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
        
        // Bind form validation to button state
        viewModel.isEmailValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.emailTextField.borderColor = isValid ? UIColor.green : UIColor.red
            }
            .store(in: &cancellables)
        
        
        viewModel.isPasswordValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.passwordTextField.borderColor = isValid ? UIColor.green : UIColor.red
            }
            .store(in: &cancellables)
        
        viewModel.isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
               // self?.emailTextField.borderColor = isValid ? UIColor.green : UIColor.red
               // self?.passwordTextField.borderColor = isValid ? UIColor.green : UIColor.red
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loginButton.startLoadingIndicator(indicatorColor: .systemGray)
                } else {
                    self?.loginButton.stopLoadingIndicator()
                }
            }
            .store(in: &cancellables)
        
        // Bind error message
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.errorLabel.text = error
                    self?.errorLabel.isHidden = false
                    self?.shakeErrorLabel()
                } else {
                    self?.errorLabel.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        // Bind login success
        viewModel.$isLoginSuccessful
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccessful in
                if isSuccessful {
                    self?.userManager.userId = Int.random.asString
                    NotificationCenter.default.post(name: .appLogin, object: nil)
                    self?.coordinator.start()
                }
            }
            .store(in: &cancellables)
    }
    
    private func shakeErrorLabel() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        errorLabel.layer.add(animation, forKey: "shake")
    }
    
}

// MARK: Actions
private extension LoginViewController{
    
    // MARK: - Actions
    private func setupActions() {
        view.addTapGesture{ [weak self] in
            self?.dismissKeyboard()
        }
    }
    
    @objc private func loginButtonTapped() {
        dismissKeyboard()
        viewModel.clearError()
        viewModel.login()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: Keyboard
extension LoginViewController {
    
    override func keyboardWillShow(withHeight keyboardHeight: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override func keyboardWillChangeFrame(to keyboardHeight: CGFloat, withDuration duration: TimeInterval, options: UIView.AnimationOptions) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override func keyboardWillHide(withDuration duration: TimeInterval, options: UIView.AnimationOptions) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
}
