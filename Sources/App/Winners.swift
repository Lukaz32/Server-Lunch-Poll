//
//  Winners.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 04/02/17.
//
//

import Vapor
import Foundation

final class Winner: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var placeId: String
    var date: String
    
    init(placeId: String) {
        self.id = nil
        self.placeId = placeId
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = dateFormat.string(from: Date())
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        placeId = try node.extract("placeid")
        date = try node.extract("date")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : id,
            "placeid": placeId,
            "date" : date
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("winners") { users in
            users.id()
            users.string("placeid")
            users.string("date")
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("winners")
    }
}
