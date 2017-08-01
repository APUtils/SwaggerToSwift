//
//  Room2.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import ObjectMapperAdditions
import RealmSwift
import RealmAdditions


class Room2: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var abbreviation: String?
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var location: String!
    dynamic var images: String?

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        abbreviation <- (map["abbreviation"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- (map["location"], StringTransform())
        images <- (map["images"], StringTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Room2 else { return false }

        return id == object.id
            && name == object.name
            && abbreviation == object.abbreviation
            && minAttendees == object.minAttendees
            && maxAttendees == object.maxAttendees
            && location == object.location
            && images == object.images
    }
}
