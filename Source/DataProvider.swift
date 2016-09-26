//
//  DataProvider.swift
//  Moody
//
//  Created by Florian on 08/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData

public protocol DataProvider: class {
    associatedtype Object
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object
    func numberOfItemsInSection(_ section: Int) -> Int
    func numberOfSections() -> Int
    
    func indexPathForObject(_ object: Object) -> IndexPath?
}


public protocol DataProviderDelegate: class {
    associatedtype Object: NSManagedObject 
    func dataProviderDidUpdate(_ updates: [DataProviderUpdate<Object>]?)
}


public  enum DataProviderUpdate<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
    
    case insertSection(Int)
    case deleteSection(Int)
}

