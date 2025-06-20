//
//  ViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 12.06.2025.
//

import UIKit
import PureLayout

final class MainViewController: BaseViewController, InitiableViewControllerProtocol {
    
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
    private lazy var presenter = MainPresenter(controller: self)
    private var countries: [Country] = []
    
    // MARK: - Override
    override var basePresenter: BasePresenterProtocol? { presenter }
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { "Countries" }
    
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

// MARK: - UI Setup
private extension MainViewController {
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        setupConstraints()
        setupTableView()
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
}

private extension MainViewController {
    
}

// MARK: - Public Methods
extension MainViewController {
    
    func setupData(countries: [Country]) {
        self.countries = countries
        tableView.reloadData()
    }
    
}

// MARK: - UITableView DataSource & Delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        let selectedCountry = countries[indexPath.row]
        
        if let сountryDetailsViewController = CountryDetailsViewController.newInstance?.config({
            $0.country = selectedCountry
        }) {
            coordinator.pushViewControllerSafe(сountryDetailsViewController, animated: true)
        }
    }
    
}
