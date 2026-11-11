//
//  Language.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum Language: String, Codable {
    case English = "en"

    func languageDescription() -> String {
        switch self {
        case .English: "LANGUAGE_ENGLISH_TITLE".localized
        }
    }

    func imageNameFlag() -> String {
        switch self {
        case .English: "ic_uk_flag"
        }
    }
}
