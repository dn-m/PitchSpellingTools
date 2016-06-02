//
//  NodeResource.swift
//  PitchSpellingTools
//
//  Created by James Bean on 6/2/16.
//
//

import Pitch

internal struct NodeResource {
    
    private var resource: [Pitch: [Node]]
    
    /// `true` if all `Nodes` have been ranked. Otherwise, `false`.
    var allNodesHaveBeenRanked: Bool {
        for (_, nodes) in resource {
            for node in nodes {
                if node.rank == nil { return false }
            }
        }
        return true
    }
    
    // init with an array of Pitches or a PitchSet
    /// - warning: this is currently assuming we don't want unconventional enharmonics
    /// (e.g., (c flat), (b sharp), (d double sharp), etc)
    init<S: SequenceType where S.Generator.Element == Pitch>(pitches: S) {
        self.resource = pitches.reduce([:]) { (dict, pitch) in
            var dict = dict
            dict[pitch] = pitch.spellingsWithoutUnconventionalEnharmonics.map { spelling in
                Node(pitch: pitch, spelling: spelling)
            }
            return dict
        }
    }
    
    subscript (pitch: Pitch) -> [Node]? {
        return resource[pitch]
    }
}