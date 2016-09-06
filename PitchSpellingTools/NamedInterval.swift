//
//  NamedInterval.swift
//  PitchSpellingTools
//
//  Created by James Bean on 8/9/16.
//
//

import ArithmeticTools
import Pitch

/**
 NamedInterval.
 
 **Example:**
 
 ```
 let perfectUnison = NamedInterval(.perfect, .unison)!
 let augmentedFifth = NamedInterval(.augmented, .fifth)!
 let doubleAugmentedSeventh = NamedInterval(.double, .augmented, .seventh)!
 let _ = NamedInterval(.major, .fourth) // nil
 ```
 
 - TODO: Create names for quarter-step and eighth-step modified intervals
 
 - TODO: Consider creating better names for `family` / `Family`. Traditionally, `class` is
    used; however, `class` is a reserved keyword in Swift.
 
 - TODO: Use actual specialized `Interval` and `IntervlClass` value types, as opposed to
    throwing anonymous `Float` values around.
 */
public struct NamedInterval {
    
    /**
     `Quality` of a `NamedInterval`.
     
     - TODO: Add documentation!
     */
    public struct Quality: OptionSet, CustomStringConvertible {
        
        /**
         `Degree` of a `Quality` (e.g., `double augmented second`).
         
         - note: Only applicable for `.augmented` and `.diminished` values.
        */
        public enum Degree: Int {
            case quintuple = 5
            case quadruple = 4
            case triple = 3
            case double = 2
            case single = 1
        }
        
        // MARK: - Cases
        
        /// Diminished `Quality`
        public static let diminished = Quality(rawValue: -2)
        
        /// Minor `Quality`.
        public static let minor = Quality(rawValue: -1)
        
        /// Perfect `Quality`.
        public static let perfect = Quality(rawValue: 0)
        
        /// Major `Quality`.
        public static let major = Quality(rawValue: 1)
        
        /// Augmented `Quality`.
        public static let augmented = Quality(rawValue: 2)
        
        // MARK: - Sets by interval ordinal family
        
        fileprivate static let perfectSet: Quality = [diminished, perfect, augmented]
        fileprivate static let imperfectSet: Quality = [diminished, minor, major, augmented]
        
        // MARK: - Instance Properties
        
        /**
         Inverse of a `Quality`
         (e.g., `.major.inverse == .minor`, `.perfect.inverse == .perfect`, etc).
         
         - TODO: Make table of inverse `Quality` pairs.
        */
        public var inverse: Quality {
            return Quality(rawValue: -1 * rawValue, degree: degree)
        }
        
        /// Raw value of a `Quality`.
        public let rawValue: Int
        
        /// Degree of a `Quality`.
        public let degree: Degree
        
        // MARK: - Initializers
        
        /**
         Create a `NamedInterval.Quality`.
         */
        public init(rawValue: Int) {
            self.rawValue = rawValue
            self.degree = .single
        }
        
        /**
         Create a `NamedInterval.Quality` with a degree.
         */
        fileprivate init(rawValue: Int, degree: Degree) {
            self.rawValue = rawValue
            self.degree = degree
        }
        
        // MARK: - Subscripts
        
        /**
         - returns: Quality with the given `degree` if `.diminished` or `.augmented`. 
         Otherwise, `nil`.
         */
        public subscript (degree: Degree) -> Quality? {
            switch (degree, self) {
            case (.single, _), (_, Quality.diminished), (_, Quality.augmented):
                return Quality(rawValue: rawValue, degree: degree)
            default:
                return nil
            }
        }
        
        // MARK: - Instance methods
        
        /**
         - returns: `true` if this `Quality` is valid for a given `Ordinal`. Otherwise, `false`.
        
         > One cannot have a major fifth, etc.
         
         - TODO: Flesh out documentation.
         */
        public func isValid(for ordinal: Ordinal) -> Bool {
            switch ordinal.family {
            case .perfect where Quality.perfectSet.contains(self): return true
            case .imperfect where Quality.imperfectSet.contains(self): return true
            default: return false
            }
        }
        
        // MARK: - CustomStringConvertible
        
        /// Printed description.
        public var description: String {
            var quality: String {
                switch self {
                case Quality.diminished: return "diminished"
                case Quality.minor: return "minor"
                case Quality.perfect: return "perfect"
                case Quality.major: return "major"
                case Quality.augmented: return "augmented"
                default: fatalError() // don't match `perfectSet` and `imperfectSet`
                }
            }
            return degree == .single ? quality : "\(degree) \(quality)"
        }
    }
    
    /**
     - returns: `Quality` for the given `normalizedIntervalClass` value, and the given 
     `ordinal` value.
     
     - TODO: Find more elegant way to do this. This implementation & api exists only
     - TODO: Factor out duplication in multiply diminished / augmented cases
     - TODO: Handle bad values properly. Currently things can blow up in extreme cases. Test.
     */
    public static func quality(for normalizedIntervalClass: Float, ordinal: Ordinal)
        -> Quality
    {
        let diminished: Float = ordinal.family == .perfect ? -1 : -1.5
        let augmented: Float = ordinal.family == .perfect ? 1 : 1.5
        
        switch normalizedIntervalClass {
        case _ where normalizedIntervalClass < diminished:
            let degreeValue = Int(abs(normalizedIntervalClass - diminished - 1))
            let degree = Quality.Degree(rawValue: degreeValue)!
            return Quality.diminished[degree]!
        case diminished: return Quality.diminished
        case -0.5: return Quality.minor
        case +0.0: return Quality.perfect
        case +0.5: return Quality.major
        case augmented: return Quality.augmented
        case _ where normalizedIntervalClass > augmented:
            let degreeValue = Int(abs(normalizedIntervalClass - augmented + 1))
            let degree = Quality.Degree(rawValue: degreeValue)!
            return Quality.augmented[degree]!
        default: fatalError() // impossible
        }
    }

