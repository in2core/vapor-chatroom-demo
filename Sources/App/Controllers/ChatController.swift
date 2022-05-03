//
//  ChatController.swift
//  App
//
//  Created by Michal Tomlein on 23/04/2022.
//

import Vapor

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.webSocket("websocket", onUpgrade: webSocket)
    }

    private func index(_ req: Request) async throws -> View {
        let messages = try await Message.query(on: req.db)
            .sort(\.$createdAt)
            .all()

        struct ViewContext: Encodable {
            let title: String = "Chat Room Demo"
            let messages: [Message]
        }

        let viewContext = ViewContext(messages: messages)
        return try await req.view.render("index", viewContext)
    }

    private func webSocket(_ req: Request, _ webSocket: WebSocket) async {
        webSocket.onText { webSocket, text in
            do {
                enum IncomingMessage: Decodable {
                    case like(sender: String)
                    case text(sender: String, content: String)
                }

                let incomingMessage = try JSONDecoder().decode(IncomingMessage.self, from: Data(text.utf8))

                let message: Message

                switch incomingMessage {
                case let .like(sender):
                    message = Message(sender: sender, content: "👍")
                case let .text(sender: sender, content: content):
                    message = Message(sender: sender, content: content)
                }

                try await message.save(on: req.db)

                guard let message = try String(data: JSONEncoder().encode(message), encoding: .utf8) else {
                    throw Abort(.internalServerError)
                }
                try await req.application.messageNotificationCenter.notify(message, on: req.db)
            } catch {
                try? await webSocket.close()
            }
        }

        let id = UUID()
        await req.application.messageNotificationCenter.subscribe(id) { notification in
            webSocket.send(notification)
        }
        _ = webSocket.onClose.always { _ in
            Task {
                await req.application.messageNotificationCenter.unsubscribe(id)
            }
        }
    }
}
