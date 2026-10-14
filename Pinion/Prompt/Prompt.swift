import Foundation

/// Command-row target. Roll writes one Prompt for one axis; Pin reads it against the live Digit.
struct Prompt: Hashable, Equatable, Codable, Sendable {
    var digit: Digit
    var axis: Axis
}

/// Five skill arms. Tie breaks follow this order when means match.
enum Axis: String, Codable, CaseIterable, Identifiable, Sendable {
    case precision
    case speed
    case rhythm
    case control
    case endurance

    var id: String { rawValue }

    var tieRank: Int {
        switch self {
        case .precision: 0
        case .speed: 1
        case .rhythm: 2
        case .control: 3
        case .endurance: 4
        }
    }
}
