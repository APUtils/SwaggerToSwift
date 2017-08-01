//
//  Billing.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Billing: Mappable, Describable {
    var id: String!
    var company: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        company <- (map["company"], StringTransform())
        address <- (map["address"], StringTransform())
        city <- (map["city"], StringTransform())
        state <- (map["state"], StringTransform())
        zipCode <- (map["zipCode"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Billing: Equatable {
    static func ==(lhs: Billing, rhs: Billing) -> Bool {
        return lhs.id == rhs.id
            && lhs.company == rhs.company
            && lhs.address == rhs.address
            && lhs.city == rhs.city
            && lhs.state == rhs.state
            && lhs.zipCode == rhs.zipCode
    }
}