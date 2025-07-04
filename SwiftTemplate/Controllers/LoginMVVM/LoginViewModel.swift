//
//  LoginViewModel.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 21.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import Combine

// MARK: - LoginViewModel
final class LoginViewModel: ObservableObject {
    
    @Published var email: String = Constants.defaultCredential.login
    @Published var password: String = Constants.defaultCredential.password
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoginSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Computed properties для валидации
    var isEmailValid: AnyPublisher<Bool, Never> {
        $email
            .map { email in
                return email.isValidEmail()
            }
            .eraseToAnyPublisher()
    }
    
    var isPasswordValid: AnyPublisher<Bool, Never> {
        $password
            .map { !$0.isBlank }
            .eraseToAnyPublisher()
    }
    
    var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isEmailValid, isPasswordValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    func login() {
        isLoading = true
        errorMessage = nil
        
        // Симуляция API запроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoading = false
            
            if self?.email == Constants.defaultCredential.login && self?.password == Constants.defaultCredential.password {
                self?.isLoginSuccessful = true
            } else {
                self?.errorMessage = "LOGINVC_WRONG_CREDENTIAL".localized
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
