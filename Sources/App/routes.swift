//
//  routes.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Fluent
import Vapor

func routes(_ app: Application) throws {
    let chatController = ChatController()
    try app.register(collection: chatController)
}
