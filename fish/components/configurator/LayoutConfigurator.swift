//
//  LayoutConfigurator.swift
//  fish
//
//  Created by Michael Ong on 9/12/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

/**
 Contract for setting a layout definition to an instance.
 */
public protocol LayoutConfigurator {
    associatedtype Constraint
    associatedtype Output
    
    func apply(_ target: Constraint) -> [Output]
}
