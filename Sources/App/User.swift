import Vapor

final class User: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var name: String
    var facebookId: String?
    
    init(name: String, facebookId: String?) {
        self.id = nil
        self.name = name
        self.facebookId = facebookId
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        facebookId = try node.extract("facebookid")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : id,
            "name": name,
            "facebookid": facebookId
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("users") { users in
            users.id()
            users.string("name")
            users.string("facebookid")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}
