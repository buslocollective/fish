//
//  UIView+Flow.swift
//  fish
//
//  Created by Michael Ong on 2/13/22.
//

import Foundation
import SnapKit
import UIKit

public protocol ViewFlowable {}

extension UIView: ViewFlowable {}

extension ViewFlowable where Self: UIView {
  public func withLayout(_ layout: @escaping (Self) -> NSLayoutConstraint)
    -> Flows.ViewLayout<Self, ViewTarget<Self>>
  { .init(.init(self), constraint: layout) }

  public func withSnapKitLayout(_ layout: @escaping (ConstraintMaker) -> Void)
    -> Flows.ViewSnapKitLayout<Self, ViewTarget<Self>>
  { .init(.init(self), maker: layout) }

  public func withModifer(_ modifier: @escaping (Self) -> Void)
    -> Flows.ViewModifier<Self, ViewTarget<Self>>
  { .init(.init(self), modifications: modifier) }

  public func ref<Owner: AnyObject>(
    _ owner: Owner,
    to keyPath: ReferenceWritableKeyPath<Owner, Self?>
  ) -> Flows.ViewRef<Owner, Self, ViewTarget<Self>> {
    .init(.init(self), owner: owner, keyPath: keyPath)
  }
}

extension Flows.ViewSnapKitLayout {
  public func withModifier(_ modifier: @escaping (View) -> Void)
    -> Flows.ViewModifier<View, Self>
  { .init(self, modifications: modifier) }

  public func ref<Owner: AnyObject>(
    _ owner: Owner,
    to keyPath: ReferenceWritableKeyPath<Owner, View?>
  ) -> Flows.ViewRef<Owner, View, Self> {
    .init(self, owner: owner, keyPath: keyPath)
  }
}

extension Flows.ViewLayout {
  public func withLayout(_ layout: @escaping (View) -> NSLayoutConstraint)
    -> Flows.ViewLayout<View, Self>
  { .init(self, constraint: layout) }

  public func withModifier(_ modifier: @escaping (View) -> Void)
    -> Flows.ViewModifier<View, Self>
  { .init(self, modifications: modifier) }

  public func ref<Owner: AnyObject>(
    _ owner: Owner,
    to keyPath: ReferenceWritableKeyPath<Owner, View?>
  ) -> Flows.ViewRef<Owner, View, Self> {
    .init(self, owner: owner, keyPath: keyPath)
  }
}

extension Flows.ViewModifier {
  public func withModifier(_ modifier: @escaping (View) -> Void)
    -> Flows.ViewModifier<View, Self>
  { .init(self, modifications: modifier) }

  public func ref<Owner: AnyObject>(
    _ owner: Owner,
    to keyPath: ReferenceWritableKeyPath<Owner, View?>
  ) -> Flows.ViewRef<Owner, View, Self> {
    .init(self, owner: owner, keyPath: keyPath)
  }
}

extension Flows {
  public struct ViewModifier<View: UIView, Upstream: Flow>: Flow
  where Upstream.Target == ViewTarget<View>, Upstream.State == UIViewTreeState {
    public typealias Target = Upstream.Target
    public typealias State = Upstream.State

    let upstream: Upstream
    let modificationsToExecute: (View) -> Void

    public init(_ upstream: Upstream, modifications: @escaping (View) -> Void) {
      self.upstream = upstream
      self.modificationsToExecute = modifications
    }

    public func consume(_ state: Upstream.State) -> Target {
      let target = upstream.consume(state)
      modificationsToExecute(target.view)

      return target
    }
  }

  public struct ViewLayout<View: UIView, Upstream: Flow>: Flow
  where Upstream.Target == ViewTarget<View>, Upstream.State == UIViewTreeState {
    public typealias Target = Upstream.Target
    public typealias State = Upstream.State

    let upstream: Upstream
    let constraintToBuild: (View) -> NSLayoutConstraint

    public init(
      _ upstream: Upstream,
      constraint: @escaping (View) -> NSLayoutConstraint
    ) {
      self.upstream = upstream
      self.constraintToBuild = constraint
    }

    public func consume(_ state: Upstream.State) -> Target {
      let target = upstream.consume(state)

      if let constraintMiddleware = state.middleware(
        for: UIViewTreeConstraintMiddleware.self
      ) {
        var constraintsToActivate =
          constraintMiddleware.constraintsToResolve[target.view] ?? []
        constraintsToActivate.append(constraintToBuild(target.view))

        constraintMiddleware.constraintsToResolve[target.view] =
          constraintsToActivate
      }

      return target
    }
  }

  public struct ViewSnapKitLayout<View: UIView, Upstream: Flow>: Flow
  where Upstream.Target == ViewTarget<View>, Upstream.State == UIViewTreeState {
    public typealias Target = Upstream.Target
    public typealias State = Upstream.State

    let upstream: Upstream
    let constraintMaker: (ConstraintMaker) -> Void

    public init(
      _ upstream: Upstream,
      maker: @escaping (ConstraintMaker) -> Void
    ) {
      self.upstream = upstream
      self.constraintMaker = maker
    }

    public func consume(_ state: Upstream.State) -> Upstream.Target {
      let target = upstream.consume(state)

      if let middleware = state.middleware(
        for: UIViewTreeSnapKitMiddleware.self
      ) {
        var constraints = middleware.constraintsToResolve[target.view] ?? []
        constraints.append(constraintMaker)

        middleware.constraintsToResolve[target.view] = constraints
      }

      return target
    }
  }

  public struct ViewRef<Owner: AnyObject, View: UIView, Upstream: Flow>: Flow
  where Upstream.Target == ViewTarget<View>, Upstream.State == UIViewTreeState {
    public typealias Target = Upstream.Target
    public typealias State = Upstream.State

    let upstream: Upstream

    weak var owner: Owner?
    let keyPath: ReferenceWritableKeyPath<Owner, View?>

    public init(
      _ upstream: Upstream,
      owner: Owner,
      keyPath: ReferenceWritableKeyPath<Owner, View?>
    ) {
      self.upstream = upstream

      self.owner = owner
      self.keyPath = keyPath
    }

    public func consume(_ state: Upstream.State) -> Target {
      let target = upstream.consume(state)

      if let owner = owner { owner[keyPath: keyPath] = target.view }

      return target
    }
  }
}
