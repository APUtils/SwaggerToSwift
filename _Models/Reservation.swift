//
//  Reservation.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 07/17/17.
//  Copyright © 2017 mac-246. All rights reserved.
//

import ObjectMapper


struct Reservation: Mappable, Describable {
    var date: String!
    var email: String!
    var guests: [Guest]?
    var isLunchIncluded: Bool?
    var name: String!

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        date <-- map["date"]
        email <-- map["email"]
        guests <- map["guests"]
        isLunchIncluded <-- map["isLunchIncluded"]
        name <-- map["name"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Reservation: Equatable {
    static func ==(lhs: Reservation, rhs: Reservation) -> Bool {
        return lhs.date == rhs.date
            && lhs.email == rhs.email
            && lhs.guests == rhs.guests
            && lhs.isLunchIncluded == rhs.isLunchIncluded
            && lhs.name == rhs.name
    }
}
