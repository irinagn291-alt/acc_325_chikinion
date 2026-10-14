import Foundation

/// Roll asked for an axis other than the locked weakest arm. The roll is refused.
struct LockMark: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var requested: Axis
    var locked: Axis
    var day: Int
}
