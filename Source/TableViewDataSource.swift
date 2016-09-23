//
//  TableViewDataSource.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import UIKit


open class TableViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UITableViewCell>: NSObject, UITableViewDataSource where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object {
    
    public required init(tableView: UITableView, dataProvider: Data, delegate: Delegate, additionalConfigureCellWithObject: ((Data.Object, Cell) -> ())? = nil) {
        self.tableView = tableView
        self.dataProvider = dataProvider
        self.delegate = delegate
        self.additionalConfigureCellWithObject = additionalConfigureCellWithObject
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }

    open var selectedObject: Data.Object? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        return dataProvider.objectAtIndexPath(indexPath)
    }

    open func processUpdates(_ updates: [DataProviderUpdate<Data.Object>]?) {
        guard let updates = updates else { return tableView.reloadData() }
        tableView.beginUpdates()
        for update in updates {
            switch update {
            case .insert(let indexPath):
                tableView.insertRows(at: [indexPath], with: .fade)
                
            case .update(let indexPath, let object):
                guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
                cell.configureForObject(object)
            case .move(let indexPath, let newIndexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            case .delete(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
            case .insertSection(let sectionIndex):
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .deleteSection(let sectionIndex):
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            }
        }
        tableView.endUpdates()
    }


    // MARK: Private

    fileprivate let tableView: UITableView
    fileprivate let dataProvider: Data
    fileprivate weak var delegate: Delegate!
    fileprivate let additionalConfigureCellWithObject: ((Data.Object, Cell) -> ())?


    // MARK: UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections()
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItemsInSection(section)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = dataProvider.objectAtIndexPath(indexPath)
        let identifier = delegate.cellIdentifierForObject(object)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell
            else { fatalError("Unexpected cell type at \(indexPath)") }
        additionalConfigureCellWithObject?(object, cell)
        cell.configureForObject(object)
        
        return cell
    }

}

