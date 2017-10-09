//
//  Receipt.swift
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


class Receipt: Object, Mappable {
    dynamic var id: String!
    dynamic var reservation: Reservation!
    dynamic var card: Card!

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "reservation") else { return nil }
        guard map.assureValuePresent(forKey: "card") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        reservation <- map["reservation"]
        card <- map["card"]

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Receipt else { return false }

        return id == object.id
            && reservation == object.reservation
            && card == object.card
    }
}
