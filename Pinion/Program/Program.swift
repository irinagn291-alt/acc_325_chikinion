import Foundation

/// Axis-emphasis preset in the local library. Not a course.
struct Program: Hashable, Equatable, Codable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var emphasis: Axis
}
