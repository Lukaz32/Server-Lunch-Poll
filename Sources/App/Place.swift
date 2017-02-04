//
//  Place.swift
//  Lunch-Poll
//
//  Created by Lucas Pereira on 31/01/17.
//
//

import Vapor

final class Place: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var placeId: String?
    var name: String?
    var photoReference: String?
    var photoWidth: Int?
    var latitude: Double?
    var longitude: Double?
    var lastTimeElected: String?
    
    init(placeId: String, name: String, photoReference: String, photoWidth: Int, latitude: Double, longitude: Double, lastTimeElected: String) {
        self.id = nil
        self.placeId = placeId
        self.name = name
        self.photoReference = photoReference
        self.photoWidth = photoWidth
        self.latitude = latitude
        self.longitude = longitude
        self.lastTimeElected = lastTimeElected
    }
    
    init(place: Polymorphic) {
        placeId = (place as? Node)?["place_id"]?.string
        name = (place as? Node)?["name"]?.string
        latitude = (place as? Node)?["geometry"]?["location"]?["lat"]?.double
        longitude = (place as? Node)?["geometry"]?["location"]?["lng"]?.double
        if let photos = (place as? Node)?["photos"]?.array, photos.count > 0 {
            photoReference = (photos[0] as? Node)?["photo_reference"]?.string
            photoWidth = (photos[0] as? Node)?["photo_reference"]?.int
        }
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        placeId = try node.extract("placeid")
        name = try node.extract("name")
        photoReference = try node.extract("photoreference")
        photoWidth = try node.extract("photowidth")
        latitude = try node.extract("latitude")
        longitude = try node.extract("longitude")
        lastTimeElected = try node.extract("lasttimeelected")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : id,
            "placeid" : placeId,
            "name": name,
            "photoreference": photoReference,
            "photowidth" : photoWidth,
            "latitude" : latitude,
            "longitude" : longitude,
            "lasttimeelected" : lastTimeElected
            ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("places") { users in
            users.id()
            users.string("placeId")
            users.string("name")
            users.string("photoreference")
            users.int("photowidth")
            users.double("latitude")
            users.double("longitude")
            users.string("lasttimeelected")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("places")
    }
}

