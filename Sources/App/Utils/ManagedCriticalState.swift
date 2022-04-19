//
//  ManagedCriticalState.swift
//  
//
//  Created by Filip Klembara on 19/04/2022.
//

import Vapor

class ManagedCriticalState<State> {
    private let lock = Lock()
    private var state: State

    init(_ context: State) {
        self.state = context
    }

    func withCriticalRegion<T>(do block: (inout State) -> T) -> T {
        lock.withLock {
            block(&state)
        }
    }
}
