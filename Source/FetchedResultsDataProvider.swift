//
//  FetchedResultsDataProvider.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData

open class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate, DataProvider where Delegate.Object == NSManagedObject {

    public typealias Object = Delegate.Object

    public init(fetchedResultsController: NSFetchedResultsController<Object>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    open func reconfigureFetchRequest(_ block: (NSFetchRequest<Object>) -> ()) {
        NSFetchedResultsController<Object>.deleteCache(withName: fetchedResultsController.cacheName)
        block(fetchedResultsController.fetchRequest)
        do { try fetchedResultsController.performFetch() } catch { fatalError("fetch request failed") }
        delegate.dataProviderDidUpdate(nil)
    }

    open func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath)
    }

    open func numberOfItemsInSection(_ section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sec.numberOfObjects
    }
    
    open func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    open func indexPathForObject(_ object: Object) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }


    // MARK: Private

    fileprivate let fetchedResultsController: NSFetchedResultsController<Object>
    fileprivate weak var delegate: Delegate!
    fileprivate var updates: [DataProviderUpdate<Object>] = []


    // MARK: NSFetchedResultsControllerDelegate

    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }

    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(indexPath))
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(indexPath)
            updates.append(.update(indexPath, object))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
        }
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            updates.append(.insertSection(sectionIndex))
        case .update: break
//            let object = objectAtIndexPath(indexPath)
//            updates.append(.Update(indexPath, object))
        case .move: break
//            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
//            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
//            updates.append(.Move(indexPath, newIndexPath))
        case .delete:
            updates.append(.deleteSection(sectionIndex))
        }
    }

    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.dataProviderDidUpdate(updates)
    }
    
    

}
