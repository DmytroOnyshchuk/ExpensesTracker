//
//  ViewController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 12.06.2025.
//

import UIKit
import PureLayout

// MARK: - Country Model
struct Country {
    let name: String
    let capital: String
    let population: String
    let flag: String
}

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
    @Inject private var userManager: UserManager
    
    private var countries: [Country] = []
    
    // MARK: - Override
    override var basePresenter: BasePresenterProtocol? { presenter }
    override var isNavigationBarVisible: Bool { true }
    override var navigationBarTitle: String { "Countries" }
    
    override func configureUI() {
        setupUI()
        setupTestData()
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

// MARK: - Data Setup
private extension MainViewController {
    
    func setupTestData() {
        countries = [
            Country(name: "Украина", capital: "Киев", population: "41.3 млн", flag: "🇺🇦"),
            Country(name: "США", capital: "Вашингтон", population: "331 млн", flag: "🇺🇸"),
            Country(name: "Германия", capital: "Берлин", population: "83.2 млн", flag: "🇩🇪"),
            Country(name: "Франция", capital: "Париж", population: "67.4 млн", flag: "🇫🇷"),
            Country(name: "Италия", capital: "Рим", population: "59.6 млн", flag: "🇮🇹"),
            Country(name: "Испания", capital: "Мадрид", population: "47.4 млн", flag: "🇪🇸"),
            Country(name: "Великобритания", capital: "Лондон", population: "67.8 млн", flag: "🇬🇧"),
            Country(name: "Канада", capital: "Оттава", population: "38.2 млн", flag: "🇨🇦"),
            Country(name: "Австралия", capital: "Канберра", population: "25.7 млн", flag: "🇦🇺"),
            Country(name: "Япония", capital: "Токио", population: "125.8 млн", flag: "🇯🇵"),
            Country(name: "Китай", capital: "Пекин", population: "1.4 млрд", flag: "🇨🇳"),
            Country(name: "Индия", capital: "Нью-Дели", population: "1.38 млрд", flag: "🇮🇳"),
            Country(name: "Бразилия", capital: "Бразилиа", population: "215 млн", flag: "🇧🇷"),
            Country(name: "Аргентина", capital: "Буэнос-Айрес", population: "45.4 млн", flag: "🇦🇷"),
            Country(name: "Мексика", capital: "Мехико", population: "128 млн", flag: "🇲🇽"),
            Country(name: "Россия", capital: "Москва", population: "144 млн", flag: "🇷🇺"),
            Country(name: "Турция", capital: "Анкара", population: "84.8 млн", flag: "🇹🇷"),
            Country(name: "Египет", capital: "Каир", population: "104 млн", flag: "🇪🇬"),
            Country(name: "ЮАР", capital: "Кейптаун", population: "60.4 млн", flag: "🇿🇦"),
            Country(name: "Нигерия", capital: "Абуджа", population: "218 млн", flag: "🇳🇬")
        ]
        tableView.reloadData()
    }
}

// MARK: - Public Methods
extension MainViewController {
    
    func setupLocalData() {
       
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
    }
    
}
