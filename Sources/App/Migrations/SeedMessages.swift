//
//  SeedMessages.swift
//  ChatRoom
//
//  Created by Filip Klembara on 02/05/2022.
//

import Fluent

struct SeedMessages: AsyncMigration {
    func prepare(on database: Database) async throws {
        let m1 = Message(sender: "Alice", content: "Hello")
        let m2 = Message(sender: "Bob", content: "Hi Alice, how are you?")
        let m3 = Message(sender: "Alice", content: "Good, you?")
        let messages = [m1, m2, m3]
        for message in messages {
            try await message.create(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await Message.query(on: database).delete()
    }
}
