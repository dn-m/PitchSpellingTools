//
//  PitchClassSetSpeller.swift
//  PitchSpellingTools
//
//  Created by James Bean on 8/24/16.
//
//

import ArrayTools
import Pitch

// MARK: - Typealiases

/// Single `PitchSpelling` value.
typealias Node = PitchSpelling

/// Pair of `PitchSpelling` values.
typealias Edge = (PitchSpelling, PitchSpelling)

/// All `PitchSpelling` values comprising a graph.
typealias Graph = [PitchSpelling]

/// Defintion of a spelling rule that takes a cost multiplier and an input, returning a cost.
///
/// The cost multiplier can be used within the closure to worsen the penalty depending on 
/// more or less egregious offences.
///
/// The `Input` can be any of the following:
/// - `Node` (aka `PitchSpelling`)
/// - `Edge` (aka `(PitchSpelling, PitchSpelling)`)
/// - `Graph` (aka `[PitchSpelling]`)
typealias Rule<Input> = (Float) -> (Input) -> Float

// MARK: - Node-level rules

let doubleSharpOrDoubleFlat: Rule<Node> = { costMultiplier in
    return { spelling in abs(spelling.quarterStep.rawValue) == 2 ? 1 : 0 }
}

let threeQuarterSharpOrThreeQuarterFlat: Rule<Node> = { costMultiplier in
    return { spelling in abs(spelling.quarterStep.rawValue) == 1.5 ? 1 : 0 }
}

let badEnharmonic: Rule<Node> = { costMultiplier in
    return { spelling in
        switch (spelling.letterName, spelling.quarterStep) {
        case (.b, .sharp), (.e, .sharp), (.c, .flat), (.f, .flat): return 1 * costMultiplier
        default: return 0
        }
    }
}

let quarterStepEighthStepCombination: Rule<Node> = { costMultiplier in
    return { spelling in
        switch (spelling.quarterStep.resolution, abs(spelling.eighthStep.rawValue)) {
        case (.quarterStep, 0.25): return 1
        default: return 0
        }
    }
}

// MARK: - Edge-level rules

let unison: Rule<Edge> = { costMultiplier in
    return { (a,b) in a.letterName == b.letterName ? 1 : 0 }
}

let augmentedOrDiminished: Rule<Edge> = { costMultiplier in
    return { (a,b) in
        switch NamedInterval(a,b).quality {
        case NamedInterval.Quality.augmented, NamedInterval.Quality.diminished: return 1
        default: return 0
        }
    }
}

let crossover: Rule<Edge> = { costMultiplier in
    return { (a,b) in
        return (a.letterName.steps < b.letterName.steps) != (a.pitchClass < b.pitchClass)
            ? 1
            : 0
    }
}

/// - TODO: Consider merging this into augmented / diminished
let flatSharpIncompatibility: Rule<Edge> = { costMultiplier in
    return { (a,b) in
        return a.quarterStep.direction.rawValue * b.quarterStep.direction.rawValue == -1
            ? 1
            : 0
    }
}

// MARK: - Graph-level rules

// FIXME: The graph-level looping should not be implemented within here.
// - In fact, this is actually an edge rule that has no "double jeopardy".
let eighthStepDirectionIncompatibility: Rule<Edge> = { costMultiplier in
    return { (a,b) in
        switch (a.eighthStep.rawValue, b.eighthStep.rawValue) {
        case (0, _), (_, 0), (-0.25, -0.25), (0.25, 0.25): return 0
        default: return 1
        }
    }
}

// MARK: - Rule collections

// Rules for individual spellings out of context
let nodeRules: [(Node) -> Float] = [
    doubleSharpOrDoubleFlat(1),
    badEnharmonic(1),
    quarterStepEighthStepCombination(1),
    threeQuarterSharpOrThreeQuarterFlat(1),
]

// Rules for which n-jeopardy may be applied
let edgeRules: [(Edge) -> Float] = [
    unison(1.0),
    augmentedOrDiminished(1.0),
    crossover(1.0),
    flatSharpIncompatibility(1.0)
]

