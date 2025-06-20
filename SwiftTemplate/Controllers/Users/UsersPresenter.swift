//
//  MainPresenter.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation

final class UsersPresenter: BasePresenter<UsersViewController, Void> {
    
    @Inject private var apiManager: API.Manager
    
    override func configureController() {
        loadData()
    }
    
}

// MARK: Public
extension UsersPresenter {
    
    func loadData() {
        vc?.showLoadingIndicator()
        
        apiManager.request(type: API.Request.UsersRequest())
            .done { (response: [User]) in
                self.vc?.setupData(users: response)
            }
            .ensure {
                self.vc?.hideLoadingIndicator()
            }
            .catch {
                self.vc?.showError(error: $0)
            }
    }
    
}
