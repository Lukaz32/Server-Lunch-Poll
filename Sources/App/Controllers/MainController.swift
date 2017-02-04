import Vapor
import HTTP
import VaporPostgreSQL

final class MainController {
    
    var currentDroplet: Droplet!
    
    func addRoutes(drop: Droplet) {
        
        currentDroplet = drop
        drop.get("pollingdata", String.self, String.self, handler: getPollingData)
        drop.post("vote", String.self, handler: castVote)
    }
    
    // MARK: Poll Data
    
    func getPollingData(request: Request, facebookId: String, location: String) throws -> ResponseRepresentable {
        
        let googleAPIKey = "AIzaSyDNqUbc1RkjMq76jl8R1M1Tb3WM0tqMbiw"
        let googlePlacesBaseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch"
        
        drop.client = FoundationClient.self
        
        let url = googlePlacesBaseURL + "/json?location=\(location)&radius=500&types=food&key=" + googleAPIKey
        
        var googlePlacesResponse: JSON?
        
        do {
            googlePlacesResponse = try drop.client.get(url).json
            
            if let places = googlePlacesResponse?["results"]?.node {
                
                let interactor = MainInteractor()
                
                // Parse Google Places
                let parsedPlaces = interactor.parsedGooglePlaces(places: places)!
                
                // Fetch User Data
                let userData = interactor.userData(forFacebookId: facebookId)!
                
                // Merge it together
                var response  = ["places" : Node(parsedPlaces)]
                response += userData
                
                return try JSON(node:Node(response))
            }
            
            return googlePlacesResponse!
        }catch {
            throw Abort.badRequest
        }
    }
    
    // MARK: Vote
    
    func castVote(request: Request, facebookId: String) throws -> ResponseRepresentable {
        
        guard let placeId = request.data["placeid"]?.string,
            let userId = try User.query().filter("facebookid", facebookId).first()?.id?.int
            else {
            throw Abort.badRequest
        }
        
        var vote = Vote(userId: userId, placeId: placeId)
        try vote.save()
        
        return try JSON(node: ["message" : "Vote successfully computed!"])
        
    }
    
}
