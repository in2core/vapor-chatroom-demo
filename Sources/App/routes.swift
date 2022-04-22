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

    app.webSocket("websocket") { request, webSocket in
        webSocket.onText { webSocket, text in
            do {
                let incomingMessage = try JSONDecoder().decode(ChatRoomMessage.self, from: Data(text.utf8))

                let message = Message(sender: incomingMessage.sender, content: incomingMessage.content, createdAt: Date())
                try await message.save(on: app.db)

                try await app.messageNotificationCenter.notify(on: app.db, message: text)
            } catch {
                try? await webSocket.close()
            }
        }

        let id = UUID()
        await app.messageNotificationCenter.subscribe(subscriber: id) { notification in
            webSocket.send(notification)
        }
        _ = webSocket.onClose.always { _ in
            Task {
                await app.messageNotificationCenter.unsubscribe(subscriber: id)
            }
        }
    }
}
