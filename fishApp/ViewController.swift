//
//  ViewController.swift
//  fishApp
//
//  Created by Michael Ong on 9/15/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import UIKit
import fish
import Combine
import Combinative

struct BackgroundColor<Target: ViewFlow>: PropertyConfigurator {
    let color: UIColor
    
    func apply(_ target: Target) {
        target.source.backgroundColor = color
    }
}

struct Height<Target: ViewFlow>: LayoutConfigurator {
    let amount: CGFloat
    
    func apply(_ target: Target) -> [NSLayoutConstraint] {
        let source = target.source
        source.translatesAutoresizingMaskIntoConstraints = false
        
        return [
            target.source.heightAnchor.constraint(equalToConstant: amount)
        ]
    }
}

struct ExclusionEdges: OptionSet {
    var rawValue: Int
    
    static var bottom = ExclusionEdges(rawValue: 16)
    static var top = ExclusionEdges(rawValue: 8)
    static var right = ExclusionEdges(rawValue: 4)
    static var left = ExclusionEdges(rawValue: 2)
}

struct SnapEdges<Target: ViewFlow>: LayoutConfigurator {
    var excluding: ExclusionEdges = []
    
    func apply(_ target: Target) -> [NSLayoutConstraint] {
        let source = target.source
        
        guard let sv = source.superview else {
            return []
        }
        
        source.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        if !excluding.contains(.left) {
            constraints.append(source.leadingAnchor.constraint(equalTo: sv.leadingAnchor))
        }
        
        if !excluding.contains(.right) {
            constraints.append(source.trailingAnchor.constraint(equalTo: sv.trailingAnchor))
        }
        
        if !excluding.contains(.top) {
            constraints.append(source.topAnchor.constraint(equalTo: sv.topAnchor))
        }
        
        if !excluding.contains(.bottom) {
            constraints.append(source.bottomAnchor.constraint(equalTo: sv.bottomAnchor))
        }
        
        return constraints
    }
}

struct Centered<Target: ViewFlow>: LayoutConfigurator {
    func apply(_ target: Target) -> [NSLayoutConstraint] {
        let source = target.source
        
        guard let sv = source.superview else {
            return []
        }
        
        source.translatesAutoresizingMaskIntoConstraints = false
        
        return [
            sv.centerXAnchor.constraint(equalTo: source.centerXAnchor),
            sv.centerYAnchor.constraint(equalTo: source.centerYAnchor)
        ]
    }
}

class ViewController: UIViewController {
    var scope = Set<AnyCancellable>()
    
    weak var input: UITextField?
    
    @Published var value = Optional("Type anything!")

    override func loadView() {
        view = UIView {
            UIStackView {
                UIView(source: $value.removeDuplicates().replaceNil(with: "")) { value in
                    if (value.lowercased().contains("hello world")) {
                        UIStackView {
                            UILabel()
                                .withProps(PropItem(\.text, value: value))
                            UILabel()
                                .withProps(PropItem(\.text, value: "Showering you with love <3"))
                        }
                        .withProps(PropItem(\.axis, value: .horizontal),
                                   PropItem(\.distribution, value: .equalSpacing))
                        .withLayout(SnapEdges().item,
                                    Height(amount: 30).item)
                    } else {
                        UILabel()
                            .withProps(PropItem(\.text, value: value))
                            .withLayout(SnapEdges().item,
                                        Height(amount: 30).item)
                    }
                }
                UILabel()
                    .withProps(PropItem(\.text, source: $value.replaceNil(with: "").map { "\($0) mapped!" }))
                UITextField()
                    .withProps(PropItem { [unowned self] (field: UITextField) in
                        field.publisher(for: .allEditingEvents).map(\.text).assign(to: &$value)
                    })
                    .assigned(to: \.input, self)
            }
            .withProps(PropItem(\.axis, value: .vertical),
                       PropItem(\.spacing, value: 10),
                       PropItem(\.insetsLayoutMarginsFromSafeArea, value: true),
                       PropItem(\.isLayoutMarginsRelativeArrangement, value: true),
                       PropItem(\.layoutMargins, value: .init(top: 20, left: 25, bottom: 20, right: 25)))
            .withLayout(SnapEdges(excluding: .bottom))
        }
        .withProps(BackgroundColor(color: .systemBackground))
        .apply(.create())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        input?.becomeFirstResponder()
    }
}
