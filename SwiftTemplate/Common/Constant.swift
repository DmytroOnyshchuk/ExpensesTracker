//
//  Constant.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 21.10.2021.
//  Copyright © 2021 PeaksCircle. All rights reserved.
//

import Foundation

struct Constants {
    
    static var groupIdentifier: String {
#if PROD
        return "group.com.dmytroon.template.ios"
#else
        return "group.com.dmytroon.template.dev"
#endif
    }
    
    static let testId: String = "testId"
    
    
    static let countryMockData: [Country] = [
        Country(name: "Ukraine", capital: "Kyiv", population: "41.3M", flag: "🇺🇦"),
        Country(name: "USA", capital: "Washington", population: "331M", flag: "🇺🇸"),
        Country(name: "Germany", capital: "Berlin", population: "83.2M", flag: "🇩🇪"),
        Country(name: "France", capital: "Paris", population: "67.4M", flag: "🇫🇷"),
        Country(name: "Italy", capital: "Rome", population: "59.6M", flag: "🇮🇹"),
        Country(name: "Spain", capital: "Madrid", population: "47.4M", flag: "🇪🇸"),
        Country(name: "United Kingdom", capital: "London", population: "67.8M", flag: "🇬🇧"),
        Country(name: "Canada", capital: "Ottawa", population: "38.2M", flag: "🇨🇦"),
        Country(name: "Australia", capital: "Canberra", population: "25.7M", flag: "🇦🇺"),
        Country(name: "Japan", capital: "Tokyo", population: "125.8M", flag: "🇯🇵"),
        Country(name: "China", capital: "Beijing", population: "1.4B", flag: "🇨🇳"),
        Country(name: "India", capital: "New Delhi", population: "1.38B", flag: "🇮🇳"),
        Country(name: "Brazil", capital: "Brasília", population: "215M", flag: "🇧🇷"),
        Country(name: "Argentina", capital: "Buenos Aires", population: "45.4M", flag: "🇦🇷"),
        Country(name: "Mexico", capital: "Mexico City", population: "128M", flag: "🇲🇽"),
        Country(name: "Turkey", capital: "Ankara", population: "84.8M", flag: "🇹🇷"),
        Country(name: "Egypt", capital: "Cairo", population: "104M", flag: "🇪🇬"),
        Country(name: "South Africa", capital: "Cape Town", population: "60.4M", flag: "🇿🇦"),
        Country(name: "Nigeria", capital: "Abuja", population: "218M", flag: "🇳🇬")
    ]
    
}
