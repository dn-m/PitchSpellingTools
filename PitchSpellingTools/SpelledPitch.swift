//
//  SpelledPitch.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/1/16.
//
//

import Foundation
import Pitch

/**
 Structure that extends a `Pitch` with a `PitchSpelling`.
 */
public struct SpelledPitch {
    
    public let pitch: Pitch
    public let spelling: PitchSpelling
    
    public init(pitch: Pitch, spelling: PitchSpelling) {
        self.pitch = pitch
        self.spelling = spelling
    }
}

extension SpelledPitch: Equatable { }

public func == (lhs: SpelledPitch, rhs: SpelledPitch) -> Bool {
    return lhs.pitch == rhs.pitch
}

extension SpelledPitch: Comparable { }

public func < (lhs: SpelledPitch, rhs: SpelledPitch) -> Bool {
    return lhs.pitch < rhs.pitch
}