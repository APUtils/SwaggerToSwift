//
//  Room2.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Room2: Mappable, Describable {
    var id: String!
    var name: String!
    var abbreviation: String?
    var minAttendees: Double?
    var maxAttendees: Double?
    var location: String!
    var images: String?

    init(id: String? = nil, name: String? = nil, abbreviation: String? = nil, minAttendees: Double? = nil, maxAttendees: Double? = nil, location: String? = nil, images: String? = nil) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.minAttendees = minAttendees
        self.maxAttendees = maxAttendees
        self.location = location
        self.images = images
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        abbreviation <- (map["abbreviation"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- (map["location"], StringTransform())
        images <- (map["images"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Room2: Equatable {
    static func ==(lhs: Room2, rhs: Room2) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.abbreviation == rhs.abbreviation
            && lhs.minAttendees == rhs.minAttendees
            && lhs.maxAttendees == rhs.maxAttendees
            && lhs.location == rhs.location
            && lhs.images == rhs.images
    }
}