    // MARK: - Instance Properties
    
    /**
     Inverse of a `NamedInterval`.
     
     - TODO: Add examples to documentation.
     - TODO: Make table of inverse relationship pairs.
    */
    public var inverse: NamedInterval {
        return NamedInterval(quality.inverse, ordinal.inverse)!
    }
    
    /// Ordinal of a `NamedInterval` (e.g., `.unison`, `.fifth`, `.seventh`, etc.).
    public let ordinal: Ordinal
    
    /// Quality of a `NamedInterval` (e.g., `.perfect`, `.augmented`, `.minor`, etc.).
    public let quality: Quality
    
    // MARK: - Initializers
    
    /**
     Create a `NamedInterval` with a given `quality` and an `ordinal`.
     
     - TODO: Add examples to documentation.
     */
    public init?(_ quality: Quality, _ ordinal: Ordinal) {
        guard quality.isValid(for: ordinal) else { return nil }
        self.quality = quality
        self.ordinal = ordinal
    }
    
    /**
     Create a `NamedInterval` with a `degree`, `quality`, and `ordinal`.
     
     - TODO: Add examples to documentation.
     */
    public init?(_ degree: Quality.Degree, _ quality: Quality, _ ordinal: Ordinal) {
        print("degree: \(degree)")
        print("quality: \(quality)")
        guard let quality = quality[degree] else { return nil }
        self.init(quality, ordinal)
    }

    /**
     Create a `NamedInterval` with two `SpelledPitch` values.
     */
    public init(_ a: SpelledPitch, _ b: SpelledPitch) {
        print("a: \(a); b: \(b)")
        let letterNameSteps = steps(a,b)
        let ideal = idealIntervalClass(steps: letterNameSteps)
        let normalized = normalizedIntervalClass(interval(a,b) - ideal)
        let intervalClass = adjustedIntervalClass(normalized, steps: letterNameSteps)
        print("intervalClass: \(intervalClass)")
        self.init(steps: letterNameSteps, intervalClass: intervalClass)!
    }
    
    /// - warning: Not yet documented!
    public init(_ a: PitchSpelling, _ b: PitchSpelling) {
        let a = SpelledPitch(Pitch(noteNumber: NoteNumber(a.pitchClass)), a)
        let b = SpelledPitch(Pitch(noteNumber: NoteNumber(b.pitchClass)), b)
        self.init(a,b)
    }
    
    /**
     Helper initializer that gathers the ordinal and quality from the given `steps` and 
        `intervalClass`.
     */
    fileprivate init?(steps: Int, intervalClass: Float) {
        guard let ordinal = NamedInterval.Ordinal(rawValue: steps) else { return nil }
        print("ordianal: \(ordinal)")
        let quality = NamedInterval.quality(for: intervalClass, ordinal: ordinal)
        print("quality: \(quality)")
        self.init(quality, ordinal)
    }
}

/// - returns: Delta between letter name steps of two `SpelledPitch` values.
fileprivate func steps(_ a: SpelledPitch, _ b: SpelledPitch) -> Int {
    return Int.mod(b.spelling.letterName.steps - a.spelling.letterName.steps, 7)
}
/**
 - returns: Delta between pitch noteNumber values
 
 - TODO: Return `Interval` rather than `Float`.
 */
fileprivate func interval(_ a: SpelledPitch, _ b: SpelledPitch) -> Float {
    return b.pitch.noteNumber.value - a.pitch.noteNumber.value
}

/**
 - returns: The given `intervalClass`, enforcing positive values if there is a `unison`
 relationship.
 */
private func adjustedIntervalClass(_ intervalClass: Float, steps: Int) -> Float {
    return steps == 0 ? abs(intervalClass) : intervalClass
}

/**
 - returns: The given `normalizedInterval`, in `IntervalClass` form (mod 12),
 
 - TODO: Return `IntervalClass` instead of `Float`.
 */
private func normalizedIntervalClass(_ normalizedInterval: Float)  -> Float {
    return Float.mod(normalizedInterval + 6.0, 12.0) - 6.0
}

/**
 - returns: The ideal interval class for the given `steps`.
 */
private func idealIntervalClass(steps: Int) -> Float {
    let steps = Int.mod(steps, 4) // remove fifths, sixths, sevenths
    var idealInterval: Float {
        switch steps {
        case 0: return 0
        case 1: return 1.5
        case 2: return 3.5
        case 3: return 5
        default: fatalError()
        }
    }
    return idealInterval
}

extension NamedInterval: CustomStringConvertible {
    
    // MARK: - CustomStringConvertible
    
    /// Printed description.
    public var description: String {
        return "\(quality) \(ordinal)"
    }
}

// MARK: - Equatable

extension NamedInterval: Equatable { }

/**
 - returns: `true` if `ordinal` and `quality` values are equivalent. Otherwise, `false`.
 */
public func == (lhs: NamedInterval, rhs: NamedInterval) -> Bool {
    return (
        lhs.ordinal == rhs.ordinal &&
        lhs.quality == rhs.quality &&
        lhs.quality.degree == rhs.quality.degree
    )
}
