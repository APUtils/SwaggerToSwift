//
//  Price.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Price: Mappable, Describable {
    var date: String!
    var price: Double!
    var timePeriod: TimePeriod!

    init(date: String? = nil, price: Double? = nil, timePeriod: TimePeriod? = nil) {
        self.date = date
        self.price = price
        self.timePeriod = timePeriod
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "price") else { return nil }
        guard map.assureValuePresent(forKey: "timePeriod") else { return nil }
    }

    mutating func mapping(map: Map) {
        date <- (map["date"], StringTransform())
        price <- (map["price"], DoubleTransform())
        timePeriod <- map["timePeriod"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Price: Equatable {
    static func ==(lhs: Price, rhs: Price) -> Bool {
        return lhs.date == rhs.date
            && lhs.price == rhs.price
            && lhs.timePeriod == rhs.timePeriod
    }
}
