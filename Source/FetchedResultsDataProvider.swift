//
//  FetchedResultsDataProvider.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


public class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate, DataProvider {

    public typealias Object = Delegate.Object

    public init(fetchedResultsController: NSFetchedResultsController, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    public func reconfigureFetchRequest(@noescape block: NSFetchRequest -> ()) {
        NSFetchedResultsController.deleteCacheWithName(fetchedResultsController.cacheName)
        block(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        delegate.dataProviderDidUpdate(nil)
    }

    public func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        guard let result = fetchedResultsController.objectAtIndexPath(indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
        return result
    }

    public func numberOfItemsInSection(section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else { return 0 }
        return sec.numberOfObjects
    }
    
    public func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    public func indexPathForObject(object: Object) -> NSIndexPath? {
        if let object =  object as? AnyObject {
            return fetchedResultsController.indexPathForObject(object)
        }
        return nil
    }


    // MARK: Private

    private let fetchedResultsController: NSFetchedResultsController
    private weak var delegate: Delegate!
    private var updates: [DataProviderUpdate<Object>] = []


    // MARK: NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        updates = []
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.Insert(indexPath))
        case .Update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(indexPath)
            updates.append(.Update(indexPath, object))
        case .Move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.Move(indexPath, newIndexPath))
        case .Delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.Delete(indexPath))
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            updates.append(.InsertSection(sectionIndex))
        case .Update: break
//            let object = objectAtIndexPath(indexPath)
//            updates.append(.Update(indexPath, object))
        case .Move: break
//            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
//            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
//            updates.append(.Move(indexPath, newIndexPath))
        case .Delete:
            updates.append(.DeleteSection(sectionIndex))
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        delegate.dataProviderDidUpdate(updates)
    }

}
