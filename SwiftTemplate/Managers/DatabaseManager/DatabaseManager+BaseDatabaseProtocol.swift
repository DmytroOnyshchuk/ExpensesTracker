//
//  DatabaseManager+BaseDatabaseProtocol.swift
//  HealthTracker
//
//  Created by Bohdan Pokhidnia on 05.07.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import UIKit
import RealmSwift

extension DatabaseManager: BaseDatabaseProtocol {
    
    func saveAsync(_ object: Object, update: Realm.UpdatePolicy?) {
        realm.writeAsync {
            if let update {
                self.realm.add(object, update: update)
            } else {
                self.realm.add(object)
            }
        } onComplete: { error in
            if let error {
                Logger.default.errorLog("Error save object \(object.className)", category: self.className, error: error)
            }
        }
    }
    
    func save(_ object: Object, update: Realm.UpdatePolicy?, completion: CompletionHandler) {
        guard !object.isInvalidated else {
            Logger.default.errorLog("Error save object \(object.className)", category: self.className, error: DBError.isInvalidate)
            completion(.isInvalidate)
            return
        }
        
#if APP
        let bgTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "DatabaseManager.save")
#endif
        
        do {
            try realm.write {
                if let update = update {
                    realm.add(object, update: update)
                } else {
                    realm.add(object)
                }
            }
        } catch {
            Logger.default.errorLog("Error save object \(object.className)", category: self.className, error: error)
            completion(.other(error))
            return
        }
        
#if APP
        if let activity = object as? Activity {
            if activity.inProgress {
                makeScheduleSmartFinishNotification()
            } else {
                notificationScheduler.cancelSmartActivityNotification(activity, type: .finish(0))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                NotificationCenter.default.post(name: .newActivityAddedToDB, object: activity)
            }
        }
#endif
        
        completion(nil)
        
#if APP
        UIApplication.shared.endBackgroundTask(bgTaskIdentifier)
#endif
    }
    
    func save(_ object: Object, completion: @escaping CompletionHandler) {
        save(object, update: nil, completion: completion)
    }
    
    func save(_ object: Object) {
        save(object) { error in }
    }
    
    func saveBatch<T: Object>( _ objects: [T], update: Realm.UpdatePolicy?, completion: @escaping CompletionHandler) {
        guard !objects.isEmpty else {
            completion(nil)
            return
        }
        
        realm.writeAsync( {
            if let update = update {
                self.realm.add(objects, update: update)
            } else {
                self.realm.add(objects)
            }
        }, onComplete: { error in
            if let error = error {
                completion(.other(error))
            } else {
                completion(nil)
            }
        })
    }
    
    func saveBatch<T: Object>( _ objects: [T], completion: @escaping CompletionHandler) {
        saveBatch(objects, update: nil, completion: completion)
    }
    
    func delete(_ object: Object, completion: CompletionHandler) {
        guard !object.isInvalidated else {
            Logger.default.errorLog("Error delete object \(object.className)", category: self.className, error: DBError.isInvalidate)
            completion(.isInvalidate)
            return
        }
        
        do {
            try realm.write {
                realm.delete(object)
                completion(nil)
            }
        } catch {
            Logger.default.errorLog("Error delete object \(object.className)", category: self.className, error: error)
            completion(.other(error))
        }
    }
    
    func deleteBatch<T: Object>( _ objects: [T], completion: CompletionHandler) {
        guard !objects.isEmpty else {
            completion(nil)
            return
        }
        do {
            try realm.write {
                realm.delete(objects)
            }
            completion(nil)
        } catch {
            Logger.default.errorLog("Error delete objects", category: self.className, error: error)
            completion(.other(error))
        }
    }
        
    func drop<T: Object>(_ classType: T.Type) {
        let objects = getObjects(T.self)
        
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            Logger.default.errorLog("Error drop objects: \(classType)", category: self.className, error: error)
        }
    }
    
    func deleteAll(completion: (DBError?) -> Void) {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            Logger.default.errorLog("Error delete all objects", category: self.className, error: error)
            completion(.other(error))
        }
        
        completion(nil)
    }
    
    func getObject<T: Object, K>(_ classType: T.Type, forPrimaryKey: K) -> T? {
        let object = realm.object(ofType: classType, forPrimaryKey: forPrimaryKey)
        
        guard !(object?.isInvalidated ?? false) else {
            Logger.default.errorLog("Error get object \(classType)", category: self.className, error: DBError.isInvalidate)
            return nil
        }
        
        return object
    }
    
    func getObjects<T: RealmFetchable>(_ classType: T.Type) -> [T] {
        let objects = Array(realm.objects(classType))
        
        return objects
    }
    
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: String) -> [T] {
        let objects = realm.objects(classType).filter(filter)
        return Array(objects)
    }
    
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: (Query<T>) -> Query<Bool>) -> [T] {
        return getObjects(T.self, filter: filter, sortDescriptors: [])
    }
    
    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: (Query<T>) -> Query<Bool>, sortDescriptors: [RealmSwift.SortDescriptor] = []) -> [T] {
        let objects = realm.objects(classType)
        let filteredObjects = objects.where(filter).sorted(by: sortDescriptors)
        return Array(filteredObjects)
    }
    
    func write(actionHandler: ActionHandler) {
        write(actionHandler: actionHandler) { error in }
    }
    
    func write(actionHandler: ActionHandler, completion: CompletionHandler) {
        var dbError: DBError?
        
        autoreleasepool {
            do {
                try self.realm.write {
                    actionHandler()
                }
            } catch {
                dbError = .other(error)
                Logger.default.errorLog("Error write transaction", category: self.className, error: error)
            }
        }
        
        completion(dbError)
    }
    
    func create<T: Object>(_ classType: T.Type, value: Any = [:], update: Realm.UpdatePolicy, completion: @escaping CompletionHandler) {
        realm.writeAsync({
            self.realm.create(classType, value: value, update: update)
        }, onComplete: { error in
            if let error = error {
                completion(.other(error))
            } else {
                completion(nil)
            }
        })
    }
    
}
