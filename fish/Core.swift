//
//  Core.swift
//  fish
//
//  Created by Michael Ong on 2/13/22.
//

import Foundation

public enum Flows {}

public protocol Unit: AnyObject {
  associatedtype State: FlowState

  var unit: FlowTree<State.Target, State>.Result? { get }
}

public protocol FlowState: AnyObject {
  associatedtype Target: Unit

  func preCompile()
  func postCompile()

  func compile(_ items: [(Self) -> Target]) -> [Target]
  func render(to target: Target, _ items: [Target])
}

public protocol Flow {
  associatedtype Target
  associatedtype State: FlowState

  func consume(_ state: State) -> Target
}

@resultBuilder public struct FlowTree<Target, State: FlowState>
where Target == State.Target {
  public typealias Pod = (State) -> Target

  public struct Result {
    public static func compile(
      with state: State,
      to target: Target,
      _ result: Result
    ) where Target.State == State {
      func buildChildren(container: Target, items: [(State) -> State.Target]) {
        let group = state.compile(items)
        state.render(to: container, group)

        for item in group {
          if let unit = item.unit {
            buildChildren(container: item, items: unit.pods)
          }
        }
      }

      state.preCompile()
      buildChildren(container: target, items: result.pods)
      state.postCompile()
    }

    public private(set) var pods: [Pod] = []

    init(items: FlowTree<Target, State>.Kind) {
      // flatten items into one result
      // reason for this is because all
      // child targets are immediately
      // the parent of another target

      var toCheck = [items]

      while !toCheck.isEmpty {
        guard let item = toCheck.popLast() else { break }

        switch item {
        case .group(let subitems): toCheck.insert(contentsOf: subitems.reversed(), at: 0)
        case .leaf(let pod): pods.append(pod)
        }
      }
    }
  }

  public enum Kind {
    case leaf(pod: Pod)
    case group([Kind])
  }

  public static func buildBlock(_ components: Kind...) -> Kind {
    .group(components)
  }

  public static func buildFinalResult(_ component: FlowTree<Target, State>.Kind) -> Result {
    .init(items: component)
  }
}
