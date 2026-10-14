import Foundation

/// Grades a PinMark by which third of the open window held it, or files a miss when the window ends still Rolling.
enum Seal {
    /// Window opens on tick 1 (the second tick) and stays open for three ticks: 1, 2, and 3.
    static let windowOpensOnTick = 1
    static let windowLength = 3

    static var windowClosesOnTick: Int { windowOpensOnTick + windowLength }

    static func windowIsOpen(tick: Int) -> Bool {
        tick >= windowOpensOnTick && tick < windowClosesOnTick
    }

    static func third(for tick: Int) -> Int? {
        guard windowIsOpen(tick: tick) else { return nil }
        return tick - windowOpensOnTick
    }

    /// First third is S, second is A, third is B.
    static func grade(forPinTick tick: Int) -> Grade? {
        guard let third = third(for: tick) else { return nil }
        switch third {
        case 0: return .s
        case 1: return .a
        default: return .b
        }
    }

    /// No mark is C. EarlyMark or SkewMark is D.
    static func missGrade(hadFault: Bool) -> Grade {
        hadFault ? .d : .c
    }
}
