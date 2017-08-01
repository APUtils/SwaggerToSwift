//
//  Location.swift
//  <#PROJECT_NAME#>
//
//  Created by mac-246 on 08/01/17.
//  Copyright © 2017 <#COMPANY_NAME#>. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import ObjectMapperAdditions
import RealmSwift
import RealmAdditions


class Location: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var abbreviation: String?
    dynamic var email: String?
    dynamic var phone: String?
    dynamic var country: String?
    dynamic var state: String?
    dynamic var city: String?
    dynamic var neighborhood: String?
    dynamic var addressLine1: String!
    dynamic var addressLine2: String?
    dynamic var postCode: String?
    dynamic var metroArea: String?
    dynamic var website: String?
    dynamic var administrativeCharge: Double = 0
    dynamic var salesTax: Double = 0
    dynamic var cityLatitude: Double = 0
    dynamic var cityLongitude: Double = 0

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "addressLine1") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

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

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Location else { return false }

        return id == object.id
            && name == object.name
            && abbreviation == object.abbreviation
            && email == object.email
            && phone == object.phone
            && country == object.country
            && state == object.state
            && city == object.city
            && neighborhood == object.neighborhood
            && addressLine1 == object.addressLine1
            && addressLine2 == object.addressLine2
            && postCode == object.postCode
            && metroArea == object.metroArea
            && website == object.website
            && administrativeCharge == object.administrativeCharge
            && salesTax == object.salesTax
            && cityLatitude == object.cityLatitude
            && cityLongitude == object.cityLongitude
    }
}