// Rules for which double-jeopardy is not applied
let graphRules: [(Edge) -> Float] = [
    eighthStepDirectionIncompatibility(1.0)
]

// MARK: - Cost functions

// Node cost
func cost<A>(_ a: A, _ rules: [(A) -> Float]) -> Float {
    return rules.reduce(0) { $0 + $1(a) }
}

/// Cost of a single spelling in relationship to all of the other nodes in a graph
func cost(_ a: Node, _ graph: Graph, _ rules: [(Edge) -> Float]) -> Float {
    return graph.reduce(0) { $0 + cost((a,$1), rules) }
}

/// Graph cost (no double jeopardy applied)
func cost(_ graph: Graph, _ rules: [(Edge) -> Float]) -> Float {
    for ai in graph.indices {
        let a = graph[ai]
        for bi in ai + 1 ..< graph.endIndex {
            let b = graph[bi]
            let cost = rules.reduce(0) { $0 + $1(a,b) }
            if cost > 0 { return cost }
       }
    }
    return 0
}

public struct PitchClassSetSpeller {

    private let costThreshold: Float
    private var bestGraphs: [Graph] = []
    private let pitchClassSet: PitchClassSet
    
    // make an optional init for rules
    public init(_ pitchClassSet: PitchClassSet, costThreshold: Float = 100) {
        self.pitchClassSet = pitchClassSet
        self.costThreshold = costThreshold
    }
    
    public func spell() -> SpelledPitchClassSet {
        
        struct SpellingContext {
            let spelling: PitchSpelling
            let totalCost: Float
            let nodeEdgeCost: Float
        }
        
        func traverseToSpell(
            _ pitchClasses: [PitchClass],
            graph: Graph,
            accumCost: Float,
            nodeEdgeCost: Float
        ) -> SpelledPitchClassSet
        {
            guard let (pitchClass, remaining) = pitchClasses.destructured else {
                return SpelledPitchClassSet()
            }

            enum CostError: Error { case thresholdExceeded }
            
            func incrementTotalCost(_ totalCost: inout Float, with cost: Float) throws {
                totalCost += cost
                guard totalCost < costThreshold else { throw CostError.thresholdExceeded }
            }
            
            let spellingContexts: [SpellingContext] = pitchClass.spellings.flatMap { spelling in
                
                var totalCost = accumCost
                
                do {
                    let nodeCost = cost(spelling, nodeRules)
                    try incrementTotalCost(&totalCost, with: nodeCost)
                    let edgeCost = cost(spelling, graph, edgeRules)
                    try incrementTotalCost(&totalCost, with: edgeCost)
                    
                    // temporary graph -- later graph with probably have ref semantics
                    var tempGraph = graph
                    tempGraph.append(spelling)
                    let graphCost = cost(tempGraph, graphRules)
                    try incrementTotalCost(&totalCost, with: graphCost)
                    
                    let spellingContext = SpellingContext(
                        spelling: spelling,
                        totalCost: totalCost,
                        nodeEdgeCost: nodeCost + edgeCost
                    )
                    
                    tempGraph.removeLast()
                    //spellingContexts.append(spellingContext)
                    return spellingContext
                    
                } catch {
                    return nil
                }
            }
            
            print("spelling contexts: ---")
            spellingContexts.forEach { print($0) }
            
            guard !spellingContexts.isEmpty else {
                fatalError()
                // TODO: throw error
            }
            
            for context in spellingContexts.sorted(by: { $0.totalCost < $1.totalCost }) {
                if context.totalCost < costThreshold {
                    let nodeEdgeCost = context.nodeEdgeCost + nodeEdgeCost
                    var graph = graph
                    graph.append(context.spelling)
                    
                    print("remaining: \(remaining)")
                    
                    return traverseToSpell(
                        remaining,
                        graph: graph,
                        accumCost: accumCost,
                        nodeEdgeCost: nodeEdgeCost
                    )
                } else { continue }
            }

            fatalError()
        }
        
        let pitchClasses = Array(pitchClassSet)
        return traverseToSpell(pitchClasses, graph: [], accumCost: 0, nodeEdgeCost: 0)
    }
}
