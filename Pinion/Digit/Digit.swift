import Foundation

/// Live odometer face. Roll advances it one step at a time; Pin compares it to Prompt.
struct Digit: Hashable, Equatable, Sendable {
    let value: Int

    init?(value: Int) {
        guard (0...9).contains(value) else { return nil }
        self.value = value
    }

    /// Bucket is reduced modulo ten, so a generated draw always lands on a face.
    static func drawn(from bucket: UInt64) -> Digit {
        Digit(trusted: Int(bucket % 10))
    }

    static let zero = Digit(trusted: 0)

    func advanced() -> Digit {
        Digit(trusted: (value + 1) % 10)
    }

    /// Caller already proved the face is inside 0...9.
    private init(trusted: Int) {
        self.value = trusted
    }
}

extension Digit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(Int.self)
        guard let digit = Digit(value: raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Digit is outside 0...9"
            )
        }
        self = digit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
