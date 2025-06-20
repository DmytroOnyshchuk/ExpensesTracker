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
    
}

extension MainPresenter {
    
    func reloadInvoices() {
        
    }
    
}
