//
//  Booking.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Booking: Mappable, Describable {
    var id: String!
    var reservation: Reservation!
    var billing: Billing!
    var payment: Payment!
    var userInfo: UserInfo!

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "reservation") else { return nil }
        guard map.assureValuePresent(forKey: "billing") else { return nil }
        guard map.assureValuePresent(forKey: "payment") else { return nil }
        guard map.assureValuePresent(forKey: "userInfo") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        reservation <- map["reservation"]
        billing <- map["billing"]
        payment <- map["payment"]
        userInfo <- map["userInfo"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Booking: Equatable {
    static func ==(lhs: Booking, rhs: Booking) -> Bool {
        return lhs.id == rhs.id
            && lhs.reservation == rhs.reservation
            && lhs.billing == rhs.billing
            && lhs.payment == rhs.payment
            && lhs.userInfo == rhs.userInfo
    }
}
