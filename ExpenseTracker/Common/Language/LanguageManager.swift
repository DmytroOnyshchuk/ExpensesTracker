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
        if let preferred = Bundle.main.preferredLocalizations.first,
           let language = Language(rawValue: preferred) {
            return language
        }

        var languageCode = Language.English.rawValue
        if let language = Locale.current.language.languageCode {
            languageCode = language.identifier
        }

        return Language(rawValue: languageCode) ?? .English
    }
}
