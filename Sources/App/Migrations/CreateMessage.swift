//
//  CreateMessage.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("messages")
            .id()
            .field("createdAt", .datetime, .required)
            .field("sender", .string, .required)
            .field("content", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("messages").delete()
    }
}
