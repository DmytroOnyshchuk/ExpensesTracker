//
//  DatabaseManager+BaseDatabaseProtocol.swift
//  HealthTracker
//
//  Created by Bohdan Pokhidnia on 05.07.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import RealmSwift
import UIKit

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
                Logger.default.logError("Error save object \(object.className)", error: error, category: self.className)
            }
        }
    }

    func save(_ object: Object, update: Realm.UpdatePolicy?, completion: CompletionHandler) {
        guard !object.isInvalidated else {
            Logger.default.logError("Error save object \(object.className)", error: DBError.isInvalidate, category: className)
            completion(.isInvalidate)
            return
        }

        #if APP
        let bgTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "DatabaseManager.save")
        #endif

        do {
            try realm.write {
                if let update {
                    realm.add(object, update: update)
                } else {
                    realm.add(object)
                }
            }
        } catch {
            Logger.default.logError("Error save object \(object.className)", error: error, category: className)
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
        save(object) { _ in }
    }

    func saveBatch<T: Object>(_ objects: [T], update: Realm.UpdatePolicy?, completion: @escaping CompletionHandler) {
        guard !objects.isEmpty else {
            completion(nil)
            return
        }

        realm.writeAsync {
            if let update {
                self.realm.add(objects, update: update)
            } else {
                self.realm.add(objects)
            }
        } onComplete: { error in
            if let error {
                completion(.other(error))
            } else {
                completion(nil)
            }
        }
    }

    func saveBatch<T: Object>(_ objects: [T], completion: @escaping CompletionHandler) {
        saveBatch(objects, update: nil, completion: completion)
    }

    func delete(_ object: Object, completion: CompletionHandler) {
        guard !object.isInvalidated else {
            Logger.default.logError("Error delete object \(object.className)", error: DBError.isInvalidate, category: className)
            completion(.isInvalidate)
            return
        }

        do {
            try realm.write {
                realm.delete(object)
                completion(nil)
            }
        } catch {
            Logger.default.logError("Error delete object \(object.className)", error: error, category: className)
            completion(.other(error))
        }
    }

    func deleteBatch<T: Object>(_ objects: [T], completion: CompletionHandler) {
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
            Logger.default.logError("Error delete objects", error: error, category: className)
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
            Logger.default.logError("Error drop objects: \(classType)", error: error, category: className)
        }
    }

    func deleteAll(completion: (DBError?) -> Void) {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            Logger.default.logError("Error delete all objects", error: error, category: className)
            completion(.other(error))
        }

        completion(nil)
    }

    func getObject<T: Object, K>(_ classType: T.Type, forPrimaryKey: K) -> T? {
        let object = realm.object(ofType: classType, forPrimaryKey: forPrimaryKey)

        guard !(object?.isInvalidated ?? false) else {
            Logger.default.logError("Error get object \(classType)", error: DBError.isInvalidate, category: className)
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

    func getObjects<T: RealmFetchable>(_: T.Type, filter: (Query<T>) -> Query<Bool>) -> [T] {
        getObjects(T.self, filter: filter, sortDescriptors: [])
    }

    func getObjects<T: RealmFetchable>(_ classType: T.Type, filter: (Query<T>) -> Query<Bool>, sortDescriptors: [RealmSwift.SortDescriptor] = []) -> [T] {
        let objects = realm.objects(classType)
        let filteredObjects = objects.where(filter).sorted(by: sortDescriptors)
        return Array(filteredObjects)
    }

    func write(actionHandler: ActionHandler) {
        write(actionHandler: actionHandler) { _ in }
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
                Logger.default.logError("Error write transaction", error: error, category: self.className)
            }
        }

        completion(dbError)
    }

    func create<T: Object>(_ classType: T.Type, value: Any = [:], update: Realm.UpdatePolicy, completion: @escaping CompletionHandler) {
        realm.writeAsync {
            self.realm.create(classType, value: value, update: update)
        } onComplete: { error in
            if let error {
                completion(.other(error))
            } else {
                completion(nil)
            }
        }
    }
}
