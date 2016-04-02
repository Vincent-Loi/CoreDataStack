//
//  CoreDataStackTests.swift
//  CoreDataStackTests
//
//  Created by Lukas Schmidt on 26.03.16.
//  Copyright © 2016 Lukas Schmidt. All rights reserved.
//

import XCTest
import UIKit
import CoreData
@testable import CoreDataStack

extension CoreDataStackTests: DataProviderDelegate, CollectionViewDataSourceDelegate {
    typealias Object = CDTrain
    
    func dataProviderDidUpdate(updates: [DataProviderUpdate<Object>]?) {
       dataSource.processUpdates(updates)
    }
    
    func cellIdentifierForObject(object: Object) -> String {
        return "yachtCell"
    }
    
    //MARK: CollectionViewDataSoruceDelegate
    typealias Header = UICollectionReusableView
    typealias Footer = UICollectionReusableView
    
    func headerIdentifierForIndexPath(indexPath: NSIndexPath) -> String { return "" }
    
    func configureHeader(header: Header, indexPath: NSIndexPath) { }
    
    func footerIdentifierForIndexPath(indexPath: NSIndexPath) -> String { return "" }
    
    func configureFooter(header: Footer, indexPath: NSIndexPath) { }
}

class TrainItemCell: UICollectionViewCell, ConfigurableCell {
    typealias DataSource = CDTrain
    func configureForObject(object: DataSource) {
        
    }
}

class CoreDataStackTests: XCTestCase {
    func managedObjectContextForTesting() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        let model = NSManagedObjectModel.mergedModelFromBundles(NSBundle.allBundles())
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        do {
            try context.persistentStoreCoordinator?.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        }
        catch  {
            
        }
        
        
        return context
    }
    
    var managedObjectContext: NSManagedObjectContext {
        if CoreDataStackTests.managedObjectContextInstance == nil {
            CoreDataStackTests.managedObjectContextInstance = managedObjectContextForTesting()
        }
        return CoreDataStackTests.managedObjectContextInstance
    }
    private static var managedObjectContextInstance: NSManagedObjectContext!
    
    var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewFlowLayout())
    
    var dataProvider: FetchedResultsDataProvider<CoreDataStackTests>!
    var dataSource: CollectionViewDataSource<CoreDataStackTests, FetchedResultsDataProvider<CoreDataStackTests>, TrainItemCell>!
    
    override func setUp() {
        super.setUp()
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedObjectContext)
        dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
        dataSource = CollectionViewDataSource(collectionView: collectionView, dataProvider: dataProvider, delegate: self)
        self.collectionView.registerNib(UINib(nibName: "TrainItemCell", bundle: NSBundle(forClass: CoreDataStackTests.self)), forCellWithReuseIdentifier: "yachtCell")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        func initt(train: CDTrain) {
            train.name = "ICE"
            train.id = "id1"
        } 
        func update(train: CDTrain) {
            train.name = "ICE T"
            train.id = "id1"
        }
        func update2(train: CDTrain) {
            train.name = "ICE 4"
            train.id = "id2"
        }
        XCTAssertEqual(collectionView.numberOfItemsInSection(0), 0)
        managedObjectContext.findAndInitialize("id1", setup: initt)
//        try! managedObjectContext.save()
//        XCTAssertEqual(collectionView.numberOfItemsInSection(0), 1)
        managedObjectContext.findAndInitialize("id1", setup: update)
         managedObjectContext.findAndInitialize("id1", setup: update)
         managedObjectContext.findAndInitialize("id1", setup: update)
        
        try! managedObjectContext.save()
        XCTAssertEqual(collectionView.numberOfItemsInSection(0), 1)
        managedObjectContext.findAndInitialize("id2", setup: update2)
        
        try! managedObjectContext.save()
        XCTAssertEqual(collectionView.numberOfItemsInSection(0), 2)
        
        //waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func fetchRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: CDTrain.entityName)
        request.sortDescriptors = []
        
        return request
    }
    
}
