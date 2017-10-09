//
//  Package.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import ObjectMapperAdditions
import RealmSwift
import RealmAdditions


class Package: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var displayName: String?
    dynamic var descriptionString: String?
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var price: Double = 0
    dynamic var preparationDuration: Double = 0

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        displayName <- (map["displayName"], StringTransform())
        descriptionString <- (map["description"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        price <- (map["price"], DoubleTransform())
        preparationDuration <- (map["preparationDuration"], DoubleTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Package else { return false }

        return id == object.id
            && name == object.name
            && displayName == object.displayName
            && descriptionString == object.descriptionString
            && minAttendees == object.minAttendees
            && maxAttendees == object.maxAttendees
            && price == object.price
            && preparationDuration == object.preparationDuration
    }
}
