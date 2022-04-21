//
//  Application+messageNotificationCenter.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Vapor

struct MessageNotificationCenterKey: StorageKey {
    typealias Value = MessageNotificationCenter
}

extension Application {
    var messageNotificationCenter: MessageNotificationCenter {
        get {
            storage[MessageNotificationCenterKey.self]!
        }
        set {
            storage[MessageNotificationCenterKey.self] = newValue
        }
    }
}
