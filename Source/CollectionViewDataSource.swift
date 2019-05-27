//
//  CollectionViewDataSource.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


open class CollectionViewDataSource<Delegate: CollectionViewDataSourceDelegate, Data: DataProvider, Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {
    
    

    public required init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate, additionalConfigureCellWithObject: ((Data.Object, Cell) -> ())? = nil) {
        self.collectionView = collectionView
        self.dataProvider = dataProvider
        self.delegate = delegate
        self.additionalConfigureCellWithObject = additionalConfigureCellWithObject
        super.init()
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    open var selectedObject: Data.Object? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        return dataProvider.objectAtIndexPath(indexPath)
    }

    open func processUpdates(_ updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates else { return collectionView.reloadData() }
        var shouldUpdate = false
        collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case .insert(let indexPath):
                    self.collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? Cell else {
                        shouldUpdate = true
                        continue
                    }
                    cell.configureForObject(object)
                case .move(let indexPath, let newIndexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.insertItems(at: [newIndexPath])
                case .delete(let indexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                case .insertSection(let sectionIndex):
                    self.collectionView.insertSections(IndexSet(integer: sectionIndex))
                case .deleteSection(let sectionIndex):
                    self.collectionView.deleteSections(IndexSet(integer: sectionIndex))
                }
            }
            }, completion: nil)
        if shouldUpdate {
            self.collectionView.reloadData()
        }
    }


    // MARK: Private

    fileprivate let collectionView: UICollectionView
    fileprivate let dataProvider: Data
    fileprivate weak var delegate: Delegate!
    fileprivate let additionalConfigureCellWithObject: ((Data.Object, Cell) -> ())?


    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.numberOfSections()
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object = dataProvider.objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        additionalConfigureCellWithObject?(object, cell)
        cell.configureForObject(object)
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch(kind) {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: delegate.headerIdentifierForIndexPath(indexPath), for: indexPath) as! Delegate.Header
            delegate.configureHeader(headerView, indexPath: indexPath)
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: delegate.footerIdentifierForIndexPath(indexPath), for: indexPath) as! Delegate.Footer
            delegate.configureFooter(footerView, indexPath: indexPath)
            return footerView
        default:
            return UICollectionReusableView()
        }
    }

}

