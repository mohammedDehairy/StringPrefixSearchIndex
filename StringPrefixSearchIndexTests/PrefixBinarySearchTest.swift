//
//  Created by mohamed mohamed El Dehairy on 2/13/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import XCTest

struct SearchableByStringMock: SearchableByString {
    var searchableString: String
}

class PrefixBinarySearchTest: XCTestCase {

    func test_find_all_strings_with_prefix() {
        let testList = ["Alabama", "Alaska", "Albania", "SSLV | Demo 2", "SSLV | Demo 1", "Smart", "Egypt", "Ethiopia", "USA", "Uganda", "Uganda", "uganda"].map { name in
            return SearchableByStringMock(searchableString: name)
        }
        let sut = PrefixBinarySearchAlgorithm(array: testList)
        let result1 = sut.findAll(WithPrefix: "aL").map { $0.searchableString }
        let expectedList1 = ["Alabama", "Alaska", "Albania"].sorted()
        XCTAssertEqual(result1, expectedList1)
        
        let result2 = sut.findAll(WithPrefix: "E").map { $0.searchableString }
        let expectedList2 = ["Egypt", "Ethiopia"].sorted()
        XCTAssertEqual(result2, expectedList2)
        
        let result3 = sut.findAll(WithPrefix: "SS").map { $0.searchableString }
        let expectedList3 = ["SSLV | Demo 2", "SSLV | Demo 1"].sorted()
        XCTAssertEqual(result3, expectedList3)
        
        let result4 = sut.findAll(WithPrefix: "U").map { $0.searchableString }
        let expectedList4 = ["USA", "Uganda", "Uganda", "uganda"].sorted()
        XCTAssertEqual(result4, expectedList4)
        
        let result5 = sut.findAll(WithPrefix: "x").map { $0.searchableString }
        XCTAssertEqual(result5, [])
        
        let result6 = sut.findAll(WithPrefix: "").map { $0.searchableString }
        let expectedList6 = ["Alabama", "Alaska", "Albania", "SSLV | Demo 2", "SSLV | Demo 1", "Smart", "Egypt", "Ethiopia", "USA", "Uganda", "Uganda", "uganda"].sorted()
        XCTAssertEqual(result6, expectedList6)
    }
    
    func test_measure_find_all_strings_with_prefix() {
        let citiesList = getCitiesList()
        let sut = PrefixBinarySearchAlgorithm(array: citiesList)
        measure {
            _ = sut.findAll(WithPrefix: "a")
        }
    }

    // MARK: - Helper functions
    
    func getCitiesList() -> [SearchableByString] {
        let jsonFilePath = Bundle(for: PrefixBinarySearchTest.self).path(forResource: "cities", ofType: "json")!
        let url = URL(fileURLWithPath: jsonFilePath)
        let data = try! Data(contentsOf: url)
        
        let jsonObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [[String: Any]]
        
        return parseCityModels(json: jsonObject)
    }
    
