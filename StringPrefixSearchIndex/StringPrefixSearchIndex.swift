//
//  Created by mohamed mohamed El Dehairy on 2/14/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import Foundation

protocol PrefixSearchAlgorithmProvider {
    func create() -> PrefixSearchAlgorithm
}

struct DefaultPrefixSearchAlgorithmProvider: PrefixSearchAlgorithmProvider {
    func create() -> PrefixSearchAlgorithm {
        return PrefixBinarySearchAlgorithm()
    }
}

final class StringPrefixSearchIndex {
    private let searchAlgorithmProvider: PrefixSearchAlgorithmProvider
    private let queue = DispatchQueue(label: "serial_queue")
    private var searchAlgorithms: [PrefixSearchAlgorithm] = []

    init(list: [SearchableByString], searchAlgorithmProvider: PrefixSearchAlgorithmProvider) {
        self.searchAlgorithmProvider = searchAlgorithmProvider
        self.prepare(list: list)
    }

    private func prepare(list: [SearchableByString]) {
        queue.async {[weak self] in
            self?._prepare(list: list)
        }
    }

    private func _prepare(list: [SearchableByString]) {
        let size = 10000
        for i in stride(from: 0, to: list.count, by: size) {
            let rangeEnd = min(list.endIndex, i + size)
            let slice = Array(list[i..<rangeEnd])
            let algorithm = searchAlgorithmProvider.create()
            algorithm.setList(array: slice)
            searchAlgorithms.append(algorithm)
        }
    }

    func findAll(withPrefix prefix: String, completion: @escaping (([SearchableByString]) -> Void)) {
        queue.async { [weak self] in
            self?._findAll(withPrefix: prefix, completion: completion)
        }
    }

    private func _findAll(withPrefix prefix: String, completion: @escaping (([SearchableByString]) -> Void)) {
        let concurrentQueue = DispatchQueue(label: "conurrentQueue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem)
        
        var result = [SearchableByString]()
        let group = DispatchGroup()
        for algorithm in searchAlgorithms {
            group.enter()
            concurrentQueue.async {
                let found = algorithm.findAll(WithPrefix: prefix)
                concurrentQueue.async(flags: .barrier) {
                    result.append(contentsOf: found)
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion(result)
        }
    }
}
