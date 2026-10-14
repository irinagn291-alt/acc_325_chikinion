import Foundation

/// Speed detent and the bounds Settings can tighten. Adaptive steps stay inside the bounds.
struct RollBounds: Hashable, Equatable, Codable, Sendable {
    var floor: Int
    var ceiling: Int
    var detent: Int

    static let opening = RollBounds(floor: 2, ceiling: 6, detent: 3)

    func clamped() -> RollBounds {
        var copy = self
        if copy.floor > copy.ceiling {
            swap(&copy.floor, &copy.ceiling)
        }
        if copy.floor < 1 { copy.floor = 1 }
        if copy.ceiling > 12 { copy.ceiling = 12 }
        if copy.detent < copy.floor { copy.detent = copy.floor }
        if copy.detent > copy.ceiling { copy.detent = copy.ceiling }
        return copy
    }

    func stepped(by delta: Int) -> RollBounds {
        var copy = clamped()
        copy.detent += delta
        return copy.clamped()
    }
}

/// One generated drill on the lane. Sealed is the recorded case after a Result is filed.
struct Drill: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var prompt: Prompt
    var phase: DrillPhase
    var pinMarks: [PinMark]
    var skewMarks: [SkewMark]
    var earlyMarks: [EarlyMark]
    var resultID: UUID?

    var hadFault: Bool { !skewMarks.isEmpty || !earlyMarks.isEmpty }
}

enum DrillPhase: String, Codable, Sendable {
    case rolling
    case pinned
    case sealed
}

/// A sitting of drills. The lane folds these; an empty list is Bare.
struct Session: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var drillIDs: [UUID]
}
