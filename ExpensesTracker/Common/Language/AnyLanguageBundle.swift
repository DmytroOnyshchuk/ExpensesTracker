//
//  AnyLanguageBundle.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation

var bundleKey: UInt8 = 0

final class AnyLanguageBundle: Bundle {
	
	override func localizedString(forKey key: String,
								  value: String?,
								  table tableName: String?) -> String {
		
		guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
			  let bundle = Bundle(path: path) else {
			return super.localizedString(forKey: key, value: value, table: tableName)
		}
		
		return bundle.localizedString(forKey: key, value: value, table: tableName)
	}
}

extension Bundle {
	
	class func setCurrentLanguage() {
		guard let code = Bundle.main.preferredLocalizations.first?.components(separatedBy: "-").first else {
			setLanguage(Locale.current.languageCode ?? Language.English.rawValue)
			return
		}
		setLanguage(code)
	}
	
	class func setLanguage(_ language: String) {
		defer {
			object_setClass(Bundle.main, AnyLanguageBundle.self)
		}
		objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}
}
