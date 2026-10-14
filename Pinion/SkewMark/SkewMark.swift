import Foundation

/// Pin while Rolling but the live Digit was not the Prompt. The reel stays Rolling.
struct SkewMark: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var drillID: UUID
    var tick: Int
    var digit: Digit
}
