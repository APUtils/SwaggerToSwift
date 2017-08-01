//
//  Status.swift
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


class Status: Object, Mappable {
    dynamic var date: String!
    dynamic var status: String!
    dynamic var timePeriod: TimePeriod!

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "status") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        date <- (map["date"], StringTransform())
        status <- (map["status"], StringTransform())
        timePeriod <- map["timePeriod"]

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Status else { return false }

        return date == object.date
            && status == object.status
            && timePeriod == object.timePeriod
    }
}
