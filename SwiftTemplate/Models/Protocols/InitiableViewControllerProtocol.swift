//
//  InitiableViewControllerProtocol.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 11.07.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
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
