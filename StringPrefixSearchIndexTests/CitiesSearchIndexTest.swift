//
//  Created by mohamed mohamed El Dehairy on 2/14/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import XCTest
import CoreLocation

final class PrefixSearchMock: PrefixSearchAlgorithm {
    var onFindAll: ((_ prefix: String) -> [SearchableByString])?
    
    func setList(array: [SearchableByString]) { }
    
    func findAll(WithPrefix prefix: String) -> [SearchableByString] {
        return onFindAll?(prefix) ?? []
    }
}

final class PrefixSearchAlgorithmProviderMock: PrefixSearchAlgorithmProvider {
    var prefixSearch: PrefixSearchAlgorithm?
    func create() -> PrefixSearchAlgorithm {
        return prefixSearch ?? PrefixSearchMock()
    }
}

class CitiesSearchIndexTest: XCTestCase {

    func test_searchIndex_return_expected_list() {
        let testCities = getTestCities()
        
        let algorithmMock = PrefixSearchMock()
        let algorithmProvider = PrefixSearchAlgorithmProviderMock()
        algorithmProvider.prefixSearch = algorithmMock
        let sut = StringPrefixSearchIndex(list: testCities, searchAlgorithmProvider: algorithmProvider)
        
        let expectation = XCTestExpectation(description: "expect PrefixSearchMock.findAll() and CitiesSearchIndex.findAll() completion to be calles")
        expectation.expectedFulfillmentCount = 2
        
        algorithmMock.onFindAll = { prefix in
            XCTAssertEqual(prefix, "str")
            expectation.fulfill()
            return [CityModel(id: 1, countryCode: "code1", name: "name1", location: CLLocation(latitude: CLLocationDegrees(1), longitude: CLLocationDegrees(1)))]
        }
        sut.findAll(withPrefix: "str") { result in
            XCTAssertTrue(Thread.isMainThread)
            let expectedResult = [CityModel(id: 1, countryCode: "code1", name: "name1", location: CLLocation(latitude: CLLocationDegrees(1), longitude: CLLocationDegrees(1)))]
            XCTAssertEqual(result as! [CityModel], expectedResult)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    private func getTestCities() -> [CityModel] {
        return [CityModel(id: 1, countryCode: "code1", name: "name1", location: CLLocation(latitude: CLLocationDegrees(1), longitude: CLLocationDegrees(1)))
            , CityModel(id: 2, countryCode: "code2", name: "name2", location: CLLocation(latitude: CLLocationDegrees(2), longitude: CLLocationDegrees(2)))
            , CityModel(id: 3, countryCode: "code3", name: "name3", location: CLLocation(latitude: CLLocationDegrees(3), longitude: CLLocationDegrees(3)))]
    }
    
    func test_parallel_calls_to_findAll_is_serialized() {
        let algorithmMock = PrefixSearchMock()
        let algorithmProvider = PrefixSearchAlgorithmProviderMock()
        algorithmProvider.prefixSearch = algorithmMock
        let sut = StringPrefixSearchIndex(list: [], searchAlgorithmProvider: algorithmProvider)
        
        var expectations = [XCTestExpectation]()
        
        (0...40).forEach { index in
            let expectation = XCTestExpectation(description: "wait for findAll() call number \(index)")
            expectations.append(expectation)
            sut.findAll(withPrefix: "ewfew") { _ in
                expectation.fulfill()
            }
        }
        
        wait(for: expectations, timeout: 10, enforceOrder: true)
    }

}
