//
//  PushHandler.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 05/02/17.
//
//

import Foundation
import Vapor
import HTTP

class PushHandler {
    
    class func notificateUserAboutTodaysWinner(winnersName: String) {
        
        
        let oneSignalAPIKey = "13c27fad-8e3b-4e6d-8144-b5b65eaee126"
        let oneSignalURL = "https://onesignal.com/api/v1/notifications"
        
        drop.client = FoundationClient.self
        
        do {
            let params = try JSON(node:["app_id": oneSignalAPIKey.makeNode(),
                                        "included_segments" : ["All"].makeNode(),
                                        "contents" :  ["en": "It has been decided. Today's lunch will be at \(winnersName)!"].makeNode()]).makeBytes()
            
            let _ = try drop.client.post(oneSignalURL, headers: ["Content-Type": "application/json","Authorization" : "Basic YzQwOTI4ZGYtYjc1Ni00MmUwLWEzZmMtMzZhYjA2MDM5MGQ2"], body: Body(params))
        
        }catch {
            // Handle Error
            // It'll never get here 🙏
            print("CATCH ERROR")
        }
    }
}
