//
//  Assignment.swift
//  fish
//
//  Created by Michael Ong on 9/13/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

extension Flows {
    /**
     Wrapping construct that performs an assignment to a defined target.
     */
    public struct Assignment<Upstream: Flow>: ComponentContract, Flow {
        public typealias Source = Upstream.Source
        public typealias State = Upstream.State

        public let source: Source
        let upstreamOp: Upstream
        
        let assignBlock: (Source) -> Void
        
        internal init(upstream: Upstream, block: @escaping (Source) -> Void) {
            self.assignBlock = block
            
            source = upstream.source
            upstreamOp = upstream
        }
        
        @discardableResult public func apply(_ state: Upstream.State) -> Source {
            upstreamOp.apply(state)
            assignBlock(source)
            
            return source
        }
    }
}
