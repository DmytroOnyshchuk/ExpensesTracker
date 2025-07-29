//
//  DatabaseManagerProtocol.swift
//  HealthTracker
//
//  Created by Bohdan Pokhidnia on 05.07.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import UIKit
import RealmSwift

typealias DatabaseManagerProtocol = BaseDatabaseProtocol & CountriesDatabaseProtocol

protocol BaseDatabaseProtocol {
    func saveAsync(_ object: Object, update: Realm.UpdatePolicy?)
    func save(_ object: Object, update: Realm.UpdatePolicy?, completion: @escaping DatabaseManager.CompletionHandler)
    func save(_ object: Object, completion: @escaping DatabaseManager.CompletionHandler)
	func save(_ object: Object)
    func saveBatch( _ objects: [Object], update: Realm.UpdatePolicy?, completion: @escaping DatabaseManager.CompletionHandler )
    func saveBatch( _ objects: [Object], completion: @escaping DatabaseManager.CompletionHandler )
    
    func delete(_ object: Object, completion: DatabaseManager.CompletionHandler)
    func deleteBatch( _ objects: [Object], completion: DatabaseManager.CompletionHandler )
    func drop<T: Object>(_ classType: T.Type)
    func deleteAll(completion: DatabaseManager.CompletionHandler)
    
    func getObject<T: Object, K>(_ classType: T.Type, forPrimaryKey: K) -> T?
    func getObjects<T: RealmFetchable>(_ classType: T.Type) -> [T]
    @available(*, deprecated, message: "Please use Query<Bool> filter")
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: String) -> [T]
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: (Query<T>) -> Query<Bool>) -> [T]
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: (Query<T>) -> Query<Bool>, sortDescriptors: [RealmSwift.SortDescriptor]) -> [T]
    
    func write(actionHandler: DatabaseManager.ActionHandler, completion: DatabaseManager.CompletionHandler)
	func write(actionHandler: DatabaseManager.ActionHandler)
    func create<T: Object>(_ classType: T.Type, value: Any, update: Realm.UpdatePolicy, completion: @escaping DatabaseManager.CompletionHandler)
}

protocol CountriesDatabaseProtocol {
    
}
