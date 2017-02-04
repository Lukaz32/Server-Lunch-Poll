import HTTP
import Vapor
import VaporPostgreSQL

let drop = Droplet(
    preparations: [Place.self, Vote.self, User.self, Winner.self],
    providers: [VaporPostgreSQL.Provider.self]
)

//drop.client = FoundationClient.self

drop.get("ramms") { req in


    let spotifyResponse = try drop.client.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670,151.1957&radius=500&types=food&key=AIzaSyDNqUbc1RkjMq76jl8R1M1Tb3WM0tqMbiw")
    print(spotifyResponse)
    
    return try JSON(node: ["message": "API version 1!", "version": "1.0"])
}

let controller = MainController()
controller.addRoutes(drop: drop)

drop.run()
