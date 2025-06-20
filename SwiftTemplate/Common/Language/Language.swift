//
//  Language.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 10.11.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

enum Language: String, Codable {
	
	case English = "en"
	
	func languageDescription() -> String {
		switch self {
			case .English: return "LANGUAGE_ENGLISH_TITLE".localized
		}
	}
	
	func imageNameFlag() -> String {
		switch self {
			case .English: return "ic_uk_flag"
		}
	}
	
}

