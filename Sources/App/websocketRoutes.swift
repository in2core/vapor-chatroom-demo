//
//  websocketRoutes.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Vapor

func websocketRoutes(_ app: Application) throws {
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
        app.messageNotificationCenter.subscribe(subscriber: id) { notification in
            webSocket.send(notification)
        }
        _ = webSocket.onClose.always { _ in
            app.messageNotificationCenter.unsubscribe(subscriber: id)
        }
    }
}
