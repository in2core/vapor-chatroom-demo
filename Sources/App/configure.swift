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
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "chatroom"
    ), as: .psql)

    app.migrations.add(CreateMessage())
    app.migrations.add(SeedMessages())
    try app.autoMigrate().wait()

    let messageNotificationCenter = MessageNotificationCenter()
    app.messageNotificationCenter = messageNotificationCenter
    app.lifecycle.use(messageNotificationCenter)

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
