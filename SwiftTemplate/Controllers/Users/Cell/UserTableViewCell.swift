//
//  UserTableViewCell.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import PureLayout

final class UserTableViewCell: UITableViewCell {
    
    // MARK: - UI
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let companyLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        companyLabel.text = user.company.name
    }
}

// MARK: - UI Setup
private extension UserTableViewCell {
    
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        nameLabel.font = .boldSystemFont(ofSize: 16)
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel
        companyLabel.font = .systemFont(ofSize: 13)
        companyLabel.textColor = .tertiaryLabel
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .init(top: 12, left: 16, bottom: 12, right: 16))
        
        [nameLabel, emailLabel, companyLabel].forEach { stackView.addArrangedSubview($0) }
    }
}
