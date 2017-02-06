import Vapor
import HTTP
import VaporPostgreSQL
import Foundation

final class MainController {
    
    let googleAPIKey = "AIzaSyCBUZCO2r_WNJzPwJ4-5cEJMgK8_CHzxPU"
    let googlePlacesBaseURL = "https://maps.googleapis.com/maps/api/place"
    
    var currentDroplet: Droplet!
    
    func addRoutes(drop: Droplet) {
        
        currentDroplet = drop
        drop.get("pollingdata", String.self, String.self, handler: getPollingData)
        drop.get("winner", handler: getTodaysWinner)
        drop.post("vote", String.self, handler: castVote)
    }
    
    // MARK: Poll Data
    
    func getPollingData(request: Request, facebookId: String, location: String) throws -> ResponseRepresentable {
        
        drop.client = FoundationClient.self
        
        let url = googlePlacesBaseURL + "/nearbysearch/json?location=\(location)&radius=500&types=food&key=" + googleAPIKey
        
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
    
    func getPlaceNameForId(placeId: String) -> String? {
        
        drop.client = FoundationClient.self
        
        let url = googlePlacesBaseURL + "/details/json?placeid=\(placeId)&key=" + googleAPIKey
        
        var googlePlacesResponse: JSON?
        
        do {
            googlePlacesResponse = try drop.client.get(url).json
            
            return googlePlacesResponse?["result"]?["name"]?.node.string
            
        } catch  {
            // Handle Error
        }
        
        return nil
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
    
    // MARK: Winner
    
    func getTodaysWinner(request: Request) throws -> ResponseRepresentable {
        
    
        guard let winner = MainInteractor().winnerForToday() else {
            throw Abort.notFound
        }
        
        return try JSON(node: ["winner" : winner])
        
        
    }    
    
}
