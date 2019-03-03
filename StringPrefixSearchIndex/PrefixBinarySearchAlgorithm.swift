//
//  Created by mohamed mohamed El Dehairy on 2/13/19.
//  Copyright © 2019 mohamed El Dehairy. All rights reserved.
//

import Foundation

protocol PrefixSearchAlgorithm {
    func setList(array: [SearchableByString])
    func findAll(WithPrefix prefix: String) -> [SearchableByString]
}

public protocol SearchableByString {
    var searchableString: String { get }
}

final public class PrefixBinarySearchAlgorithm: PrefixSearchAlgorithm {
    private var array: [SearchableByString] = []
    
    init(array: [SearchableByString]) {
        self.array = sort(array: array)
    }
    
    convenience init() {
        self.init(array: [])
    }
    
    func setList(array: [SearchableByString]) {
        self.array = sort(array: array)
    }
    
    private func sort(array: [SearchableByString]) -> [SearchableByString] {
        return array.sorted { item1, item2 in
            return item1.searchableString < item2.searchableString
        }
    }
    
    func findAll(WithPrefix prefix: String) -> [SearchableByString] {
        let prefix = prefix.lowercased()
        var startIndex = array.startIndex
        
        // First try to find any item with the desired prefix,
        // then Once an item has been found, we keep searching in a linear fashion
        // upward and downward starting at the found item to get the rest of the items
        // with the same prefix
        
        var endIndex = array.endIndex
        var currentIndex = -1
        var foundItem: SearchableByString?
        while startIndex < endIndex {
            currentIndex = (endIndex + startIndex) / 2
            let currentItem = array[currentIndex]
            if currentItem.searchableString.lowercased().hasPrefix(prefix) {
                foundItem = currentItem
                break
            } else if currentItem.searchableString.lowercased() < prefix {
                startIndex = currentIndex + 1
            } else {
                endIndex = currentIndex - 1
            }
        }
        
        guard let item = foundItem else { return [] }
        var result = [item]
        
        var upIndex = currentIndex + 1
        var downIndex = currentIndex - 1
        
        // search upward
        while upIndex < array.endIndex {
            let upwardItem = array[upIndex]
            guard upwardItem.searchableString.lowercased().hasPrefix(prefix) else {
                break
            }
            result.append(upwardItem)
            upIndex += 1
        }
        
        // search downward
        while downIndex >= 0 {
            let downwardItem = array[downIndex]
            guard downwardItem.searchableString.lowercased().hasPrefix(prefix) else {
                break
            }
            result.append(downwardItem)
            downIndex -= 1
        }
        return sort(array: result)
    }
}
