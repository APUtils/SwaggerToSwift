//
//  Payment.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Payment: Mappable, Describable {
    var id: String!
    var token: String!

    init(id: String? = nil, token: String? = nil) {
        self.id = id
        self.token = token
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "token") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        token <- (map["token"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Payment: Equatable {
    static func ==(lhs: Payment, rhs: Payment) -> Bool {
        return lhs.id == rhs.id
            && lhs.token == rhs.token
    }
}
