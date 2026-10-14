import Foundation

/// Pin before the window opens. The window opens on the second tick and stays open for three ticks.
struct EarlyMark: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var drillID: UUID
    var tick: Int
}
