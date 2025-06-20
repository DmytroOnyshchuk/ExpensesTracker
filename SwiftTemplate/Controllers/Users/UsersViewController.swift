//
//  MainViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import PureLayout

final class UsersViewController: BaseViewController, InitiableViewControllerProtocol {
    
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
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Variables
    private lazy var presenter = UsersPresenter(controller: self)
    private var users: [User] = []
    
    // MARK: - Override
    override var basePresenter: BasePresenterProtocol? { presenter }
    override var isNavigationBarVisible: Bool { true }
    override var isAppNavigationBarVisible: Bool { false }
    override var navigationBarTitle: String { "USERSVC_TITLE".localized }
    
    override func configureUI() {
        setupUI()
        NotificationCenter.default.addObserver(forName: .usersScrollToTop, object: nil, queue: nil){ [weak self] _ in
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
private extension UsersViewController {
    
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
            $0.addSubview(refreshControl)
            $0.register(UserTableViewCell.self)
        }
    }
}

private extension UsersViewController {
    
}

// MARK: - Public Methods
extension UsersViewController {
    
    func setupData(users: [User]) {
        refreshControl.endRefreshing()
        self.users = users
        tableView.reloadData()
    }
    
}

// MARK: - Actions
private extension UsersViewController {
    
    @objc private func refreshTriggered() {
        presenter.loadData()
    }
    
}

// MARK: - UITableView DataSource & Delegate
extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.get(UserTableViewCell.self)
        let item = users[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = users[indexPath.row]
        
        if let userDetailsViewController = UserDetailsViewController.newInstance?.config({
            $0.user = selectedItem
        }) {
            coordinator.pushViewControllerSafe(userDetailsViewController, animated: true)
        }

    }
    
}
