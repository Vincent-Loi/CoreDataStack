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
    var managedObjectContext: NSManagedObjectContext! {
        get {
            return nil
        }
        
        set(value) {
            passManagedObjectContextToChildren(value)
        }
    }
    private func passManagedObjectContextToChildren(managedObjectContext:NSManagedObjectContext) {
        for (_, controller) in childViewControllers.enumerate(){
            if let controller = controller as? ManagedObjectContextSettable {
                controller.managedObjectContext = managedObjectContext
            }
        }
    }
}