//
//  UserInfo.swift
//  SwaggerToSwift
//
//  Created by mac-246 on 10/09/17.
//  Copyright © 2017 Anton Plebanovich. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjectMapper_Realm
import ObjectMapperAdditions
import RealmSwift
import RealmAdditions


class UserInfo: Object, Mappable {
    dynamic var id: String!
    dynamic var firstName: String!
    dynamic var lastName: String?
    dynamic var email: String?
    dynamic var phone: String?

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "firstName") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        firstName <- (map["firstName"], StringTransform())
        lastName <- (map["lastName"], StringTransform())
        email <- (map["email"], StringTransform())
        phone <- (map["phone"], StringTransform())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? UserInfo else { return false }

        return id == object.id
            && firstName == object.firstName
            && lastName == object.lastName
            && email == object.email
            && phone == object.phone
    }
}
