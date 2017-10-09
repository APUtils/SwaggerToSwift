//
//  Receipt.swift
//  SwaggerToSwift
//
//  Created by Anton Plebanovich on 10/09/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Receipt: Mappable, Describable {
    var id: String!
    var reservation: Reservation!
    var card: Card!

    init(id: String? = nil, reservation: Reservation? = nil, card: Card? = nil) {
        self.id = id
        self.reservation = reservation
        self.card = card
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "reservation") else { return nil }
        guard map.assureValuePresent(forKey: "card") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        reservation <- map["reservation"]
        card <- map["card"]
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Receipt: Equatable {
    static func ==(lhs: Receipt, rhs: Receipt) -> Bool {
        return lhs.id == rhs.id
            && lhs.reservation == rhs.reservation
            && lhs.card == rhs.card
    }
}
