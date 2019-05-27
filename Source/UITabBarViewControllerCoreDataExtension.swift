//
//  UITabBarViewControllerCoreDataExtension.swift
//  Medications
//
//  Created by Lukas Schmidt on 10.08.15.
//  Copyright © 2015 Lukas Schmidt. All rights reserved.
//

import UIKit
import CoreData

extension UITabBarController: ManagedObjectContextSettable {
    public var managedObjectContext: NSManagedObjectContext! {
        get {
            return nil
        }
        
        set(value) {
            passManagedObjectContextToChildren(value)
        }
    }
    fileprivate func passManagedObjectContextToChildren(_ managedObjectContext:NSManagedObjectContext) {
        for (_, controller) in children.enumerated(){
            if let controller = controller as? ManagedObjectContextSettable {
                controller.managedObjectContext = managedObjectContext
            }
        }
    }
}
