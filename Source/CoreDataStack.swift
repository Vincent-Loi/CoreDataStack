//
//  CoreDataStack.swift
//  Medications
//
//  Created by Lukas Schmidt on 10.08.15.
//  Copyright © 2015 Lukas Schmidt. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataStack: NSObject {
    let modelName: String
    let bundle: Bundle
    let options: Dictionary<String, Any>?
    
    public init(modelName: String, bundle: Bundle, options: Dictionary<String, Any>? = nil) {
        self.bundle = bundle
        self.modelName = modelName
        self.options = options
    }
    
    open func createMainContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = createCoordinator()
        return context
    }
    
    fileprivate func createCoordinator() -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: model())
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
            configurationName: nil, at: storeURL(), options: options)
        return coordinator
    }
    
    fileprivate func storeURL() -> URL {
        let fm = FileManager.default
        let documentDirURL = try! fm.url(for: .documentDirectory,
            in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirURL
            .appendingPathComponent(modelName)
            .appendingPathExtension("sqlite")
    }
    
    fileprivate func model() -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: modelName,
            withExtension: "momd")
            else {
                fatalError("Managed object model not found")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Could not load managed object model from \(modelURL)")
        }
        return model
    }
}
