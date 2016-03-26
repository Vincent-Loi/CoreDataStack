//
//  NSFetchedResultsController+Extensions.swift
//  Medications
//
//  Created by Lukas Schmidt on 27.01.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//

import CoreData

public extension NSFetchedResultsController {
    convenience init(fetchRequest: NSFetchRequest, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: String? = nil, cacheNameDefault: String? = nil) {
        self.init(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }
}