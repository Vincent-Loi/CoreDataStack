//
//  ManagedObjectContextSettable.swift
//  Medications
//
//  Created by Lukas Schmidt on 10.08.15.
//  Copyright © 2015 Lukas Schmidt. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectContextSettable: class {
    var managedObjectContext: NSManagedObjectContext! { get set }
}
