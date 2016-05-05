//
//  HalfToneDyadSpeller.swift
//  PitchSpellingTools
//
//  Created by James Bean on 5/5/16.
//
//

import Pitch

public class HalfToneDyadSpeller: DyadSpeller {
    
    /**
     <#Description#>
     
     - returns: <#return value description#>
     */
    public override func spell() -> Result {
        let stepPreserving = allPitchSpellingDyads.filter { $0.isStepPreserving }
        switch stepPreserving.count {
        case 0: return .none
        case 1: return .single(stepPreserving.first!)
        default: return .multiple(stepPreserving.sort { $0.meanDistance < $1.meanDistance })
        }
    }
}