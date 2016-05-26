//
//  GraphTests.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/26/16.
//
//

import XCTest
import ArithmeticTools
import Pitch
@testable import PitchSpellingTools

class GraphTests: XCTestCase {

    func testInitWithEmptyPitchSet() {
        let _ = Graph(pitchSet: [])
    }
    
    func testInitWithMonadPitchSet() {
        
        var graph = Graph(
            pitchSet: [
                Pitch(noteNumber: 60)
            ]
        )
        
        XCTAssertEqual(graph.levels.count, 1)
        XCTAssertEqual(graph.allPaths.count, 3)
    }
    
    func testInitWithDyadPitchSet() {
        
        var graph = Graph(
            pitchSet: [
                Pitch(noteNumber: 60),
                Pitch(noteNumber: 67)
            ]
        )
        
        XCTAssertEqual(graph.levels.count, 2)
        XCTAssertEqual(graph.allPaths.count, 9)
    }
    
    func testInitWithTriadPitchSet() {
        
        var graph = Graph(
            pitchSet: [
                Pitch(noteNumber: 60),
                Pitch(noteNumber: 67),
                Pitch(noteNumber: 69)
            ]
        )
        
        XCTAssertEqual(graph.levels.count, 3)
        XCTAssertEqual(graph.allPaths.count, 3 * 3 * 3)
    }
    
    func testInitWithTetrachordWithQuarterTones() {
        
        var graph = Graph(
            pitchSet: [
                Pitch(noteNumber: 60),
                Pitch(noteNumber: 67.5),
                Pitch(noteNumber: 70.5),
                Pitch(noteNumber: 71)
            ]
        )
        
        XCTAssertEqual(graph.levels.count, 4)
        XCTAssertEqual(graph.allPaths.count, 3 * 2 * 2 * 3)
    }
    
    func testPathsCompatibleWithCoarseDirection() {
        
        var graph = Graph(
            pitchSet: [
                Pitch(noteNumber: 60),
                Pitch(noteNumber: 67.5),
                Pitch(noteNumber: 70.5),
                Pitch(noteNumber: 71)
            ]
        )
        let _ = graph.paths(compatibleWithCoarseDirection: .up)
        let _ = graph.paths(compatibleWithFineDirection: .down)
        let _ = graph.paths(
            compatibleWithCoarseDirection: .down,
            compatibleWithFineDirection: .down
        )
    }
}