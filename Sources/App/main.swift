import HTTP
import Vapor
import VaporPostgreSQL
import Jobs
import Foundation

let drop = Droplet(
    preparations: [Place.self, Vote.self, User.self, Winner.self],
    providers: [VaporPostgreSQL.Provider.self]
)

let controller = MainController()
controller.addRoutes(drop: drop)

var lastDateRan: Date?

// Check for daily winners
Jobs.delay(by: Duration.seconds(5), interval: .seconds(60)) {
    
    
    let today = Date()
    var todayComponents = Calendar.current.dateComponents([.day,.month,.year], from: today)
    let hour = Calendar.current.component(.hour, from: today)
    
    if hour == 19 {
    
        if let date = lastDateRan, date.isToday() {
            return
        }
        
        lastDateRan = Date()
        
        MainInteractor().computeVotes()
        
        print("Computing votes")
        
        if let dailyWinnersPlaceId = MainInteractor().winnerForToday() {
            
            if let name = MainController().getPlaceNameForId(placeId: dailyWinnersPlaceId) {
                
                PushHandler.notificateUserAboutTodaysWinner(winnersName: name)
            }
        }
    }
}

drop.run()
