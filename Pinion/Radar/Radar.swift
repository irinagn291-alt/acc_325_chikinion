import Foundation

/// One arm of the five-axis radar. The mean is computed from Results, not stored on the arm.
/// Pending until five Results exist, then held on one arm, then open once that arm clears.
enum AxisLock: Hashable, Equatable, Codable, Sendable {
    case pending
    case held(Axis)
    case open

    var heldAxis: Axis? {
        if case .held(let axis) = self { return axis }
        return nil
    }
}

struct RadarArm: Hashable, Equatable, Codable, Identifiable, Sendable {
    var axis: Axis
    var id: Axis { axis }

    static let five: [RadarArm] = Axis.allCases.map { RadarArm(axis: $0) }
}

struct ArmMean: Equatable, Sendable {
    var axis: Axis
    var sum: Int
    var count: Int

    var milli: Int {
        guard count > 0 else { return 0 }
        return (sum * 1000) / count
    }
}

/// Weakest-arm spotlight and the roll-speed step.
enum Radar {
    static let samplesBeforeSpotlight = 5

    static func means(for results: [Result]) -> [ArmMean] {
        Axis.allCases.map { axis in
            let points = results.filter { $0.axis == axis }.map(\.grade.points)
            return ArmMean(axis: axis, sum: points.reduce(0, +), count: points.count)
        }
    }

    /// Nil until five Results exist. Ties break in axis order, precision first.
    static func weakest(in results: [Result]) -> Axis? {
        guard results.count >= samplesBeforeSpotlight else { return nil }
        return ranked(results).first?.axis
    }

    /// Holds one arm from the fifth Result until that arm's mean exceeds the next-lowest arm.
    /// A fresh ranking cannot clear, because the minimum never exceeds the second minimum.
    static func advance(_ lock: AxisLock, results: [Result]) -> AxisLock {
        guard results.count >= samplesBeforeSpotlight else { return .pending }
        if case .open = lock { return .open }
        let order = ranked(results)
        guard let lowest = order.first, order.count > 1 else { return .pending }
        let held: Axis
        if case .held(let axis) = lock {
            held = axis
        } else {
            held = lowest.axis
        }
        let mine = order.first { $0.axis == held }?.milli ?? 0
        let other = order.first { $0.axis != held }?.milli ?? 0
        if mine > other { return .open }
        return .held(held)
    }

    /// Two of the last three grades at S step up. Two D grades step down.
    static func adapt(bounds: RollBounds, recent: [Grade]) -> RollBounds {
        let tail = recent.suffix(3)
        guard tail.count == 3 else { return bounds.clamped() }
        let top = tail.filter(\.isTop).count
        let bottom = tail.filter { $0 == .d }.count
        if top >= 2 { return bounds.stepped(by: 1) }
        if bottom >= 2 { return bounds.stepped(by: -1) }
        return bounds.clamped()
    }

    static func recentGrades(on axis: Axis, results: [Result]) -> [Grade] {
        results.filter { $0.axis == axis }.map(\.grade)
    }

    private static func ranked(_ results: [Result]) -> [ArmMean] {
        means(for: results).sorted { lhs, rhs in
            if lhs.milli != rhs.milli { return lhs.milli < rhs.milli }
            return lhs.axis.tieRank < rhs.axis.tieRank
        }
    }
}
