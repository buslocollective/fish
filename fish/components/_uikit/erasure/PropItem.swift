//
//  PropItem.swift
//  fish
//
//  Created by Michael Ong on 9/14/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit
import Combine

/**
 Construct that wraps a specialized ``PropertyConfigurator`` instance to participate in defining multiple disparate instance types.
 */
public struct PropItem<Target>: PropertyConfigurator {
    public typealias Constraint = Target
    
    var block: (Target) -> Void = { _ in }
    
    public init(block: @escaping (Target) -> Void) {
        self.block = block
    }
    
    public init<Value>(_ keyPath: ReferenceWritableKeyPath<Target, Value>, value: Value) {
        self.block = { target in
            target[keyPath: keyPath] = value
        }
    }
    
    public init<Value>(_ keyPath: ReferenceWritableKeyPath<Target, Value?>, value: Value) {
        self.block = { target in
            target[keyPath: keyPath] = value
        }
    }
    
    public init<Obx: Publisher>(_ keyPath: ReferenceWritableKeyPath<Target, Obx.Output>, source: Obx) where Obx.Failure == Never {
        block = { target in
            source.subscribe(Subscribers.Sink { _ in

            } receiveValue: { value in
                target[keyPath: keyPath] = value
            })
        }
    }
    
    public func apply(_ target: Target) {
        block(target)
    }
}

extension PropertyConfigurator {
    public var item: PropItem<Constraint> {
        .init { constraint in
            apply(constraint)
        }
    }
}
