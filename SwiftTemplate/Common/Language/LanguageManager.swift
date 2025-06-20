//
//  Locale.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 19.12.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

struct LanguageManager {
	
	static func getSystemLanguage() -> Language {
		
		var languageCode = Language.English.rawValue
		
		if #available(iOS 16.0, *) {
			if let language = Locale.current.language.languageCode {
				languageCode = language.identifier
			}
		} else {
			if let language = Locale.current.languageCode {
				languageCode = language
			}
		}
		
		
		return Language(rawValue: languageCode) ?? .English
	}
	
}
