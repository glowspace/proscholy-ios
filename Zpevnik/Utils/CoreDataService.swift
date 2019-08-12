//
//  CoreDataService.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

class CoreDataService {
    
    private init() { }
    
    static func getObject<T: NSManagedObject>(id: String, context: NSManagedObjectContext) -> T? {
        if let objects: [T] = fetchData(predicate: NSPredicate(format: "id = %@", id), context: context), objects.count == 1 {
            return objects[0]
        }
        
        return nil
    }
    
    static func createOrGetObject<T: NSManagedObject>(id: String, context: NSManagedObjectContext) -> T? {
        if let object: T = getObject(id: id, context: context) {
            return object
        } else if let entityName = T.entity().name {
            return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T
        }
        
        return nil
    }
    
    static func fetchData<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, context: NSManagedObjectContext) -> [T]? {
        let request = T.fetchRequest()
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request) as? [T]
        } catch {
            return nil
        }
    }
}

class PersistenceService {
    
    private init() { }
    
    static var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Zpevnik")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch { }
        }
    }
}
