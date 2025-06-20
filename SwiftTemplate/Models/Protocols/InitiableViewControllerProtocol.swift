//
//  InitiableResource.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import UIKit

enum InitiableResource {
	case storyboard(storyboard: UIStoryboard)
	case xib
	case manual
	case none
}

protocol InitiableViewControllerProtocol where Self: UIViewController {
	
	static var initiableResource: InitiableResource { get }
	
}

extension InitiableViewControllerProtocol {
	
	static var newInstance: Self? {
		switch Self.initiableResource {
			case .storyboard(let storyboard): return storyboard.instantiateViewController(withIdentifier: name) as? Self
			case .xib: return Self.init(nibName: name, bundle: nil)
			case .manual: return Self.init(nibName: nil, bundle: nil)
			case .none: return nil
		}
	}
	
}
