//
//  PropertyConfigurator.swift
//  fish
//
//  Created by Michael Ong on 9/12/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

/**
 Contract for setting a property to an instance.
 */
public protocol PropertyConfigurator {
    associatedtype Constraint
    
    func apply(_ target: Constraint)
}
