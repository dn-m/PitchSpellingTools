//
//  PitchTests.swift
//  Pitch
//
//  Created by James Bean on 3/12/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import XCTest
@testable import Pitch

class PitchTests: XCTestCase {
    
    func testInitWithPitch() {
        let original = Pitch(noteNumber: 60)
        let new = Pitch(pitch: original)
        XCTAssertEqual(original, new)
    }
}
