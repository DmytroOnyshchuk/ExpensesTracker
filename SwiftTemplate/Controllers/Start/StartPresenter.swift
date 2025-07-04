//
//  StartPresneter.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

final class StartPresenter: BasePresenter<StartViewController, Void> {
    
    @Inject private var apiManager: API.Manager
    @Inject private var userManager: UserManager
    @Inject private var databaseManager: DatabaseManagerProtocol
    
    override func configureController() {
    }
    
}

// MARK: Public
extension StartPresenter {
    
}
