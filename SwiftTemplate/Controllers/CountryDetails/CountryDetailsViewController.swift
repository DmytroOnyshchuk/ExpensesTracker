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
    private lazy var flagLabel = UILabel()
    private lazy var nameLabel = UILabel()
    private lazy var capitalLabel = UILabel()
    private lazy var populationLabel = UILabel()
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [flagLabel, nameLabel, capitalLabel, populationLabel])
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
        setupLabels()
        view.addSubview(stackView)
        stackView.autoCenterInSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
    }
    
    private func setupLabels() {
        flagLabel.font = .systemFont(ofSize: 60)
        nameLabel.font = .boldSystemFont(ofSize: 24)
        capitalLabel.font = .systemFont(ofSize: 18)
        populationLabel.font = .systemFont(ofSize: 18)
        
        flagLabel.text = country.flag
        nameLabel.text = "Country: \(country.name)"
        capitalLabel.text = "Capital: \(country.capital)"
        populationLabel.text = "Population: \(country.population)"
    }
}