    func getTestString() -> [String] {
        let string = "In two weeks we’ll present a paper on the Dynamo technology at SOSP, the prestigious biannual Operating Systems conference. Dynamo is internal technology developed at Amazon to address the need for an incrementally scalable, highly-available key-value storage system. The technology is designed to give its users the ability to trade-off cost, consistency, durability and performance, while maintaining high-availability.Let me emphasize the internal technology part before it gets misunderstood: Dynamo is not directly exposed externally as a web service; however, Dynamo and similar Amazon technologies are used to power parts of our Amazon Web Services, such as S3.We submitted the technology for publication in SOSP because many of the techniques used in Dynamo originate in the operating systems and distributed systems research of the past years; DHTs, consistent hashing, versioning, vector clocks, quorum, anti-entropy based recovery, etc. As far as I know Dynamo is the first production system to use the synthesis of all these techniques, and there are quite a few lessons learned from doing so. The paper is mainly about these lessons.We are extremely fortunate that the paper was selected for publication in SOSP; only a very few true production systems have made it into the conference and as such it is a recognition of the quality of the work that went into building a real incrementally scalable storage system in which the most important properties can be appropriately configured.Dynamo is representative of a lot of the work that we are doing at Amazon; we continuously develop cutting edge technologies using recent research, and in many cases do the research ourselves. Much of the engineering work at Amazon, whether it is in infrastructure, distributed systems, workflow, rendering, search, digital, similarities, supply chain, shipping or any of the other systems, is equally highly advanced.Reliability at massive scale is one of the biggest challenges we face at Amazon.com, one of the largest e-commerce operations in the world; even the slightest outage has significant financial consequences and impacts customer trust. The Amazon-com platform, which provides services for many web sites worldwide, is implemented on top of an infrastructure of tens of thousands of servers and network components located in many datacenters around the world. At this scale, small and large components fail continuously and the way persistent state is managed in the face of these failures drives the reliability and scalability of the software systems.This paper presents the design and implementation of Dynamo, a highly available key-value storage system that some of Amazon’s core services use to provide an “always-on” experience.  To achieve this level of availability, Dynamo sacrifices consistency under certain failure scenarios. It makes extensive use of object versioning and application-assisted conflict resolution in a manner that provides a novel interface for developers to use.Amazon runs a world-wide e-commerce platform that serves tens of millions customers at peak times using tens of thousands of servers located in many data centers around the world. There are strict operational requirements on Amazon’s platform in terms of performance, reliability and efficiency, and to support continuous growth the platform needs to be highly scalable. Reliability is one of the most important requirements because even the slightest outage has significant financial consequences and impacts customer trust. In addition, to support continuous growth, the platform needs to be highly scalable.One of the lessons our organization has learned from operating Amazon’s platform is that the reliability and scalability of a system is dependent on how its application state is managed. Amazon uses a highly decentralized, loosely coupled, service oriented architecture consisting of hundreds of services. In this environment there is a particular need for storage technologies that are always available. For example, customers should be able to view and add items to their shopping cart even if disks are failing, network routes are flapping, or data centers are being destroyed by tornados. Therefore, the service responsible for managing shopping carts requires that it can always write to and read from its data store, and that its data needs to be available across multiple data centers.Dealing with failures in an infrastructure comprised of millions of components is our standard mode of operation; there are always a small but significant number of server and network components that are failing at any given time. As such Amazon’s software systems need to be constructed in a manner that treats failure handling as the normal case without impacting availability or performance.To meet the reliability and scaling needs, Amazon has developed a number of storage technologies, of which the Amazon Simple Storage Service (also available outside of Amazon and known as Amazon S3), is probably the best known. This paper presents the design and implementation of Dynamo, another highly available and scalable distributed data store built for Amazon’s platform. Dynamo is used to manage the state of services that have very high reliability requirements and need tight control over the tradeoffs between availability, consistency, cost-effectiveness and performance. Amazon’s platform has a very diverse set of applications with different storage requirements. A select set of applications requires a storage technology that is flexible enough to let application designers configure their data store appropriately based on these tradeoffs to achieve high availability and guaranteed performance in the most cost effective manner.There are many services on Amazon’s platform that only need primary-key access to a data store. For many services, such as those that provide best seller lists, shopping carts, customer preferences, session management, sales rank, and product catalog, the common pattern of using a relational database would lead to inefficiencies and limit scale and availability. Dynamo provides a simple primary-key only interface to meet the requirements of these applications.Dynamo uses a synthesis of well known techniques to achieve scalability and availability: Data is partitioned and replicated using consistent hashing [10], and consistency is facilitated by object versioning [12]. The consistency among replicas during updates is maintained by a quorum-like technique and a decentralized replica synchronization protocol. Dynamo employs a gossip based distributed failure detection and membership protocol. Dynamo is a completely decentralized system with minimal need for manual administration. Storage nodes can be added and removed from Dynamo without requiring any manual partitioning or redistribution.In the past year, Dynamo has been the underlying storage technology for a number of the core services in Amazon’s e-commerce platform. It was able to scale to extreme peak loads efficiently without any downtime during the busy holiday shopping season. For example, the service that maintains shopping cart (Shopping Cart Service) served tens of millions requests that resulted in well over 3 million checkouts in a single day and the service that manages session state handled hundreds of thousands of concurrently active sessions.The main contribution of this work for the research community is the evaluation of how different techniques can be combined to provide a single highly-available system. It demonstrates that an eventually-consistent storage system can be used in production with demanding applications. It also provides insight into the tuning of these techniques to meet the requirements of production systems with very strict performance demands.The paper is structured as follows. Section 2 presents the background and Section 3 presents the related work. Section 4 presents the system design and Section 5 describes the implementation. Section 6 details the experiences and insights gained by running Dynamo in production and Section 7 concludes the paper. There are a number of places in this paper where additional information may have been appropriate but where protecting Amazon’s business interests require us to reduce some level of detail. For this reason, the intra- and inter-datacenter latencies in section 6, the absolute request rates in section 6.2 and outage lengths and workloads in section 6.3 are provided through aggregate measures instead of absolute details."
        return normalise(stringList: string.components(separatedBy: CharacterSet(charactersIn: ",.")))
    }
    
    func normalise(stringList : [String]) -> [String]{
        let filteredStringList = stringList.filter { !$0.isEmpty }
        
        let stringsSet = Set(filteredStringList)
        return Array(stringsSet)
    }
}
