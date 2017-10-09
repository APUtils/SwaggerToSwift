//
//  TimePeriod.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct TimePeriod: Mappable, Describable {
    var id: String!
    var name: String!
    var startTime: String!
    var endTime: String!

    init(id: String? = nil, name: String? = nil, startTime: String? = nil, endTime: String? = nil) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "startTime") else { return nil }
        guard map.assureValuePresent(forKey: "endTime") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        startTime <- (map["startTime"], StringTransform())
        endTime <- (map["endTime"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension TimePeriod: Equatable {
    static func ==(lhs: TimePeriod, rhs: TimePeriod) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.startTime == rhs.startTime
            && lhs.endTime == rhs.endTime
    }
}
