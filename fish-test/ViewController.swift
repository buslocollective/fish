//
//  ViewController.swift
//  fish-test
//
//  Created by Michael Ong on 2/13/22.
//

import UIKit
import fish

final class View: ViewTree {
  weak var mainTitle: UILabel?
  weak var actionButton: UIButton?

  @UIViewTree var content: UIViewTree.Result {
    UIImageView()
      .withSnapKitLayout { $0.edges.equalToSuperview() }
    UIStackView {
      UILabel()
        .withModifer {
          $0.text = "Title goes here"
          $0.font = .preferredFont(forTextStyle: .title1)
          $0.textAlignment = .center
        }
        .ref(self, to: \View.mainTitle)
      UILabel()
        .withModifer {
          $0.text = "And this is another label!"
          $0.textAlignment = .center
        }
      UIButton(configuration: .borderedProminent(), primaryAction: nil)
        .withModifer {
          $0.setTitle("Press me", for: .normal)
        }
        .ref(self, to: \View.actionButton)
    }
    .withSnapKitLayout { $0.center.equalToSuperview() }
    .withModifier {
      $0.axis = .vertical
      $0.spacing = 10
    }
  }
}

class ViewController: UIViewFishController<View> {
  override func loadView() {
    viewTreeCompiler.useSnapKitMiddleware()

    super.loadView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.tintColor = .systemCyan

    if let button = content.actionButton {
      button.addAction(
        .init { [unowned self] _ in
          present(AnotherController(), animated: true) {
          }
        }, for: .touchUpInside)
    }
  }
}
