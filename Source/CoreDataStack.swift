//
//  CoreDataStack.swift
//  Medications
//
//  Created by Lukas Schmidt on 10.08.15.
//  Copyright © 2015 Lukas Schmidt. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStack: NSObject {
    let modelName: String
    let bundle: NSBundle
    
    init(modelName: String, bundle: NSBundle) {
        self.bundle = bundle
        self.modelName = modelName
    }
    
    public func createMainContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(
            concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = createCoordinator()
        return context
    }
    
    private func createCoordinator() -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: model())
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: storeURL(), options: nil)
        return coordinator
    }
    
    private func storeURL() -> NSURL {
        let fm = NSFileManager.defaultManager()
        let documentDirURL = try! fm.URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        return documentDirURL
            .URLByAppendingPathComponent(modelName)
            .URLByAppendingPathExtension("sqlite")
    }
    
    private func model() -> NSManagedObjectModel {
        guard let modelURL = bundle.URLForResource(modelName,
            withExtension: "momd")
            else {
                fatalError("Managed object model not found")
        }
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL)
            else {
                fatalError("Could not load managed object model from \(modelURL)")
        }
        return model
    }
}
