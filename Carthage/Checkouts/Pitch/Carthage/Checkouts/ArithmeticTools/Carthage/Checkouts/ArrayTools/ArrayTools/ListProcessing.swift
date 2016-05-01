//
//  ListProcessing.swift
//  ArrayTools
//
//  Created by James Bean on 2/22/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

extension Array {
    
    // MARK: - List Processing
    
    /**
     2-tuple containing the `head` `Element` and `tail` `[Element]` of `Self`

     -  note: From Chris Eidhof: http://chris.eidhof.nl/posts/swift-tricks.html
    */
    public var destructured: (Element, [Element])? {
        return count == 0 ? nil : (self.first!, Array(self[1..<self.count]))
    }
}

/**
Construct an `Array` from a `head` and a `tail`

- parameter head: First element of new `Array`
- parameter tail: Array of elements appended after head in new `Array`

- returns: New `Array` with the first element `head`, and the remaining elements of `tail`
*/
public func + <T>(head: T, tail: [T]) -> [T] {
    return [head] + tail
}

/**
Append an element

- parameter list: `Array` to append `item` to
- parameter item: Element to append to `list`

- returns: New `Array` with `item` appended to the end of `list`
*/
public func + <T>(list: [T], item: T) -> [T] {
    return list + [item]
}