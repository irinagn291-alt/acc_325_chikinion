import Foundation

/// Filed grade for one sealed drill. The day is YYYYMMDD from the start of that calendar day.
struct Result: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var drillID: UUID
    var axis: Axis
    var grade: Grade
    var day: Int
}

enum Grade: String, Codable, CaseIterable, Sendable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    /// Radar points. Means are computed from these, never stored.
    var points: Int {
        switch self {
        case .s: 100
        case .a: 80
        case .b: 60
        case .c: 40
        case .d: 20
        }
    }

    var isTop: Bool { self == .s }
}

enum DayStamp {
    static func yyyymmdd(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
