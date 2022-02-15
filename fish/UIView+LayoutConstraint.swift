//
//  UIView+LayoutConstraint.swift
//  fish
//
//  Created by Michael Ong on 2/13/22.
//

import UIKit

public class UIViewTreeConstraintMiddleware: UIViewTreeMiddleware {
  public var key: UIViewTreeMiddlewareKey { .init(Self.self) }
  public var constraintsToResolve: [UIView: [NSLayoutConstraint]] = [:]

  public init() {}

  public func setup() {

  }

  public func cleanup() { constraintsToResolve.removeAll() }

  public func postRender(view: UIView) {
    for constraint in constraintsToResolve[view] ?? [] {
      constraint.isActive = true
    }
  }
}

extension UIViewTreeState {
  public func useConstraintMiddleware() {
    addMiddleware(UIViewTreeConstraintMiddleware())
  }
}
