//
//  FishViewController.swift
//  fish
//
//  Created by Michael Ong on 2/14/22.
//

import Foundation
import UIKit

public protocol ViewTree {
  init()

  var content: UIViewTree.Result { get }
}

open class UIViewFishController<Tree>: UIViewController where Tree: ViewTree {
  public let viewTreeCompiler = UIViewTreeState()

  public lazy var content: Tree = .init()

  open override func loadView() {
    super.loadView()

    UIViewTree.Result.compile(with: viewTreeCompiler, to: view, content.content)
  }
}
