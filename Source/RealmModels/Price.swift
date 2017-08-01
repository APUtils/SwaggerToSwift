//
//  Price.swift
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


class Price: Object, Mappable {
    dynamic var date: String!
    dynamic var price: Double = 0
    dynamic var timePeriod: TimePeriod!

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        date <- (map["date"], StringTransform())
        price <- (map["price"], DoubleTransform())
        timePeriod <- map["timePeriod"]

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Price else { return false }

        return date == object.date
            && price == object.price
            && timePeriod == object.timePeriod
    }
}
