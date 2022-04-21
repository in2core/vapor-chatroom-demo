//
//  websocketRoutes.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateMessage())
    app.autoMigrate().whenFailure { error in
        fatalError(error.localizedDescription)
    }

    let messageNotificationCenter = MessageNotificationCenter()
    app.messageNotificationCenter = messageNotificationCenter
    app.lifecycle.use(messageNotificationCenter)

    app.views.use(.leaf)

    try websocketRoutes(app)
    try routes(app)
}
