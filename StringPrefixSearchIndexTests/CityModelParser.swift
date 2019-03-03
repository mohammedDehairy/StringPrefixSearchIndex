//
//  Created by mohamed mohamed El Dehairy on 2/13/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import UIKit
import CoreLocation

func parseCityModels(json: [[String: Any]]) -> [CityModel] {
    var result = [CityModel]()
    for cityJson in json {
        guard let id = cityJson["_id"] as? Int else { continue }
        guard let name = cityJson["name"] as? String else { continue }
        guard let code = cityJson["country"] as? String else { continue }
        guard let coordinate = cityJson["coord"] as? [String: Any] else { continue }
        guard let lon = coordinate["lon"] as? Double else { continue }
        guard let lat = coordinate["lat"] as? Double else { continue }
        result.append(CityModel(id: id, countryCode: code, name: name, location: CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))))
    }
    return result
}
