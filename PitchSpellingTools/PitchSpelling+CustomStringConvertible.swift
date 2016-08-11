//
//  PitchSpelling+CustomStringConvertible.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/3/16.
//
//

import Foundation

extension PitchSpelling: CustomStringConvertible {
    
    public var description: String {
        var result = "("
        result += "\(letterName)"
        if quarterStep != .natural { result += " \(quarterStep)" }
        if eighthStep != .none { result += " \(eighthStep)" }
        result += ")"
        return result
    }
}
