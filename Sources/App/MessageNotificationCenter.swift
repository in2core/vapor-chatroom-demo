//
//  MessageNotificationCenter.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import FluentPostgresDriver
import Vapor

class MessageNotificationCenter {
    private static let channel = "messages"

    typealias NotificationHandler = (String) -> Void
    private let state = ManagedCriticalState([UUID: NotificationHandler]())
}

extension MessageNotificationCenter {
    func notify(on database: any Database, message: String) async throws {
        let db = database as! PostgresDatabase
        try await db.simpleQuery("NOTIFY \"\(Self.channel)\", '\(message)'") { _ in }.get()
    }
}

// MARK: - Subscriptions
extension MessageNotificationCenter {
    func subscribe(subscriber: UUID, callback: @escaping NotificationHandler) {
        state.withCriticalRegion { $0[subscriber] = callback }
    }

    func unsubscribe(subscriber: UUID) {
        state.withCriticalRegion { $0[subscriber] = nil }
    }
}

// MARK: - Lifecycle
extension MessageNotificationCenter: LifecycleHandler {
    func startListening(on database: any Database) throws {
        let database = database as! PostgresDatabase
        try database.withConnection { connection -> EventLoopFuture<Void> in
            connection.addListener(channel: Self.channel) { [weak self] context, notification in
                self?.state.withCriticalRegion { subscribers in
                    subscribers.forEach {
                        $0.value(notification.payload)
                    }
                }
            }
            return connection.simpleQuery("LISTEN \"\(Self.channel)\"") { _ in }
        }
        .wait()
    }

    func didBoot(_ application: Application) throws {
        try startListening(on: application.db)
    }
}
