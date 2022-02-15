//
//  AnotherViewController.swift
//  fish-test
//
//  Created by Michael Ong on 2/14/22.
//

import Foundation
import UIKit
import fish

final class AnotherView: ViewTree {
  weak var buttonClose: UIButton?

  @UIViewTree var content: UIViewTree.Result {
    UIStackView {
      UILabel()
        .withModifer {
          $0.text = "Another"
        }
      UIButton()
        .withModifer {
          $0.setTitle("Close", for: .normal)
        }
        .ref(self, to: \AnotherView.buttonClose)
    }
    .withSnapKitLayout {
      $0.center.equalToSuperview()
    }
    .withModifier {
      $0.axis = .vertical
      $0.alignment = .center
    }
  }
}

class AnotherController: UIViewFishController<AnotherView> {
  override func loadView() {
    viewTreeCompiler.useSnapKitMiddleware()

    super.loadView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    content.buttonClose?.addAction(
      .init { [unowned self] _ in
        dismiss(animated: true) {}
      }, for: .touchUpInside)
  }
}
