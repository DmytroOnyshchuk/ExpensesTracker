//
//  BasePresenterProtocol.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit

protocol BasePresenterProtocol {
	func viewDidLoad()
	func runtimeConfigureUI(_ animated: Bool)
	func viewDidAppear(_ animated: Bool)
	func viewWillDisappear(_ animated: Bool)
	func setParameters(_ parameters: Any?)
}

class BasePresenter<T: BaseViewController, P>: NSObject {
	
    @Inject var coordinator: AppCoordinator
	private(set) weak var vc: T?
	var p: P?
	var navigationController: UINavigationController? { return vc?.navigationController }
	
	init(controller: T?) {
		super.init()
		self.vc = controller
		self.p = controller?.parameters as? P
	}
	
	init(controller: T?, parameters: P?) {
		super.init()
		self.vc = controller
		self.p = parameters
	}
	
	func configureController() {
		
	}
    
    func runtimeConfigureUI(_ animated: Bool) {
        
    }
	
	func controllerDidAppear(_ animated: Bool) {
		
	}
	
	func controllerWillDisappear(_ animated: Bool) {
		
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
}

extension BasePresenter: BasePresenterProtocol {
    
    func setParameters(_ parameters: Any?) {
        p = parameters as? P
    }
    
    func viewDidLoad() {
        configureController()
    }
    
    func viewWillAppear(_ animated: Bool) {
        runtimeConfigureUI(animated)
    }
    
    func viewDidAppear(_ animated: Bool) {
        controllerDidAppear(animated)
    }
    
    func viewWillDisappear(_ animated: Bool) {
        controllerWillDisappear(animated)
    }
    
}
