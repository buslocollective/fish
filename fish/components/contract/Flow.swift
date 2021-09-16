//
//  Flow.swift
//  fish
//
//  Created by Michael Ong on 9/13/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

/**
 Conformance to allow disparate transitory types to conform to its target constraints.
 */
public protocol Flow {
    /// The flow stream source type
    associatedtype Source
    
    /// The state to store relevant flow stream information.
    associatedtype State: FlowState
    
    /// The instance to apply the stream onto.
    var source: Source { get }
    
    /// Applies any kept-up flow stream configuration to the ``fish/Flow/source-swift.property`` immediately.
    @discardableResult func apply(_ state: State) -> Source
}

extension Flow {
    public func apply(_ state: State) -> Source {
        source
    }
}

/**
 Conformance that provides a ``Flow`` stream context.
 
 This is primarily used when creating ``FlowBuilder`` instances. This augments instance creation in a flow stream
 by sending applicable use-later actions such as layout definitions.
 */
public protocol FlowState: AnyObject {
    /// The base type that `Flow.Source` inherits from.
    associatedtype Atom
    /// The layout type.
    associatedtype Layout
    
    /// Creates a new `FlowState`.
    static func create() -> Self
    
    /// Applys a given layout information to the `Atom`.
    func applyLayout(block: @escaping (Atom) -> [Layout])
}
