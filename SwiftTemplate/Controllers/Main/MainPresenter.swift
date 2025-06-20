//
//  MainPresenter.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 13.06.2025.
//

import Foundation

final class MainPresenter: BasePresenter<MainViewController, Void> {
    
    @Inject private var apiManager: API.Manager
    @Inject private var userManager: UserManager
    @Inject private var databaseManager: DatabaseManagerProtocol
    
    override func configureController() {
        loadData()
    }
    
}

// MARK: Public
extension MainPresenter {
    
    func loadData() {
        let countries = databaseManager.getObjects(Country.self)
        
        guard countries.isEmpty else {
            vc?.setupData(countries: countries)
            return
        }
        
        databaseManager.saveBatch(Constants.countryMockData) { [weak self] error in
            guard let self else { return }
            
            if let error {
                vc?.showErrorToast(error.localizedDescription)
                Logger.default.logMessage("Error saving сountries: \(error)", category: self.className, type: .error)
            } else {
                let savedCountries = self.databaseManager.getObjects(Country.self)
                vc?.setupData(countries: savedCountries)
            }
        }
    }
    
}
