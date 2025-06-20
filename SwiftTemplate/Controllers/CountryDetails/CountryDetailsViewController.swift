//
//  CountryDetailsViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import PureLayout

final class CountryDetailsViewController: BaseViewController, InitiableViewControllerProtocol {
    
    static var initiableResource: InitiableResource { .manual }
    
    // MARK: - Public
    var country: Country!
    
    // MARK: - UI Components
    private var flagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60)
        return label
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private var capitalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private var populationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Variables
    private lazy var presenter = CountryDetailsPresenter(controller: self)
    
    // MARK: - Override
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { country.name }
    
    override func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.autoCenterInSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
        stackView.addArrangedSubviews([flagLabel, nameLabel, capitalLabel, populationLabel])
        setupLabels()
    }
    
    private func setupLabels() {
        flagLabel.text = country.flag
        nameLabel.text = "Country: \(country.name)"
        capitalLabel.text = "Capital: \(country.capital)"
        populationLabel.text = "Population: \(country.population)"
    }
}
