//
//  SpelledDyad.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/12/16.
//
//

import Collections
import ArithmeticTools

/// Dyad of `SpelledPitch` values.
public struct SpelledDyad {
    
    // MARK: - Instance Properties
    
    /// Lower of the two `SpelledPitch` values.
    public let lower: SpelledPitch
    
    /// Higher of the two `SpelledPitch` values.
    public let higher: SpelledPitch
    
    /// - returns: Relative named interval, which does not ordering of `SpelledPitch` values
    /// contained herein.
    public var relativeInterval: RelativeNamedInterval {
        
        // TODO: Make convenience init
        let lowerSPC = SpelledPitchClass(lower.pitch.pitchClass, lower.spelling)
        let higherSPC = SpelledPitchClass(higher.pitch.pitchClass, higher.spelling)
        
        return RelativeNamedInterval(lowerSPC, higherSPC)
    }
    
    /// - returns: Absolute named interval, which honors ordering of `SpelledPitch` values
    /// contained herein.
    public var absoluteInterval: AbsoluteNamedInterval {
        fatalError()
    }
    
    // MARK: - Initializers
    
    /// Create a `SpelledDyad` with two `SpelledPitch` values.
    public init(_ lower: SpelledPitch, _ higher: SpelledPitch) {
        let (lower, higher) = ordered(lower, higher)
        self.lower = lower
        self.higher = higher
    }
}
