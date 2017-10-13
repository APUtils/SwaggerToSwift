# SwaggerToSwift

This repository contains two bash command files to generate [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) models or [Realm](https://realm.io/docs/swift/latest/) with ObjectMapper models from [Swagger](https://swagger.io/) spec.

## Usage

Check Source/Models for generated example ObjectMapper models or Source/RealmModels for Realm with ObjectMapper models.

To generate ObjectMapper models just run `makeModels.command`. To generate Realm with ObjectMapper models run `makeRealmModels.command`. By default it uses `swagger.json` file from same directory but you could pass other filename.

```
$ bash makeModels.sh --help
Swagger JSON spec to Swift ObjectMapper models converter

./makeModels.sh
    -h    --help                    Show help
    -f    --file                    Swagger spec JSON file name. Default - 'swagger.json'.
    -o    --output-dir              Models output directory. Default - same as script file location.
    -mp   --model-prefix            Models prefix. Default - no prefix.
    -t    --type-casting-enabled    Enable type casting? Default - true.
    -mn   --model-name              Specify concrete model name to parse.
    -de   --describable-enabled     Add Describable protocol conformance? Default - true.
    -a    --assert-values           Add value assertion checks? Only asserts mandatory values. Default - true.
    -p    --project-name            Project name for header. Default - <#PROJECT_NAME#>.
    -u    --user-name               Company name for header. Default - $USER or git user name.
    -c    --company-name            Company name for header. Default - <#COMPANY_NAME#>.
```

```
$ bash makeRealmModels.sh --help
Swagger JSON spec to Swift ObjectMapper models converter

./makeModels.sh
    -h    --help                    Show help
    -f    --file                    Specify swagger spec JSON file name. Default - 'swagger.json'.
    -o    --output-dir              Models output directory. Default - same as script file location.
    -t    --type-casting-enabled    Enable type casting? Default - true.
    -a    --assert-values           Add value assertion checks? Only asserts mandatory values. Default - true.
    -oi    --override-isEqual       Override Realm implementation of objects equality with properties comparison? Default - true.
    -p    --project-name            Project name for header. Default - <#PROJECT_NAME#>.
    -u    --user-name               Company name for header. Default - $USER or git user name.
    -c    --company-name            Company name for header. Default - <#COMPANY_NAME#>.
```

You can view/edit sample spec or create your own in [Swagger Editor](http://editor.swagger.io/)

## Example

Source JSON object:

```json
{
  "Room1": {
    "type": "object",
    "required": [
      "id",
      "name",
      "location",
      "date",
      "prices",
      "statuses"
    ],
    "properties": {
      "id": {
        "type": "string"
      },
      "name": {
        "type": "string"
      },
      "minAttendees": {
        "type": "number"
      },
      "maxAttendees": {
        "type": "number"
      },
      "location": {
        "$ref": "#/definitions/Location"
      },
      "images": {
        "type": "array",
        "items": {
          "type": "string"
        }
      },
      "date": {
        "type": "string"
      },
      "prices": {
        "type": "array",
        "items": {
          "$ref": "#/definitions/Price"
        }
      },
      "statuses": {
        "type": "array",
        "items": {
          "$ref": "#/definitions/Status"
        }
      }
    }
  }
}
```

### ObjectMapper

Simpliest possible model (type_casting_enabled=false, describable_enabled=false, assert_values=false):

```swift
struct Room1: Mappable {
    var id: String?
    var name: String?
    var minAttendees: Double?
    var maxAttendees: Double?
    var location: Location?
    var images: [String]?
    var date: String?
    var prices: [Price]?
    var statuses: [Status]?

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        minAttendees <- map["minAttendees"]
        maxAttendees <- map["maxAttendees"]
        location <- map["location"]
        images <- map["images"]
        date <- map["date"]
        prices <- map["prices"]
        statuses <- map["statuses"]
    }
}
```

Model with type casting enabled (type_casting_enabled=true, describable_enabled=false, assert_values=false):

```swift
struct Room1: Mappable {
    var id: String?
    var name: String?
    var minAttendees: Double?
    var maxAttendees: Double?
    var location: Location?
    var images: [String]?
    var date: String?
    var prices: [Price]?
    var statuses: [Status]?

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], StringTransform())
        date <- (map["date"], StringTransform())
        prices <- map["prices"]
        statuses <- map["statuses"]
    }
}
```

All options enabled:

```swift
struct Room1: Mappable, Describable {
    var id: String!
    var name: String!
    var minAttendees: Double?
    var maxAttendees: Double?
    var location: Location!
    var images: [String]?
    var date: String!
    var prices: [Price]!
    var statuses: [Status]!

    init() {}

    init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "prices") else { return nil }
        guard map.assureValuePresent(forKey: "statuses") else { return nil }
    }

    mutating func mapping(map: Map) {
        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], StringTransform())
        date <- (map["date"], StringTransform())
        prices <- map["prices"]
        statuses <- map["statuses"]
    }
}
```

### Realm

Simpliest possible model (type_casting_enabled=false, assert_values=false, override_isEqual=false):

```swift
class Room1: Object, Mappable {
    dynamic var id: String?
    dynamic var name: String?
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var location: Location?
    var images: List<RealmString> = List<RealmString>()
    dynamic var date: String?
    var prices: List<Price> = List<Price>()
    var statuses: List<Status> = List<Status>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- map["id"]
        name <- map["name"]
        minAttendees <- map["minAttendees"]
        maxAttendees <- map["maxAttendees"]
        location <- map["location"]
        images <- (map["images"], RealmTransform<RealmString>())
        date <- map["date"]
        prices <- (map["prices"], ListTransform<Price>())
        statuses <- (map["statuses"], ListTransform<Status>())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }
}
```

Model with type casting enabled (type_casting_enabled=true, assert_values=false, override_isEqual=false):

```swift
class Room1: Object, Mappable {
    dynamic var id: String?
    dynamic var name: String?
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var location: Location?
    var images: List<RealmString> = List<RealmString>()
    dynamic var date: String?
    var prices: List<Price> = List<Price>()
    var statuses: List<Status> = List<Status>()

    required convenience init?(map: Map) { self.init() }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], RealmTypeCastTransform<RealmString>())
        date <- (map["date"], StringTransform())
        prices <- (map["prices"], ListTransform<Price>())
        statuses <- (map["statuses"], ListTransform<Status>())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }
}
```

All options enabled:

```swift
class Room1: Object, Mappable {
    dynamic var id: String!
    dynamic var name: String!
    dynamic var minAttendees: Double = 0
    dynamic var maxAttendees: Double = 0
    dynamic var location: Location!
    var images: List<RealmString> = List<RealmString>()
    dynamic var date: String!
    var prices: List<Price> = List<Price>()
    var statuses: List<Status> = List<Status>()

    required convenience init?(map: Map) {
        guard map.assureValuePresent(forKey: "id") else { return nil }
        guard map.assureValuePresent(forKey: "name") else { return nil }
        guard map.assureValuePresent(forKey: "location") else { return nil }
        guard map.assureValuePresent(forKey: "date") else { return nil }
        guard map.assureValuePresent(forKey: "prices") else { return nil }
        guard map.assureValuePresent(forKey: "statuses") else { return nil }

        self.init()
    }

    func mapping(map: Map) {
        let isWriteRequired = realm != nil && realm?.isInWriteTransaction == false
        isWriteRequired ? realm?.beginWrite() : ()

        id <- (map["id"], StringTransform())
        name <- (map["name"], StringTransform())
        minAttendees <- (map["minAttendees"], DoubleTransform())
        maxAttendees <- (map["maxAttendees"], DoubleTransform())
        location <- map["location"]
        images <- (map["images"], RealmTypeCastTransform<RealmString>())
        date <- (map["date"], StringTransform())
        prices <- (map["prices"], ListTransform<Price>())
        statuses <- (map["statuses"], ListTransform<Status>())

        isWriteRequired ? try? realm?.commitWrite() : ()
    }

    //-----------------------------------------------------------------------------
    // MARK: - Equatable
    //-----------------------------------------------------------------------------

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Room1 else { return false }

        return id == object.id
            && name == object.name
            && minAttendees == object.minAttendees
            && maxAttendees == object.maxAttendees
            && location == object.location
            && images == object.images
            && date == object.date
            && prices == object.prices
            && statuses == object.statuses
    }
}
```

## Contributions

Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Author

Anton Plebanovich, anton.plebanovich@gmail.com

## License

SwaggerToSwift is available under the MIT license. See the LICENSE file for more info.
