//
//  JSONDecoder.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 27.11.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static var appDefault: JSONDecoder {
        JSONDecoder.withConvertFromSnakeCase
    }

    static func build(_ config: (JSONDecoder) -> Void) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        config(jsonDecoder)
        return jsonDecoder
    }

    func build(_ config: (JSONDecoder) -> Void) -> JSONDecoder {
        config(self)
        return self
    }

    static var withConvertFromSnakeCase: JSONDecoder {
        JSONDecoder.build { $0.keyDecodingStrategy = .convertFromSnakeCase }
    }

    static func withDateFormat(_ dateFormat: String) -> JSONDecoder {
        JSONDecoder.build {
            $0.dateDecodingStrategy = .formatted(DateFormatter().config { $0.dateFormat = dateFormat })
        }
    }

    var convertFromSnakeCase: JSONDecoder {
        build { $0.keyDecodingStrategy = .convertFromSnakeCase }
    }

    func withDateFormat(_ dateFormat: String) -> JSONDecoder {
        build {
            $0.dateDecodingStrategy = .formatted(DateFormatter().config { $0.dateFormat = dateFormat })
        }
    }
}
