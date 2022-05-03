//
//  MessageNotificationCenter.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import FluentPostgresDriver
import Vapor

actor MessageNotificationCenter {
    private static let channel = "messages"

    typealias NotificationHandler = (String) -> Void
    private var state: [UUID: NotificationHandler] = [:]
}

extension MessageNotificationCenter {
    func notify(_ message: String, on database: any Database) async throws {
        let db = database as! PostgresDatabase
        try await db.simpleQuery("NOTIFY \"\(Self.channel)\", '\(message)'") { _ in }.get()
    }
}

// MARK: - Subscriptions
extension MessageNotificationCenter {
    func subscribe(_ subscriber: UUID, callback: @escaping NotificationHandler) {
        state[subscriber] = callback
    }

    func unsubscribe(_ subscriber: UUID) {
        state[subscriber] = nil
    }

    private func notifyAll(_ notification: PostgresMessage.NotificationResponse) {
        state.forEach {
            $0.value(notification.payload)
        }
    }
}

// MARK: - Lifecycle
extension MessageNotificationCenter: LifecycleHandler {
    nonisolated private func startListening(on database: any Database) throws {
        let database = database as! PostgresDatabase
        try database.withConnection { connection -> EventLoopFuture<Void> in
            connection.addListener(channel: Self.channel) { [weak self] context, notification in
                guard let self = self else { return }
                Task {
                    await self.notifyAll(notification)
                }
            }
            return connection.simpleQuery("LISTEN \"\(Self.channel)\"") { _ in }
        }
        .wait()
    }

    nonisolated func didBoot(_ application: Application) throws {
        try startListening(on: application.db)
    }
}

// MARK: - Storage
private struct MessageNotificationCenterKey: StorageKey {
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
