//
//  FlowBuilder.swift
//  fish
//
//  Created by Michael Ong on 9/12/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit

/**
 Construct that creates a flow stream hierarchy.
 
 This is used as a result builder on function arguments to create hierarchy from flow stream instances.

 A `FlowBuilder` defintion found in the wild:
 ```swift
 @FlowBuilder<ViewFlowState>
 var content: UIView {
    UIView {
        UILabel()
            .withProps(PropItem(\.text, value: "Hello World!"))
    }
 }
 
 ```
 */
@resultBuilder
public struct FlowBuilder<State: FlowState> {
    /// Encoded state information of a flow stream result.
    public indirect enum Item: ComponentContract {
        /// No operation.
        case none
        /// A leaf flow stream instance.
        case leaf(state: State?, target: State.Atom)
        /// A grouped flow stream instance.
        case group(state: [Item])
    }
    
    public static func buildExpression<Target: Flow>(_ expression: [Target]) -> Item where Target.State == State {
        .group(state: expression.map(buildExpression))
    }
    
    public static func buildExpression<Target: Flow>(_ expression: Target) -> Item where Target.State == State {
        let atom = expression.source as! State.Atom // runtime casting, huhuhu
        
        let state = State.create()
        expression.apply(state)
        
        return .leaf(state: state, target: atom)
    }
    
    
    public static func buildExpression<Target: ComponentContract & ComponentAssignableContract>(_ expression: Target) -> Item {
        .leaf(state: nil, target: expression as! State.Atom)
    }
    
    
    public static func buildBlock(_ components: Item...) -> Item {
        .group(state: components)
    }

    
    public static func buildEither(first component: Item) -> Item {
        component
    }
    
    public static func buildEither(second component: Item) -> Item {
        component
    }
    
    
    public static func buildOptional(_ component: Item?) -> Item {
        component ?? .none
    }
    
    
    public static func buildArray(_ components: [Item]) -> Item {
        .group(state: components)
    }
}
