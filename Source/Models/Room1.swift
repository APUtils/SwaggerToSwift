//
//  Room1.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Room1: Mappable, Describable {
    var id: String!
    var name: String!
    var minAttendees: Double?
    var maxAttendees: Double?
    var location: Location!
    var images: [String]?
    var date: String!
    var prices: [Price]!
    var statuses: [Status]!

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "prices") else { return nil }
        guard map.assureValuePresent(forKey: "statuses") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], StringTransform())
        date <- (map["date"], StringTransform())
        prices <- map["prices"]
        statuses <- map["statuses"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Room1: Equatable {
    static func ==(lhs: Room1, rhs: Room1) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.minAttendees == rhs.minAttendees
            && lhs.maxAttendees == rhs.maxAttendees
            && lhs.location == rhs.location
            && lhs.images == rhs.images
            && lhs.date == rhs.date
            && lhs.prices == rhs.prices
            && lhs.statuses == rhs.statuses
    }
}
