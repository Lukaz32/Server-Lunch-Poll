//
//  Vote.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 02/02/17.
//
//

import Vapor
import Foundation

final class Vote: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var userId: Int
    var placeId: String
    var date: String
    
    init(userId: Int, placeId: String) {
        self.id = nil
        self.userId = userId
        self.placeId = placeId
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = dateFormat.string(from: Date())
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userId = try node.extract("userid")
        placeId = try node.extract("placeid")
        date = try node.extract("date")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : id,
            "userid": userId,
            "placeid": placeId,
            "date" : date
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("votes") { users in
            users.id()
            users.int("userid")
            users.string("placeid")
            users.string("date")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("votes")
    }
}
