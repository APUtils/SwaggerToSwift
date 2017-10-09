//
//  Card.swift
//  SwaggerToSwift
//
//  Created by Anton Plebanovich on 10/09/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Card: Mappable, Describable {
    var brand: String?
    var funding: String?
    var last4: String?
    var name: String?
    var addressZip: String?

    init(brand: String? = nil, funding: String? = nil, last4: String? = nil, name: String? = nil, addressZip: String? = nil) {
        self.brand = brand
        self.funding = funding
        self.last4 = last4
        self.name = name
        self.addressZip = addressZip
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        brand <- (map["brand"], StringTransform())
        funding <- (map["funding"], StringTransform())
        last4 <- (map["last4"], StringTransform())
        name <- (map["name"], StringTransform())
        addressZip <- (map["addressZip"], StringTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.brand == rhs.brand
            && lhs.funding == rhs.funding
            && lhs.last4 == rhs.last4
            && lhs.name == rhs.name
            && lhs.addressZip == rhs.addressZip
    }
}
