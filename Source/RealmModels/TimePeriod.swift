//
//  TimePeriod.swift
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


class TimePeriod: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var startTime: String!
    dynamic var endTime: String!

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "startTime") else { return nil }
        guard map.assureValuePresent(forKey: "endTime") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        startTime <- (map["startTime"], StringTransform())
        endTime <- (map["endTime"], StringTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TimePeriod else { return false }

        return id == object.id
            && name == object.name
            && startTime == object.startTime
            && endTime == object.endTime
    }
}
