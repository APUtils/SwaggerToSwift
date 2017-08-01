//
//  UserInfo.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct UserInfo: Mappable, Describable {
    var id: String!
    var firstName: String!
    var lastName: String?
    var email: String?
    var phone: String?

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "firstName") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        firstName <- (map["firstName"], StringTransform())
        lastName <- (map["lastName"], StringTransform())
        email <- (map["email"], StringTransform())
        phone <- (map["phone"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension UserInfo: Equatable {
    static func ==(lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.id == rhs.id
            && lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.email == rhs.email
            && lhs.phone == rhs.phone
    }
}
