//
//  Status.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Status: Mappable, Describable {
    var date: String!
    var status: String!
    var timePeriod: TimePeriod!

    init(date: String? = nil, status: String? = nil, timePeriod: TimePeriod? = nil) {
        self.date = date
        self.status = status
        self.timePeriod = timePeriod
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "status") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }
    }

    mutating func mapping(map: Map) {
        date <- (map["date"], StringTransform())
        status <- (map["status"], StringTransform())
        timePeriod <- map["timePeriod"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Status: Equatable {
    static func ==(lhs: Status, rhs: Status) -> Bool {
        return lhs.date == rhs.date
            && lhs.status == rhs.status
            && lhs.timePeriod == rhs.timePeriod
    }
}
