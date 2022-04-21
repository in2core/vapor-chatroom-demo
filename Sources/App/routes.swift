//
//  routes.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> View in
        let messages = try await Message.query(on: app.db)
            .sort(\.$createdAt)
            .all()
            .map {
                ChatRoomMessage(sender: $0.sender, content: $0.content)
            }

        struct ViewContext: Encodable {
            let title: String = "Chat Room Demo"
            let messages: [ChatRoomMessage]
        }
        let ctx = ViewContext(messages: messages)
        return try await req.view.render("index", ctx)
    }
}
