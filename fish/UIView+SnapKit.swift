//
//  UIView+SnapKit.swift
//  fish
//
//  Created by Michael Ong on 2/13/22.
//

import Foundation
import SnapKit
import UIKit

public class UIViewTreeSnapKitMiddleware: UIViewTreeMiddleware {
  public var key: UIViewTreeMiddlewareKey { .init(Self.self) }

  public var constraintsToResolve: [UIView: [(ConstraintMaker) -> Void]] = [:]

  public init() {}

  public func setup() {}

  public func cleanup() { constraintsToResolve.removeAll() }

  public func postRender(view: UIView) {
    if let makers = constraintsToResolve[view] {
      for maker in makers { view.snp.makeConstraints(maker) }
    }
  }
}

extension UIViewTreeState {
  public func useSnapKitMiddleware() {
    addMiddleware(UIViewTreeSnapKitMiddleware())
  }
}
