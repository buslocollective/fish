//
//  ComponentContract+UIKit.swift
//  fish
//
//  Created by Michael Ong on 9/12/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit

/// Alias that defines the source of a `UIView` flow stream.
public typealias ViewSource<View: UIView> = Flows.Source<ViewFlowState, View>

extension UIView: ComponentContract, ComponentAssignableContract {
    public convenience init(@FlowBuilder<ViewFlowState> children: () -> FlowBuilder<ViewFlowState>.Item) {
        self.init(frame: .zero)
        
        _ = withChildren(children)
    }
}

extension ComponentContract where Self: UIView {
    /**
     Creates a flow stream hierarchy.
     
     - Parameters:
        - children: The child flow stream items to include.
     
     - Returns: The instance with the children added.
     */
    public func withChildren(@FlowBuilder<ViewFlowState> _ children: () -> FlowBuilder<ViewFlowState>.Item) -> Self {
        func parse(_ item: FlowBuilder<ViewFlowState>.Item) {
            switch item {
            case .none:
                break
            case .group(let items):
                items.forEach(parse)
            case .leaf(let state, let target):
                switch self {
                case let me as UIStackView:
                    me.addArrangedSubview(target)
                case let me as UICollectionViewCell:
                    me.contentView.addSubview(target)
                case let me as UIVisualEffectView:
                    me.contentView.addSubview(target)
                default:
                    addSubview(target)
                }
                
                if let state = state {
                    _ = target.apply(state)
                }
            }
        }
        
        parse(children())
        
        return self
    }
}

extension ComponentContract where Self: UIView {
    /**
     Creates a layout definition flow stream.
     */
    public func withLayout<Config: LayoutConfigurator>(_ config: Config...) -> Flows.Layout<ViewSource<Self>> where Config.Constraint == Self {
        .init(.init(source: self), config)
    }
    
    /**
     Creates a property flow stream.
     */
    public func withProps<Config: PropertyConfigurator>(_ config: Config...) -> Flows.Property<ViewSource<Self>> where Config.Constraint == Self {
        .init(.init(source: self), config)
    }
    
    
    /**
     Creates an assignment flow stream.
     */
    public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Self>, _ target: Root) -> Flows.Assignment<ViewSource<Self>> {
        .init(upstream: .init(source: self)) { [weak target] source in
            target?[keyPath: path] = source
        }
    }

    /**
     Creates an assignment flow stream.
     */
    public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Self?>, _ target: Root) -> Flows.Assignment<ViewSource<Self>> {
        .init(upstream: .init(source: self)) { [weak target] source in
            target?[keyPath: path] = source
        }
    }
}
