//
//  Card.swift
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


class Card: Object, Mappable {
    dynamic var brand: String?
    dynamic var funding: String?
    dynamic var last4: String?
    dynamic var name: String?
    dynamic var addressZip: String?

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        brand <- (map["brand"], StringTransform())
        funding <- (map["funding"], StringTransform())
        last4 <- (map["last4"], StringTransform())
        name <- (map["name"], StringTransform())
        addressZip <- (map["addressZip"], StringTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Card else { return false }

        return brand == object.brand
            && funding == object.funding
            && last4 == object.last4
            && name == object.name
            && addressZip == object.addressZip
    }
}
