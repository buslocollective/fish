//
//  Source.swift
//  fish
//
//  Created by Michael Ong on 9/14/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation

extension Flows {
    /**
     Starting construct for a flow stream.
     */
    public struct Source<State: FlowState, Target>: Flow {
        public typealias Source = Target
        public typealias State = State
        
        public let source: Target
    }
}
