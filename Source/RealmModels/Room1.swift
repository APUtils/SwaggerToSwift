//
//  Room1.swift
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


class Room1: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var location: Location!
    var images: List<RealmString> = List<RealmString>()
    dynamic var date: String!
    var prices: List<Price> = List<Price>()
    var statuses: List<Status> = List<Status>()

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "prices") else { return nil }
        guard map.assureValuePresent(forKey: "statuses") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], RealmTypeCastTransform<RealmString>())
        date <- (map["date"], StringTransform())
        prices <- (map["prices"], ListTransform<Price>())
        statuses <- (map["statuses"], ListTransform<Status>())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Room1 else { return false }

        return id == object.id
            && name == object.name
            && minAttendees == object.minAttendees
            && maxAttendees == object.maxAttendees
            && location == object.location
            && images == object.images
            && date == object.date
            && prices == object.prices
            && statuses == object.statuses
    }
}
