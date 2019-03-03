//
//  Created by mohamed mohamed El Dehairy on 2/14/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import XCTest

class CitiesSearchIndexIntegrationTest: XCTestCase {
    
    func test_perfromance() {
        let sut = StringPrefixSearchIndex(list: getCitiesList(), searchAlgorithmProvider: DefaultPrefixSearchAlgorithmProvider())
        self.measure {
            let expectation = XCTestExpectation(description: "Expect completion to be called")
            sut.findAll(withPrefix: "a") { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Helper functions
    
    func getCitiesList() -> [CityModel] {
        let jsonFilePath = Bundle(for: CitiesSearchIndexIntegrationTest.self).path(forResource: "cities", ofType: "json")!
        let url = URL(fileURLWithPath: jsonFilePath)
        let data = try! Data(contentsOf: url)
        
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [[String: Any]]
        
        return parseCityModels(json: jsonObject)
    }
}
