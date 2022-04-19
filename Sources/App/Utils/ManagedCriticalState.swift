//
//  ManagedCriticalState.swift
//  
//
//  Created by Filip Klembara on 19/04/2022.
//

import Vapor

class ManagedCriticalState<Context> {
    private let lock = Lock()
    private var context: Context
    init(_ context: Context) {
        self.context = context
    }

    func withCriticalRegion<T>(do block: (inout Context) -> T) -> T {
        lock.withLock {
            block(&context)
        }
    }
}
