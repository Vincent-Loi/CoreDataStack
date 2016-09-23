//
//  DataSource.swift
//  Moody
//
//  Created by Florian on 31/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//


public protocol DataSourceCellConfiguratorDelegate {
    associatedtype Object
    associatedtype Cell
    func configureCellWithObject(_ object: Object, cell: Cell) -> Cell
}

public protocol DataSourceDelegate: class {
    associatedtype Object
    func cellIdentifierForObject(_ object: Object) -> String
}

public protocol CollectionViewDataSourceDelegate: DataSourceDelegate {
    associatedtype Header: UICollectionReusableView
    associatedtype Footer: UICollectionReusableView
    
    func headerIdentifierForIndexPath(_ indexPath: IndexPath) -> String
    func configureHeader(_ header: Header, indexPath: IndexPath)
    
    func footerIdentifierForIndexPath(_ indexPath: IndexPath) -> String
    func configureFooter(_ header: Footer, indexPath: IndexPath)
}

