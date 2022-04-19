//
//  Message.swift
//  App
//
//  Created by Filip Klembara on 19/04/2022.
//

import Fluent
import Vapor

final class Message: Model {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "sender")
    var sender: String

    @Field(key: "content")
    var content: String

    @Field(key: "createdAt")
    var createdAt: Date

    init() { }

    init(id: UUID? = nil, sender: String, content: String, createdAt creationDate: Date) {
        self.id = id
        self.sender = sender
        self.content = content
        self.createdAt = creationDate
    }
}
