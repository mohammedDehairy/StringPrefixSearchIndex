//
//  Created by mohamed mohamed El Dehairy on 2/13/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import Foundation
import CoreLocation

struct CityModel: Equatable, SearchableByString {
    let countryCode: String
    let name: String
    let id: Int
    let location: CLLocation
    var searchableString: String {
        return name
    }
    
    init(id: Int, countryCode: String, name: String, location: CLLocation) {
        self.id = id
        self.location = location
        self.countryCode = countryCode
        self.name = name
    }
    
    public static func == (lhs: CityModel, rhs: CityModel) -> Bool {
        return lhs.id == rhs.id && lhs.countryCode == rhs.countryCode && lhs.name == rhs.name
    }
}
