//
//  Guest.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 07/17/17.
//  Copyright © 2017 mac-246. All rights reserved.
//

import ObjectMapper


struct Guest: Mappable, Describable {
    var name: String!

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        name <-- map["name"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Guest: Equatable {
    static func ==(lhs: Guest, rhs: Guest) -> Bool {
        return lhs.name == rhs.name
    }
}
