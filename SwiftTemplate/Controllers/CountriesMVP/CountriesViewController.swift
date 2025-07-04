//
//  CountriesViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import PureLayout

final class CountriesViewController: BaseViewController, InitiableViewControllerProtocol {
    
    static var initiableResource: InitiableResource { .manual }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .singleLine
        table.separatorColor = .systemGray4
        table.estimatedRowHeight = 80
        table.rowHeight = UITableView.automaticDimension
        table.sectionHeaderHeight = UITableView.automaticDimension
        table.sectionHeaderTopPadding = 0
        return table
    }()
    
    // MARK: - Variables
    private lazy var presenter = CountriesPresenter(controller: self)
    private var countries: [Country] = []
    
    // MARK: - Override
    override var basePresenter: BasePresenterProtocol? { presenter }
    override var isNavigationBarVisible: Bool { true }
    override var isAppNavigationBarVisible: Bool { false }
    override var navigationBarTitle: String { "COUNTRIESVC_TITLE".localized }
    
    override func configureUI() {
        setupUI()
        NotificationCenter.default.addObserver(forName: .mainScrollToTop, object: nil, queue: nil){ [weak self] _ in
            guard let self = self else { return }
            if self.isVisible {
                self.tableView.scrollToTop()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Public Methods
extension CountriesViewController {
    
    func setupData(countries: [Country]) {
        self.countries = countries
        tableView.reloadData()
    }
    
}

// MARK: - UI Setup
private extension CountriesViewController {
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        setupConstraints()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupConstraints() {
        tableView.autoPinEdgesToSuperviewSafeArea()
    }
    
    private func setupTableView() {
        tableView.config{
            $0.delegate = self
            $0.dataSource = self
            $0.register(CountryTableViewCell.self)
        }
    }
    
    private func setupNavigationBar() {
        let logoutImage = UIImage(systemName: "rectangle.portrait.and.arrow.right") // SF Symbols icon
        let logoutButton = UIBarButtonItem( image: logoutImage, style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
}

private extension CountriesViewController {
    
}

// MARK: - Actions
private extension CountriesViewController {
    
    @objc private func logoutButtonTapped() {
        show(title: "COUNTRIESVC_LOGOUT".localized, message: "COUNTRIESVC_LOGOUT_DESCRIPTION".localized) {
            $0.yesAction { [weak self] in
                self?.presenter.logout()
            }
            $0.noAction()
        }
    }
    
}

// MARK: - UITableView DataSource & Delegate
extension CountriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.get(CountryTableViewCell.self)
        let item = countries[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = countries[indexPath.row]
        
        if let сountryDetailsViewController = CountryDetailsViewController.newInstance?.config({
            $0.country = selectedItem
        }) {
            coordinator.pushViewControllerSafe(сountryDetailsViewController, animated: true)
        }
    }
    
}
