//
//  Package.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Package: Mappable, Describable {
    var id: String!
    var name: String!
    var displayName: String?
    var description: String?
    var minAttendees: Double?
    var maxAttendees: Double?
    var price: Double!
    var preparationDuration: Double?

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        displayName <- (map["displayName"], StringTransform())
        description <- (map["description"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        price <- (map["price"], DoubleTransform())
        preparationDuration <- (map["preparationDuration"], DoubleTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Package: Equatable {
    static func ==(lhs: Package, rhs: Package) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.displayName == rhs.displayName
            && lhs.description == rhs.description
            && lhs.minAttendees == rhs.minAttendees
            && lhs.maxAttendees == rhs.maxAttendees
            && lhs.price == rhs.price
            && lhs.preparationDuration == rhs.preparationDuration
    }
}
