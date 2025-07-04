//
//  Country.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit
import RealmSwift

final class Country: Object, Codable {
    
    @objc dynamic var uuid: UUID = UUID()
    @objc dynamic var name: String = String()
    @objc dynamic var capital: String = String()
    @objc dynamic var population: String = String()
    @objc dynamic var flag: String = String()

    public override static func primaryKey() -> String? {
        return "uuid"
    }
    
    override init() {
    }
    
    internal init(name: String, capital: String, population: String, flag: String) {
        self.name = name
        self.capital = capital
        self.population = population
        self.flag = flag
    }

}
