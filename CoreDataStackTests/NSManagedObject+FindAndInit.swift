//
//  NSManagedObject+FindAndInit.swift
//  Burgess
//
//  Created by Lukas Schmidt on 26.03.16.
//  Copyright © 2016 Digital Workroom. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func findAndInitialize<T: NSManagedObject>(_ id: String, setup: (T)->()) {
        let fetchRequest = NSFetchRequest(entityName: T.entityName)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.fetchLimit = 1
        if let result = try? self.fetch(fetchRequest), let obj = result.last as? T {
            setup(obj)
        }else {
            let obj: T = self.insertObject()
            setup(obj)
        }
    }
}
