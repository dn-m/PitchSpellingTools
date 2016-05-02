//
//  PitchSpellingsTests.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/2/16.
//
//

import XCTest
import Pitch
@testable import PitchSpellingTools

class PitchSpellingsTests: XCTestCase {

    func testDefaultPitchSpellingsForEighthToneResolution() {
        Float(0).stride(to: 12.0, by: 0.25).forEach {
            XCTAssertNotNil(PitchSpellings.defaultSpelling(forPitchClass: $0))
        }
    }
    
    func testMiddleCPitchSpelling() {
        XCTAssertEqual(
            PitchSpellings.defaultSpelling(forPitchClass: Pitch.MiddleC.pitchClass)!,
            PitchSpelling(letterName: .C, coarse: .Natural, fine: .None)
        )
    }
}
