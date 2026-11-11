//
//  LanguageManager.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum LanguageManager {
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
