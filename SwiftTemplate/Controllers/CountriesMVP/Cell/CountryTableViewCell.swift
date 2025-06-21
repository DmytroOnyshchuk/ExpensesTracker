//
//  CountryTableViewCell.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit

final class CountryTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let flagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appRegularFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let capitalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appRegularFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let populationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appRegularFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .default
        
        containerStackView.addArrangedSubview(nameLabel)
        containerStackView.addArrangedSubview(capitalLabel)
        containerStackView.addArrangedSubview(populationLabel)
        
        contentView.addSubview(flagLabel)
        contentView.addSubview(containerStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Flag label constraints
        flagLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        flagLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        flagLabel.autoSetDimensions(to: CGSize(width: 50, height: 50))
        
        // Container stack view constraints
        containerStackView.autoPinEdge(.leading, to: .trailing, of: flagLabel, withOffset: 16)
        containerStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        containerStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        containerStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    // MARK: - Configuration
    func configure(with country: Country) {
        flagLabel.text = country.flag
        nameLabel.text = country.name
        capitalLabel.text = "Capital: \(country.capital)"
        populationLabel.text = "Population: \(country.population)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        flagLabel.text = nil
        nameLabel.text = nil
        capitalLabel.text = nil
        populationLabel.text = nil
    }
}
