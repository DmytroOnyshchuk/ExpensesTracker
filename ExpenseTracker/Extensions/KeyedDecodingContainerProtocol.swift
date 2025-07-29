//
//  KeyedDecodingContainerProtocol.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 19.02.2021.
//  Copyright © 2021 PeaksCircle. All rights reserved.
//

import Foundation

extension KeyedDecodingContainerProtocol{

    func getValueFromAvailableKey(codingKeys:[CodingKey])-> Any?{
        for key in codingKeys{
            for keyPath in self.allKeys{
                if key.stringValue == keyPath.stringValue{
                    do{
                        if let value = try? self.decodeIfPresent([String].self, forKey:keyPath){
                            return value
                        }

                        if let value = try? self.decodeIfPresent([String:String].self, forKey:keyPath){
                            return value
                        }

                        if let value = try? self.decodeIfPresent([[String:String]].self, forKey:keyPath){
                            return value
                        }

                        if let value = try? self.decodeIfPresent(String.self, forKey:keyPath){
                            return value
                        }

                        return nil
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - Property
struct Property: Codable {
    var customKey:[String:Any] = [:]
    
    init(customKey: [String : Any]) {
        self.customKey = customKey
    }

    init(from decoder: Decoder)  {
        do{
            let container = try decoder.container(keyedBy: CustomCodingKeys.self)
            for key in container.allKeys{
                customKey[key.stringValue] = container.getValueFromAvailableKey(codingKeys: [CustomCodingKeys.init(stringValue: key.stringValue)!])
            }

        }catch{
            print(error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        for key in customKey{
                 try? container.encodeIfPresent(customKey[key.key] as? String, forKey: CustomCodingKeys.init(stringValue: key.key)!)
                 try? container.encodeIfPresent(customKey[key.key] as? [[String:String]], forKey: CustomCodingKeys.init(stringValue: key.key)!)
                 try? container.encodeIfPresent(customKey[key.key] as? [String:String], forKey: CustomCodingKeys.init(stringValue: key.key)!)
            }

    }
}

struct CustomCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}
