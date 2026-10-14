import SwiftUI

/// Token accessors for the cabinet. Views reach colour, type, space, and radius only through here.
enum ReelColor {
    static let bg = DesignTokens.bg
    static let surface = DesignTokens.surface
    static let ink = DesignTokens.ink
    static let accent = DesignTokens.accent
    static let muted = DesignTokens.muted
}

enum ReelType {
    static let display = Font.custom("DINCondensed-Bold", size: 64, relativeTo: .largeTitle)
    static let title = Font.custom("DINCondensed-Bold", size: 34, relativeTo: .title)
    static let headline = Font.custom("DINCondensed-Bold", size: 22, relativeTo: .headline)
    static let body = Font.custom("DINCondensed-Bold", size: 17, relativeTo: .body)
    static let caption = Font.custom("DINCondensed-Bold", size: 14, relativeTo: .caption)
    static let micro = Font.custom("DINCondensed-Bold", size: 12, relativeTo: .caption2)
}

enum ReelSpace {
    static let unit: CGFloat = 8
    static let s1: CGFloat = 8
    static let s2: CGFloat = 16
    static let s3: CGFloat = 24
    static let s4: CGFloat = 32
    static let s5: CGFloat = 40
    static let s6: CGFloat = 48
    static let hit: CGFloat = 48
    static let digit: CGFloat = 96
    static let art: CGFloat = 240
    static let radar: CGFloat = 160
    static let decor: CGFloat = 56
}

enum ReelRadius {
    static let card: CGFloat = 24
    static let chip: CGFloat = 10
}

enum ReelFormat {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func mean(milli: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.usesGroupingSeparator = false
        let value = Double(milli) / 1000
        return formatter.string(from: NSNumber(value: value)) ?? "0.0"
    }

    /// One filed grade as its radar score, same scale as the arm mean.
    static func score(for grade: Grade) -> String {
        mean(milli: grade.points * 1000)
    }

    /// YYYYMMDD stamp as a calendar date a stranger can read.
    static func filedDay(_ stamp: Int) -> String {
        var parts = DateComponents()
        parts.year = stamp / 10_000
        parts.month = (stamp / 100) % 100
        parts.day = stamp % 100
        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: parts) else { return whole(stamp) }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

extension Axis {
    var plate: String {
        switch self {
        case .precision: "Precision"
        case .speed: "Speed"
        case .rhythm: "Rhythm"
        case .control: "Control"
        case .endurance: "Endurance"
        }
    }
}

/// Filled capsule for the live verb. Destructive is a separate ink plate, used only for reset.
struct ReelPressStyle: ButtonStyle {
    var loading: Bool = false
    var destructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return ReelPressBody(
            pressed: pressed,
            loading: loading,
            destructive: destructive,
            label: configuration.label
        )
    }
}

private struct ReelPressBody<Label: View>: View {
    var pressed: Bool
    var loading: Bool
    var destructive: Bool
    var label: Label
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .font(ReelType.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: ReelSpace.hit)
            .padding(.horizontal, ReelSpace.s2)
            .background(fill, in: Capsule())
            .overlay {
                if loading {
                    ProgressView()
                        .tint(foreground)
                }
            }
            .opacity(pressed && isEnabled ? 0.82 : 1)
            .contentShape(Capsule())
            .animation(.easeOut(duration: 0.2), value: pressed)
    }

    private var foreground: Color {
        if !isEnabled { return ReelColor.muted }
        return destructive ? ReelColor.bg : ReelColor.surface
    }

    private var fill: Color {
        if !isEnabled { return ReelColor.surface }
        if destructive { return ReelColor.ink }
        return ReelColor.accent
    }
}

struct ReelQuietStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ReelType.caption)
            .foregroundStyle(ReelColor.ink)
            .frame(minHeight: ReelSpace.hit)
            .padding(.horizontal, ReelSpace.s2)
            .background(ReelColor.surface, in: Capsule())
            .opacity(configuration.isPressed ? 0.82 : 1)
            .contentShape(Capsule())
    }
}
