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


// Something with Ubuntu is crashing the app on this routine
// Locally on OSX it works fine.
// For now winners will have to be computed manually by calling
// https://calm-plateau-17216.herokuapp.com/vote/compute

/*
var lastDateRan: Date?

// Check for daily winners
Jobs.delay(by: Duration.seconds(30), interval: .seconds(30)) {
    
    print("Running Job")
    fflush(stdout)
    
    let today = Date()
    
    print(today)
    
    var todayComponents = Calendar(identifier: .gregorian).dateComponents([.day,.month,.year], from: today)
    let hour = Calendar(identifier: .gregorian).component(.hour, from: today)
    
    if hour == 13 {
    
        print("It's time!.")
        fflush(stdout)
        
        if let date = lastDateRan, date.isToday() {
            
            print("Votes already computed for today.")
            fflush(stdout)
            return
        }
        
        print("Votes about to be computed")
        fflush(stdout)
        
        lastDateRan = Date()
        
        MainInteractor().computeVotes()
        
    }
}
*/

drop.run()
