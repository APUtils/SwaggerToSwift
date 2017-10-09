//
//  Billing.swift
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


class Billing: Object, Mappable {
    dynamic var id: String!
    dynamic var company: String?
    dynamic var address: String?
    dynamic var city: String?
    dynamic var state: String?
    dynamic var zipCode: String?

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        company <- (map["company"], StringTransform())
        address <- (map["address"], StringTransform())
        city <- (map["city"], StringTransform())
        state <- (map["state"], StringTransform())
        zipCode <- (map["zipCode"], StringTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Billing else { return false }

        return id == object.id
            && company == object.company
            && address == object.address
            && city == object.city
            && state == object.state
            && zipCode == object.zipCode
    }
}
