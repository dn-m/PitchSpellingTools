//
//  RelativeNamedIntervalTests.swift
//  PitchSpellingTools
//
//  Created by James Bean on 1/8/17.
//
//

import XCTest
import Pitch
import PitchSpellingTools

class RelativeNamedIntervalTests: XCTestCase {

    typealias Ordinal = RelativeNamedInterval.Ordinal
    
    func testUnisonPerfectNotImperfect() {
        let unison = Ordinal.unison
        XCTAssert(Ordinal.perfects.contains(unison))
        XCTAssertFalse(Ordinal.imperfects.contains(unison))
    }
    
    func testSecondImperfectNotImperfect() {
        let second = Ordinal.second
        XCTAssert(Ordinal.imperfects.contains(second))
        XCTAssertFalse(Ordinal.perfects.contains(second))
    }
    
    func testSecondOrdinalInverseSeventh() {
        XCTAssertEqual(Ordinal.second.inverse, Ordinal.fourth)
    }
    
    func testInverseMajorThirdMinorThird() {
        let M3 = RelativeNamedInterval(.major, .third)
        let m3 = RelativeNamedInterval(.minor, .third)
        XCTAssertEqual(M3.inverse, m3)
    }
    
    func testInverseAugmentedFourthDiminishedSecond() {
        let A4 = RelativeNamedInterval(.augmented, .fourth)
        let d2 = RelativeNamedInterval(.diminished, .second)
        XCTAssertEqual(A4.inverse, d2)
        XCTAssertEqual(d2.inverse, A4)
    }
    
    func testInitUnisonSamePitchClass() {
        let a = SpelledPitchClass(0, PitchSpelling(.c))
        let b = SpelledPitchClass(0, PitchSpelling(.c))
        let result = RelativeNamedInterval(a,b)
        let expected = RelativeNamedInterval(.perfect, .unison)
        XCTAssertEqual(result, expected)
    }
    
    func testCASharpAugmentedSixthDiminishedThird() {
        let a = SpelledPitchClass(0, PitchSpelling(.c))
        let b = SpelledPitchClass(10, PitchSpelling(.a, .sharp))
        let result = RelativeNamedInterval(a,b)
        let expected = RelativeNamedInterval(.diminished, .third)
        XCTAssertEqual(result, expected)
    }
    
    func testDFSharpMajorThird() {
        let a = SpelledPitchClass(2, PitchSpelling(.d))
        let b = SpelledPitchClass(6, PitchSpelling(.f, .sharp))
        let result = RelativeNamedInterval(a,b)
        let expected = RelativeNamedInterval(.major, .third)
        XCTAssertEqual(result, expected)
    }
    
    func testBFlatDSharpAugmentedThird() {
        let a = SpelledPitchClass(10, PitchSpelling(.b, .flat))
        let b = SpelledPitchClass(3, PitchSpelling(.d, .sharp))
        let result = RelativeNamedInterval(a,b)
        let expected = RelativeNamedInterval(.augmented, .third)
        XCTAssertEqual(result, expected)
    }
}
