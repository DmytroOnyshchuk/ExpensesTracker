//
//  Codable.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

extension Encodable {
    func jsonData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Decodable {
    init?(jsonData: Data?) {
        guard let jsonData, let value = try? JSONDecoder().decode(Self.self, from: jsonData) else { return nil }
        self = value
    }
}
