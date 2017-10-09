//
//  Reservation.swift
//  SwaggerToSwift
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import ObjectMapperAdditions
import RealmSwift
import RealmAdditions


class Reservation: Object, Mappable {
    dynamic var date: String!
    dynamic var timePeriod: TimePeriod!
    dynamic var attendeesCount: Double = 0
    dynamic var room: Room2!
    dynamic var price: Double = 0
    dynamic var package: Package!
    dynamic var userTotalPriceWithTaxes: Double = 0

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }
        guard map.assureValuePresent(forKey: "room") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }
        guard map.assureValuePresent(forKey: "package") else { return nil }
        guard map.assureValuePresent(forKey: "userTotalPriceWithTaxes") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        date <- (map["date"], StringTransform())
        timePeriod <- map["timePeriod"]
        attendeesCount <- (map["attendeesCount"], DoubleTransform())
        room <- map["room"]
        price <- (map["price"], DoubleTransform())
        package <- map["package"]
        userTotalPriceWithTaxes <- (map["userTotalPriceWithTaxes"], DoubleTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Reservation else { return false }

        return date == object.date
            && timePeriod == object.timePeriod
            && attendeesCount == object.attendeesCount
            && room == object.room
            && price == object.price
            && package == object.package
            && userTotalPriceWithTaxes == object.userTotalPriceWithTaxes
    }
}
