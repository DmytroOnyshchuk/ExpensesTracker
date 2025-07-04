//
//  StartViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit

final class StartViewController: BaseViewController, InitiableViewControllerProtocol {
    
    static var initiableResource: InitiableResource { .xib }
    
    // MARK: - UI Components

    // MARK: - Variables
    private lazy var presenter = StartPresenter(controller: self)
    
    // MARK: - Override
    override var basePresenter: BasePresenterProtocol? { presenter }
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { "STARTVC_TITLE".localized }
    
    override func configureUI() {
    }
    
}

// MARK: - Public Methods
extension StartViewController {
    
}

private extension StartViewController {
    
}

// MARK: - Actions
private extension StartViewController {
    
    @IBAction private func MVPButtonAction(_ sender: UIButton) {
        coordinator.showCountries()
    }
    
    @IBAction func MVVMButtonAction(_ sender: UIButton) {
        coordinator.showLogin()
    }
    
}

