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
    
    // MARK: Places
    
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
                    
                    let winnersThisWeek = try Winner.query().filter("placeid", placeId).all().filter({ (winner) -> Bool in
                        // If it has won this week add it to the array
                        if Calendar.current.compare(Date.date(fromJsonDate: winner.date), to: Date(), toGranularity: .weekOfYear) == .orderedSame {
                            return true
                        }
                        return false
                    })
                    
                    // If it has already been chosen this week is not elegible
                    if winnersThisWeek.count > 0 {
                        elegibility = false
                        print("\((place as? Node)?["name"]?.string) is not elegigle")
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
    
    // MARK: User Data
    
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

            }else {
                var user = User(name: "", facebookId: fbId)
                try user.save()
            }
            
            userData["userIsAllowedToVote"] = Node(userIsAllowedToVote)
            
            return userData
            
        }catch {
            // Handle Error
        }
        return nil
    }
    
    // MARK: Winners
    
    func winnerForToday() -> String? {
        
        do {
            let winners = try Winner.query().all().filter({ (winner) -> Bool in
                if Date.date(fromJsonDate: winner.date).isToday() {
                    return true
                }
                return false
            })
            
            return winners.first?.placeId
            
        } catch {
            // Handle Error
        }
        
        return nil
    }
    
    func computeVotes() {
        
        do {
            
            let todayVotes = try Vote.query().all().filter({ (vote) -> Bool in
                if Date.date(fromJsonDate: vote.date).isToday() {
                    return true
                }
                return false
            })
            
            
            var voteCount = [String:Int]()
            
            for vote in todayVotes {
            
                if let count = voteCount[vote.placeId] {
                    voteCount[vote.placeId] = count + 1
                }else {
                    voteCount[vote.placeId] = 1
                }
            }
            
            var highestVoted = ("" ,0)
            
            for (placeId , count) in voteCount {
                if count > highestVoted.1 {
                    highestVoted = (placeId, count)
                }
            }
            
            if highestVoted.0.characters.count > 0 {
                var todaysWinner = Winner(placeId: highestVoted.0)
                try todaysWinner.save()
            }
            
            if let dailyWinnersPlaceId = MainInteractor().winnerForToday() {
                
                if let name = MainController().getPlaceNameForId(placeId: dailyWinnersPlaceId) {
                    
                    PushHandler.notificateUserAboutTodaysWinner(winnersName: name)
                }
            }
            
        } catch {
            //
        }
    
    }
}
