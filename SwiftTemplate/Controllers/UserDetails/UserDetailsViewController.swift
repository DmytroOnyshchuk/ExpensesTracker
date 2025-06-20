//
//  UserDetailViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import PureLayout

final class UserDetailsViewController: BaseViewController, InitiableViewControllerProtocol {
    
    static var initiableResource: InitiableResource { .manual }
    
    // MARK: - Public
    var user: User!
    
    // MARK: - UI Components
    private var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        stack.distribution = .fill
        return stack
    }()
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Variables
    private lazy var presenter = UserDetailsPresenter(controller: self)
    
    // MARK: - Overrides
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { user.name }
    
    override func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(mainStackView)
        mainStackView.autoPinEdgesToSuperviewSafeArea(with: .init(top: 16, left: 16, bottom: 16, right: 16))
        mainStackView.addArrangedSubview(stackView)
        configureDetails()
    }
    
}

private extension UserDetailsViewController {
    
    private func configureDetails() {
        let details: [String] = [
            String(format: "USERDETAILSVC_USERNAME".localized, user.username),
            String(format: "USERDETAILSVC_EMAIL".localized, user.email),
            String(format: "USERDETAILSVC_PHONE".localized, user.phone),
            String(format: "USERDETAILSVC_WEBSITE".localized, user.website),
            String(format: "USERDETAILSVC_COMPANY".localized, user.company.name),
            String(format: "USERDETAILSVC_ADDRESS".localized, user.address.street, user.address.city),
        ]
        
        details.forEach { text in
            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            stackView.addArrangedSubview(label)
        }
    }
    
}
