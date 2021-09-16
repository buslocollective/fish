//
//  LayoutItem.swift
//  fish
//
//  Created by Michael Ong on 9/14/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit

/**
 Construct that wraps a specialized ``LayoutConfigurator`` instance to participate in defining multiple disparate instance types.
 */
public struct LayoutItem<Target>: LayoutConfigurator {
    public typealias Constraint = Target
    public typealias Output = NSLayoutConstraint
    
    let block: (Constraint) -> [Output]
    
    public func apply(_ target: Constraint) -> [Output] {
        block(target)
    }
}

extension LayoutConfigurator where Output == NSLayoutConstraint {
    public var item: LayoutItem<Constraint> {
        .init { constraint in
            apply(constraint)
        }
    }
}
