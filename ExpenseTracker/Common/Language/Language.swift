//
//  Language.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum Language: String, Codable, CaseIterable {
    case English = "en"
    case Afrikaans = "af"
    case Amharic = "am"
    case Arabic = "ar"
    case Azerbaijani = "az"
    case Belarusian = "be"
    case Bulgarian = "bg"
    case Bengali = "bn"
    case Catalan = "ca"
    case Czech = "cs"
    case Danish = "da"
    case German = "de"
    case Greek = "el"
    case Spanish = "es"
    case Estonian = "et"
    case Basque = "eu"
    case Persian = "fa"
    case Finnish = "fi"
    case Filipino = "fil"
    case French = "fr"
    case Galician = "gl"
    case Gujarati = "gu"
    case Hindi = "hi"
    case Croatian = "hr"
    case Hungarian = "hu"
    case Armenian = "hy"
    case Indonesian = "id"
    case Icelandic = "is"
    case Italian = "it"
    case Hebrew = "he"
    case Japanese = "ja"
    case Georgian = "ka"
    case Kazakh = "kk"
    case Khmer = "km"
    case Kannada = "kn"
    case Korean = "ko"
    case Kyrgyz = "ky"
    case Luxembourgish = "lb"
    case Lao = "lo"
    case Lithuanian = "lt"
    case Latvian = "lv"
    case Macedonian = "mk"
    case Malayalam = "ml"
    case Mongolian = "mn"
    case Marathi = "mr"
    case Malay = "ms"
    case Burmese = "my"
    case Norwegian = "nb"
    case Nepali = "ne"
    case Dutch = "nl"
    case Punjabi = "pa"
    case Polish = "pl"
    case Portuguese = "pt-BR"
    case Romansh = "rm"
    case Romanian = "ro"
    case Russian = "ru"
    case Sinhala = "si"
    case Slovak = "sk"
    case Slovenian = "sl"
    case Albanian = "sq"
    case Serbian = "sr"
    case Swedish = "sv"
    case Swahili = "sw"
    case Tamil = "ta"
    case Telugu = "te"
    case Thai = "th"
    case Turkmen = "tk"
    case Turkish = "tr"
    case Ukrainian = "uk"
    case Urdu = "ur"
    case Uzbek = "uz"
    case Vietnamese = "vi"
    case ChineseSimplified = "zh-Hans"
    case ChineseTraditional = "zh-Hant"
    case Zulu = "zu"
    
    func languageDescription() -> String {
        let name = Locale(identifier: rawValue).localizedString(forIdentifier: rawValue) ?? rawValue
        return name.prefix(1).uppercased() + name.dropFirst()
    }

    func imageNameFlag() -> String {
        switch self {
        case .English: "ic_uk_flag"
        default: "ic_\(rawValue)_flag"
        }
    }
}
