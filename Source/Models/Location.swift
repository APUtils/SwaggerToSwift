//
//  Location.swift
//  SwaggerToSwift
//
//  Created by Anton Plebanovich on 10/09/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation
import APExtensions
import ObjectMapper
import ObjectMapperAdditions


struct Location: Mappable, Describable {
    var id: String!
    var name: String!
    var abbreviation: String?
    var email: String?
    var phone: String?
    var country: String?
    var state: String?
    var city: String?
    var neighborhood: String?
    var addressLine1: String!
    var addressLine2: String?
    var postCode: String?
    var metroArea: String?
    var website: String?
    var administrativeCharge: Double?
    var salesTax: Double?
    var cityLatitude: Double?
    var cityLongitude: Double?

    init(id: String? = nil, name: String? = nil, abbreviation: String? = nil, email: String? = nil, phone: String? = nil, country: String? = nil, state: String? = nil, city: String? = nil, neighborhood: String? = nil, addressLine1: String? = nil, addressLine2: String? = nil, postCode: String? = nil, metroArea: String? = nil, website: String? = nil, administrativeCharge: Double? = nil, salesTax: Double? = nil, cityLatitude: Double? = nil, cityLongitude: Double? = nil) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.email = email
        self.phone = phone
        self.country = country
        self.state = state
        self.city = city
        self.neighborhood = neighborhood
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.postCode = postCode
        self.metroArea = metroArea
        self.website = website
        self.administrativeCharge = administrativeCharge
        self.salesTax = salesTax
        self.cityLatitude = cityLatitude
        self.cityLongitude = cityLongitude
    }

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "addressLine1") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        abbreviation <- (map["abbreviation"], StringTransform())
        email <- (map["email"], StringTransform())
        phone <- (map["phone"], StringTransform())
        country <- (map["country"], StringTransform())
        state <- (map["state"], StringTransform())
        city <- (map["city"], StringTransform())
        neighborhood <- (map["neighborhood"], StringTransform())
        addressLine1 <- (map["addressLine1"], StringTransform())
        addressLine2 <- (map["addressLine2"], StringTransform())
        postCode <- (map["postCode"], StringTransform())
        metroArea <- (map["metroArea"], StringTransform())
        website <- (map["website"], StringTransform())
        administrativeCharge <- (map["administrativeCharge"], DoubleTransform())
        salesTax <- (map["salesTax"], DoubleTransform())
        cityLatitude <- (map["cityLatitude"], DoubleTransform())
        cityLongitude <- (map["cityLongitude"], DoubleTransform())
    }
}

//-----------------------------------------------------------------------------
// MARK: - Equatable
//-----------------------------------------------------------------------------

extension Location: Equatable {
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.abbreviation == rhs.abbreviation
            && lhs.email == rhs.email
            && lhs.phone == rhs.phone
            && lhs.country == rhs.country
            && lhs.state == rhs.state
            && lhs.city == rhs.city
            && lhs.neighborhood == rhs.neighborhood
            && lhs.addressLine1 == rhs.addressLine1
            && lhs.addressLine2 == rhs.addressLine2
            && lhs.postCode == rhs.postCode
            && lhs.metroArea == rhs.metroArea
            && lhs.website == rhs.website
            && lhs.administrativeCharge == rhs.administrativeCharge
            && lhs.salesTax == rhs.salesTax
            && lhs.cityLatitude == rhs.cityLatitude
            && lhs.cityLongitude == rhs.cityLongitude
    }
}
