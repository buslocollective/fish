//
//  Flow+UIKit.swift
//  fish
//
//  Created by Michael Ong on 9/13/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit
import Combine

/**
 Contains state information for passing layout and props to a `UIView`.
 */
public final class ViewFlowState: FlowState {
    public typealias Atom = UIView
    public typealias Layout = NSLayoutConstraint
    
    var constraints: [(Atom) -> [NSLayoutConstraint]] = []
    
    public static func create() -> ViewFlowState {
        ViewFlowState()
    }
    
    
    public func applyLayout(block: @escaping (Atom) -> [NSLayoutConstraint]) {
        constraints.append(block)
    }
    
    public func finalize() {
        
    }
}

/**
 Contract that allows UIKit participation in creating flow streams.
 */
public protocol ViewFlow: Flow where State == ViewFlowState {
    associatedtype View: UIView
    
    var source: View { get }
}

extension UIView: ViewFlow {
    public var source: UIView { self }
    
    public func apply(_ state: ViewFlowState) -> UIView {
        NSLayoutConstraint.activate(state.constraints.flatMap { $0(self) })
        
        return self
    }
}
