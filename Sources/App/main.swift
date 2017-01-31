import Vapor
import VaporPostgreSQL

let drop = Droplet(
    providers: [VaporPostgreSQL.Provider.self]
)

drop.get { req in
    
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    }else {
        return "NO DB Connection :/"
    }
}

drop.run()
