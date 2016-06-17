//
//  Iterate.swift
//  EnumTools
//
//  Created by James Bean on 2/24/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import Foundation

/**
 Iterate over an Enum type.
 
 ```
 for instrumentKind in iterateEnum(InstrumentKind) { ... }
 ```
 
 - TODO: Embed in a `SequenceType` conforming structure:
 
 >```
 >let allCases: [InstrumentKind] = iterateEnum(InstrumentKind).map { $0 }
 >```
 
 - TODO: Add extension to `RawRepresentable` types to generate `allCases` innately:
 
 >```
 >let allCases = InstrumentKind.allCases
 >```
 
 - authors: [rintaro](http://stackoverflow.com/users/3804019/rintaro) / [kemetrixom](http://stackoverflow.com/users/3443689/kametrixom) @ [Stackoverflow](http://stackoverflow.com/a/28341290).
 
 - parameter _: Enum type.
 
 - returns: Next case of given Enum type. `nil` once last case has been reached.
 */
public func iterateEnum<T: Hashable>(_: T.Type) -> AnyGenerator<T> {
    var i = 0
    return AnyGenerator {
        let next = withUnsafePointer(&i) { UnsafePointer<T>($0).memory }
        defer { i += 1 }
        return next.hashValue == i ? next : nil
    }
}