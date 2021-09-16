//
//  Layout.swift
//  fish
//
//  Created by Michael Ong on 9/12/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

extension Flows {
    /**
     Layout construct that performs a layout definition to a defined Source.
     */
    public struct Layout<Upstream: Flow>: ComponentContract, Flow {
        public typealias Source = Upstream.Source
        public typealias State = Upstream.State

        public let source: Source
        let upstreamOp: Upstream
        
        let applyBlock: (State) -> Void
        
        internal init<Config: LayoutConfigurator>(_ target: Upstream, _ config: [Config]) where Config.Constraint == Source {
            source = target.source
            upstreamOp = target
            
            applyBlock = { state in
                config.forEach { layout in
                    state.applyLayout { target in
                        layout.apply(target as! Source) as! [State.Layout]
                    }
                }
            }
        }
        
        
        public func withLayout<Config: LayoutConfigurator>(_ config: Config...) -> Layout<Self> where Config.Constraint == Source {
            .init(self, config)
        }
        
        public func withProps<Config: PropertyConfigurator>(_ config: Config...) -> Property<Self> where Config.Constraint == Source {
            .init(self, config)
        }
        
        
        public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Upstream.Source>, _ target: Root) -> Assignment<Self> {
            .init(upstream: self) { [weak target] source in
                target?[keyPath: path] = source
            }
        }
        
        public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Upstream.Source?>, _ target: Root) -> Assignment<Self> {
            .init(upstream: self) { [weak target] source in
                target?[keyPath: path] = source
            }
        }
        
        
        @discardableResult public func apply(_ state: Upstream.State) -> Source {
            upstreamOp.apply(state)
            applyBlock(state)
            
            return source
        }
    }
}
