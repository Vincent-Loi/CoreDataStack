//
//  ConfigurableCell.swift
//  Moody
//
//  Created by Florian on 28/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//


public protocol ConfigurableCell {
    associatedtype DataSource
    func configureForObject(_ object: DataSource)
}
