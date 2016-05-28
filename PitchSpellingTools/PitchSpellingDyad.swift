//
//  PitchSpellingDyad.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/2/16.
//
//

import ArithmeticTools

/**
 Pair of two `PitchSpellings objects.
 */
public struct PitchSpellingDyad {

    internal let a: PitchSpelling
    internal let b: PitchSpelling

    /**
    `true` if `coarse` values of both `PitchSpelling` objects are equivalent.
     Otherwise `false`.
     */
    public var isCoarseMatching: Bool { return b.coarse == a.coarse }
    
    public var isCoarseCompatible: Bool { return eitherIsNatural || isCoarseMatching }
    
    /**
    `true` if `coarse.direction` values of both `PitchSpelling` objects are equivalent.
     Otherwise `false`.
     */
    public var isCoarseDirectionMatching: Bool {
        return b.coarse.direction == a.coarse.direction
    }
    
    public var isCoarseDirectionCompatible: Bool {
        return eitherIsNatural || isCoarseDirectionMatching
    }
    
    public var isCoarseResolutionMatching: Bool {
        return b.coarse.resolution == a.coarse.resolution
    }
    
    public var isCoarseResolutionCompatible: Bool {
        return eitherIsNatural || isCoarseResolutionMatching
    }
    
    private var eitherIsNatural: Bool { return b.coarse == .natural || a.coarse == .natural }
    
    /**
     `true if `fine` values of `PitchSpelling` objects are equivalent. Otherwise `false`..
     */
    public var isFineMatching: Bool { return b.fine == a.fine }
    
    public var isFineCompatible: Bool {
        if b.fine == .none || a.fine == .none { return true }
        return isFineMatching
    }
    
    public var isStepPreserving: Bool { return intervalQuality.isStepPreserving }
    
    /// Mean of `distance` values of both `PitchSpelling` objects.
    public var meanSpellingDistance: Float {
        return [b.spellingDistance, a.spellingDistance].mean!
    }
    
    /// Amount of steps between two `PitchSpelling` objects.
    public var steps: Int {
        let difference = a.letterName.steps - b.letterName.steps
        return abs(Int.mod(difference, 7))
    }

    /// `IntervalQuality` between `PitchSpelling` objects.
    public var intervalQuality: IntervalQualityKind {
        return IntervalQuality.kind(forPitchSpellingDyad: self)
    }
    
    /**
     Create a `PitchSpellingDyad` with two `PitchSpelling` objects.
     */
    public init(_ b: PitchSpelling, _ a: PitchSpelling) {
        self.b = b
        self.a = a
    }
}

extension PitchSpellingDyad: Hashable {
    
    public var hashValue: Int { return b.hashValue * a.hashValue }
}

extension PitchSpellingDyad: Equatable { }

public func == (lhs: PitchSpellingDyad, rhs: PitchSpellingDyad) -> Bool {
    return lhs.b == rhs.b && lhs.a == rhs.a
}
