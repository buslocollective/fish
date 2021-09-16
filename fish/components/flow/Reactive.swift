//
//  Reactive.swift
//  fish
//
//  Created by Michael Ong on 9/15/21.
//  Copyright © 2021 Buslo Collective. All rights reserved.
//

import Foundation
import Combine

extension Flows {
    /**
     Reactive construct to apply builder updates on `Publisher` emissions.
     */
    public class Reactive<Upstream: Flow, Observable: Publisher>: Flow where Observable.Failure == Never {
        public typealias Source = Upstream.Source
        public typealias State = Upstream.State
        
        public typealias Config = (Subscribers.Sink<Observable.Output, Never>) -> Void
        
        public let source: Source
        let upstreamOp: Upstream
        
        private let config: Config
        private let builder: (Observable.Output) -> ComponentContract
        
        var onUpdate: (ComponentContract) -> Void = { _ in }
        
        internal init(_ upstream: Upstream, builder: @escaping (Observable.Output) -> ComponentContract, config: @escaping Config) {
            source = upstream.source
            upstreamOp = upstream
            
            self.config = config
            self.builder = builder
        }
        
        
        public func withLayout<Config: LayoutConfigurator>(_ config: Config...) -> Layout<Reactive<Upstream, Observable>> where Config.Constraint == Source {
            .init(self, config)
        }
        
        public func withProps<Config: PropertyConfigurator>(_ config: Config...) -> Property<Reactive<Upstream, Observable>> where Config.Constraint == Source {
            .init(self, config)
        }
        
        
        public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Upstream.Source>, _ target: Root) -> Assignment<Reactive<Upstream, Observable>> {
            .init(upstream: self) { [weak target] source in
                target?[keyPath: path] = source
            }
        }
        
        public func assigned<Root: AnyObject>(to path: WritableKeyPath<Root, Upstream.Source?>, _ target: Root) -> Assignment<Reactive<Upstream, Observable>> {
            .init(upstream: self) { [weak target] source in
                target?[keyPath: path] = source
            }
        }
        
        
        @discardableResult public func apply(_ state: Upstream.State) -> Upstream.Source {
            upstreamOp.apply(state)

            let sink = Subscribers.Sink<Observable.Output, Never> { _ in
            } receiveValue: { [self] value in
                onUpdate(builder(value))
            }
            
            config(sink)
            
            return source
        }
    }
}
