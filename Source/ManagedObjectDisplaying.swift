//
//  ManagedObjectDisplayingController.swift
//  Medications
//
//  Created by Lukas Schmidt on 09.03.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagedObjectDisplaying {
    associatedtype Displayable: NSManagedObject
    
    var displayingObject: Displayable! { get set }
    var observer: GenericObserver<Displayable>! { get }
    
    func didChangeObject(changeType: ManagedObjectObserver.ChangeType, object: Displayable)
}

public final class GenericObserver<Obsavable: NSManagedObject> {
    let observer: ManagedObjectObserver?
    public init?(object: Obsavable, changeHandler: (ManagedObjectObserver.ChangeType, object: Obsavable) -> ()) {
        let observer = ManagedObjectObserver(object: object, changeHandler: {changeType in
            changeHandler(changeType, object: object)
        })
        self.observer = observer
    }
}

