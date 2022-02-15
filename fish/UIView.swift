//
//  UIView.swift
//  fish
//
//  Created by Michael Ong on 2/13/22.
//

import Foundation
import UIKit

public typealias UIViewTree = FlowTree<UIView, UIViewTreeState>

public struct ViewTarget<View: UIView>: Flow {
  public typealias Target = ViewTarget<View>
  public typealias State = UIViewTreeState

  let view: View

  init(_ view: View) { self.view = view }

  public func consume(_ state: UIViewTreeState) -> ViewTarget<View> { self }
}

public struct UIViewTreeMiddlewareKey {
  public let type: Any.Type

  public init(_ type: Any.Type) { self.type = type }
}

extension UIViewTreeMiddlewareKey: Hashable, Equatable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(type))
  }

  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.type == rhs.type }
}

public protocol UIViewTreeMiddleware {
  var key: UIViewTreeMiddlewareKey { get }

  func preRender(view: UIView) -> Bool
  func postRender(view: UIView)

  func setup()
  func cleanup()
}

extension UIViewTreeMiddleware {
  public func preRender(view: UIView) -> Bool { true }
}

public final class UIViewTreeState: FlowState {
  public typealias Target = UIView

  public private(set) var middlewares = [
    UIViewTreeMiddlewareKey: UIViewTreeMiddleware
  ]()

  public init() {}

  public func addMiddleware<Middleware>(_ middleware: Middleware)
  where Middleware: UIViewTreeMiddleware {
    middlewares[.init(Middleware.self)] = middleware
  }

  public func middleware<Middleware>(for key: Middleware.Type) -> Middleware?
  where Middleware: UIViewTreeMiddleware {
    middlewares[.init(key)] as? Middleware
  }

  public func preCompile() { middlewares.forEach { $1.setup() } }

  public func postCompile() { middlewares.forEach { $1.cleanup() } }

  public func compile(_ items: [(UIViewTreeState) -> UIView]) -> [UIView] {
    items.map { item in item(self) }
  }

  public func render(to container: UIView, _ items: [UIView]) {
    renderViews: for item in items {
      for middleware in middlewares {
        if middleware.value.preRender(view: item) == false {
          continue renderViews
        }
      }

      switch container {
      case let view as UIStackView: view.addArrangedSubview(item)
      case let view as UIVisualEffectView: view.contentView.addSubview(view)
      case let view as UICollectionViewCell: view.contentView.addSubview(view)
      default: container.addSubview(item)
      }

      middlewares.forEach { $1.postRender(view: item) }
    }
  }
}

extension UIView: Unit {
  fileprivate static var key: Int = 0xBEEF

  public typealias State = UIViewTreeState

  public var unit: UIViewTree.Result? {
    get { objc_getAssociatedObject(self, &Self.key) as? UIViewTree.Result }
    set {
      objc_setAssociatedObject(
        self,
        &Self.key,
        newValue,
        .OBJC_ASSOCIATION_COPY
      )
    }
  }

  public convenience init(@UIViewTree _ children: () -> UIViewTree.Result) {
    self.init(frame: .zero)

    unit = children()
  }
}

extension FlowTree where State == UIViewTreeState {
  public static func buildExpression<FlowStream: Flow, View: UIView>(
    _ expression: FlowStream
  ) -> FlowTree<Target, State>.Kind
  where FlowStream.Target == ViewTarget<View>, FlowStream.State == State {
    .leaf { state in expression.consume(state).view }
  }

  public static func buildExpression<View: UIView>(_ expression: View)
    -> FlowTree<Target, State>.Kind
  { .leaf { state in expression } }
}
