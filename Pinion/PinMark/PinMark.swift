import Foundation

/// Match inside the open window. Folds Rolling to Pinned.
struct PinMark: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var drillID: UUID
    var tick: Int
}
