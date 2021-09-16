//
//  ComponentContract+Combine.swift
//  fish
//
//  Created by Michael Ong on 9/15/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit
import Combine

extension FlowBuilder where State == ViewFlowState {
    /**
     Builder input for creating reactive flow streams.
     
     - Parameters:
        - expression: A `Flows.Reactive` stream to be assigned reactive builder updates.
     */
    public static func buildExpression<Source: Publisher>(_ expression: Flows.Reactive<ViewSource<State.Atom>, Source>) -> Item {
        let source = expression.source
        
        func parse(_ item: FlowBuilder<ViewFlowState>.Item) {
            switch item {
            case .none:
                break
            case .group(let items):
                items.forEach(parse)
            case .leaf(let state, let target):
                source.addSubview(target)
                
                if let state = state {
                    _ = target.apply(state)
                }
            }
        }
        
        let state = ViewFlowState.create()
        expression.onUpdate = { item in
            source.subviews.forEach { $0.removeFromSuperview() }
            parse(item as! FlowBuilder.Item)
        }
        expression.apply(state)
        
        return .leaf(state: state, target: expression.source)
    }
}

extension ComponentContract where Self: UIView {
    /**
     Starts a reactive flow stream.
     */
    public func withPublisher<Obx: Publisher>(source: Obx, @FlowBuilder<ViewFlowState> _ builder: @escaping (Obx.Output) -> ComponentContract)
        -> Flows.Reactive<ViewSource<Self>, Obx> where Obx.Failure == Never {
            return .init(.init(source: self), builder: builder) { bind in source.subscribe(bind) }
    }
}

extension UIView {
    public convenience init<Obx: Publisher>(source: Obx, @FlowBuilder<ViewFlowState> _ builder: @escaping (Obx.Output)
        -> ComponentContract) where Obx.Failure == Never {
        self.init(frame: .zero)
        
        func parse(_ item: FlowBuilder<ViewFlowState>.Item) {
            switch item {
            case .none:
                break
            case .group(let items):
                items.forEach(parse)
            case .leaf(let state, let target):
                addSubview(target)
                
                if let state = state {
                    _ = target.apply(state)
                }
            }
        }
        
        let stream = withPublisher(source: source, builder)
        
        stream.onUpdate = { [unowned self] item in
            subviews.forEach { $0.removeFromSuperview() }
            parse(item as! FlowBuilder.Item)
        }
        
        stream.apply(.create())
    }
}
