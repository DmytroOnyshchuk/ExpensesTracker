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
        return JSONDecoder.withConvertFromSnakeCase
    }
    
    static func build(_ config: (JSONDecoder) -> ()) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        config(jsonDecoder)
        return jsonDecoder
    }
    
    func build(_ config: (JSONDecoder) -> ()) -> JSONDecoder {
        config(self)
        return self
    }
    
    static var withConvertFromSnakeCase: JSONDecoder {
        return JSONDecoder.build { $0.keyDecodingStrategy = .convertFromSnakeCase }
    }
    
    static func withDateFormat(_ dateFormat: String) -> JSONDecoder {
        return JSONDecoder.build {
            $0.dateDecodingStrategy = .formatted(DateFormatter().config { $0.dateFormat = dateFormat })
        }
    }
    
    var convertFromSnakeCase: JSONDecoder {
        return self.build { $0.keyDecodingStrategy = .convertFromSnakeCase }
    }
    
    func withDateFormat(_ dateFormat: String) -> JSONDecoder {
        return self.build {
            $0.dateDecodingStrategy = .formatted(DateFormatter().config { $0.dateFormat = dateFormat })
        }
    }
    
}
