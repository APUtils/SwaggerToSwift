//
//  Reservation.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Reservation: Mappable, Describable {
    var date: String!
    var timePeriod: TimePeriod!
    var attendeesCount: Double?
    var room: Room2!
    var price: Double!
    var package: Package!
    var userTotalPriceWithTaxes: Double!

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }
        guard map.assureValuePresent(forKey: "room") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }
        guard map.assureValuePresent(forKey: "package") else { return nil }
        guard map.assureValuePresent(forKey: "userTotalPriceWithTaxes") else { return nil }
    }

    mutating func mapping(map: Map) {
        date <- (map["date"], StringTransform())
        timePeriod <- map["timePeriod"]
        attendeesCount <- (map["attendeesCount"], DoubleTransform())
        room <- map["room"]
        price <- (map["price"], DoubleTransform())
        package <- map["package"]
        userTotalPriceWithTaxes <- (map["userTotalPriceWithTaxes"], DoubleTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Reservation: Equatable {
    static func ==(lhs: Reservation, rhs: Reservation) -> Bool {
        return lhs.date == rhs.date
            && lhs.timePeriod == rhs.timePeriod
            && lhs.attendeesCount == rhs.attendeesCount
            && lhs.room == rhs.room
            && lhs.price == rhs.price
            && lhs.package == rhs.package
            && lhs.userTotalPriceWithTaxes == rhs.userTotalPriceWithTaxes
    }
}
