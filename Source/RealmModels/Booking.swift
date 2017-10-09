//
//  Booking.swift
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


class Booking: Object, Mappable {
    dynamic var id: String!
    dynamic var reservation: Reservation!
    dynamic var billing: Billing!
    dynamic var payment: Payment!
    dynamic var userInfo: UserInfo!

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "reservation") else { return nil }
        guard map.assureValuePresent(forKey: "billing") else { return nil }
        guard map.assureValuePresent(forKey: "payment") else { return nil }
        guard map.assureValuePresent(forKey: "userInfo") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        reservation <- map["reservation"]
        billing <- map["billing"]
        payment <- map["payment"]
        userInfo <- map["userInfo"]

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Booking else { return false }

        return id == object.id
            && reservation == object.reservation
            && billing == object.billing
            && payment == object.payment
            && userInfo == object.userInfo
    }
}
