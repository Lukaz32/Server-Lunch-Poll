//
//  MainInteractor.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 02/02/17.
//
//

import Foundation
import Vapor
import HTTP
import PostgreSQL

class MainInteractor {
    
    func parsedGooglePlaces(places: Node) -> [Node]? {
        
        do {
            
            var parsedPlaces = [Node]()
            
            for place in places.array! {
                
                if let placeId = (place as? Node)?["place_id"]?.string {
                    
                    let votes = try Vote.query().filter("placeid", placeId).all()

                    // Add the place's votes for today
                    var dailyVotes = 0
                    
                    for vote in votes {
                        if Date.date(fromJsonDate: vote.date).isToday() {
                            dailyVotes += 1
                        }
                    }
                    
                    // Check the place's elegibility
                    var elegibility = true
                    
                    let winnersThisWeek = try Winner.query().all().filter({ (winner) -> Bool in
                        // If it has won this week add it to the array
                        if Calendar.current.compare(Date.date(fromJsonDate: winner.date), to: Date(), toGranularity: .weekOfYear) == .orderedSame {
                            return true
                        }
                        return false
                    })
                    
                    // If it has already been chosen this week is not elegible
                    if winnersThisWeek.count > 0 {
                        elegibility = false
                    }
                    
                    // Add the formatted node to the parsed array
                    parsedPlaces.append(["googlePlace" : place as! Node, "votes" : Node(dailyVotes), "elegible" : Node(elegibility)])
                }
            }
            
            return parsedPlaces
            
        }catch {
            // Handle error
        }
        return nil
    }
    
    func userData(forFacebookId fbId: String) -> [String:Node]? {
        
        do {
            var userData = [String:Node]()
            var userIsAllowedToVote = true
            
            // Find user by facebookId
            if let user = try User.query().filter("facebookid", fbId).first() {
                // Fetch the user votes from today
                let dailyVotes = try Vote.query().all().filter({ (vote) -> Bool in
                    if vote.userId == user.id?.int && Date.date(fromJsonDate: vote.date).isToday() {
                        return true
                    }
                    return false
                })
                if dailyVotes.count > 0 { userIsAllowedToVote = false }

            }
            
            userData["userIsAllowedToVote"] = Node(userIsAllowedToVote)
            
            return userData
            
        }catch {
            // Handle error
        }
        return nil
    }
}
