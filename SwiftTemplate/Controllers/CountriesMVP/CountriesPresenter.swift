//
//  CountriesMVPPresenter.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation

final class CountriesPresenter: BasePresenter<CountriesViewController, Void> {
    
    @Inject private var apiManager: API.Manager
    @Inject private var userManager: UserManager
    @Inject private var databaseManager: DatabaseManagerProtocol
    
    private var countryMockData: [Country] {
        return [
            Country(name: "Ukraine", capital: "Kyiv", population: "41.3M", flag: "🇺🇦"),
            Country(name: "USA", capital: "Washington", population: "331M", flag: "🇺🇸"),
            Country(name: "Germany", capital: "Berlin", population: "83.2M", flag: "🇩🇪"),
            Country(name: "France", capital: "Paris", population: "67.4M", flag: "🇫🇷"),
            Country(name: "Italy", capital: "Rome", population: "59.6M", flag: "🇮🇹"),
            Country(name: "Spain", capital: "Madrid", population: "47.4M", flag: "🇪🇸"),
            Country(name: "United Kingdom", capital: "London", population: "67.8M", flag: "🇬🇧"),
            Country(name: "Canada", capital: "Ottawa", population: "38.2M", flag: "🇨🇦"),
            Country(name: "Australia", capital: "Canberra", population: "25.7M", flag: "🇦🇺"),
            Country(name: "Japan", capital: "Tokyo", population: "125.8M", flag: "🇯🇵"),
            Country(name: "China", capital: "Beijing", population: "1.4B", flag: "🇨🇳"),
            Country(name: "India", capital: "New Delhi", population: "1.38B", flag: "🇮🇳"),
            Country(name: "Brazil", capital: "Brasília", population: "215M", flag: "🇧🇷"),
            Country(name: "Argentina", capital: "Buenos Aires", population: "45.4M", flag: "🇦🇷"),
            Country(name: "Mexico", capital: "Mexico City", population: "128M", flag: "🇲🇽"),
            Country(name: "Turkey", capital: "Ankara", population: "84.8M", flag: "🇹🇷"),
            Country(name: "Egypt", capital: "Cairo", population: "104M", flag: "🇪🇬"),
            Country(name: "South Africa", capital: "Cape Town", population: "60.4M", flag: "🇿🇦"),
            Country(name: "Nigeria", capital: "Abuja", population: "218M", flag: "🇳🇬")
        ]
    }
    
    override func configureController() {
        loadData()
    }
    
}

// MARK: Public
extension CountriesPresenter {
    
    func loadData() {
        let countries = databaseManager.getCountries().sorted{ $0.name < $1.name }
        
        guard countries.isEmpty else {
            vc?.setupData(countries: countries)
            return
        }
        
        databaseManager.saveBatch(countryMockData) { [weak self] error in
            guard let self else { return }
            
            if let error {
                vc?.showErrorToast(error.localizedDescription)
                Logger.default.logMessage("Error saving сountries: \(error)", category: self.className, type: .error)
            } else {
                let savedCountries = self.databaseManager.getCountries().sorted{ $0.name < $1.name }
                vc?.setupData(countries: savedCountries)
            }
        }
    }
    
    func logout(){
        Task {
            await userManager.logout()
            await coordinator.start()
        }
    }
    
}
