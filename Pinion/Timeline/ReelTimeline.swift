import SwiftUI

/// The only custom surface. Places the prompt plate, live digit, mark rail, and compact radar as one instrument.
struct ReelTimeline: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? ReelSpace.art, height: proposal.height ?? ReelSpace.art)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let prompt = subviews.filter { $0[ReelRoleKey.self] == .prompt }
        let digit = subviews.filter { $0[ReelRoleKey.self] == .digit }
        let marks = subviews.filter { $0[ReelRoleKey.self] == .mark }
        let radar = subviews.filter { $0[ReelRoleKey.self] == .radar }
        let gap = ReelSpace.s2
        var y = bounds.minY
        let promptProposal = ProposedViewSize(width: bounds.width, height: nil)
        let promptHeight = prompt.map { $0.sizeThatFits(promptProposal).height }.max() ?? 0
        for view in prompt {
            view.place(at: CGPoint(x: bounds.minX, y: y), proposal: promptProposal)
        }
        y += promptHeight + gap
        let radarHeight = min(ReelSpace.radar, max(ReelSpace.s6, bounds.maxY - y - ReelSpace.s6))
        let midHeight = max(ReelSpace.digit, bounds.maxY - y - radarHeight - gap)
        let digitWidth = bounds.width * 0.42
        let digitProposal = ProposedViewSize(width: digitWidth, height: midHeight)
        for view in digit {
            view.place(at: CGPoint(x: bounds.minX, y: y), proposal: digitProposal)
        }
        let rail = CGRect(
            x: bounds.minX + digitWidth + gap,
            y: y + midHeight * 0.35,
            width: max(0, bounds.width - digitWidth - gap),
            height: ReelSpace.hit
        )
        let span = CGFloat(max(Seal.windowClosesOnTick, 1))
        for view in marks {
            let tick = view[MarkAnchorKey.self]
            let markSize = view.sizeThatFits(ProposedViewSize(width: rail.width * 0.4, height: rail.height))
            let x = rail.minX + (tick / span) * max(0, rail.width - markSize.width)
            view.place(at: CGPoint(x: x, y: rail.minY), proposal: ProposedViewSize(width: markSize.width, height: rail.height))
        }
        let radarY = bounds.maxY - radarHeight
        let radarProposal = ProposedViewSize(width: bounds.width, height: radarHeight)
        for view in radar {
            view.place(at: CGPoint(x: bounds.minX, y: radarY), proposal: radarProposal)
        }
    }
}

enum ReelRole: Hashable {
    case prompt
    case digit
    case mark
    case radar
}

struct ReelRoleKey: LayoutValueKey {
    static let defaultValue: ReelRole = .prompt
}

struct MarkAnchorKey: LayoutValueKey {
    static let defaultValue: CGFloat = 0
}

/// Compact five-arm plate drawn inside the timeline hero. Grade letters sit beside the tint.
struct RadarPlate: Shape {
    var fractions: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.42
        let count = max(fractions.count, 1)
        for index in 0..<count {
            let angle = (-Double.pi / 2) + (Double(index) * 2 * Double.pi / Double(count))
            let length = radius * min(1, max(0.08, fractions[index]))
            let end = CGPoint(
                x: center.x + CGFloat(cos(angle)) * length,
                y: center.y + CGFloat(sin(angle)) * length
            )
            path.move(to: center)
            path.addLine(to: end)
        }
        path.addEllipse(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
        return path
    }
}

struct RadarHero: View {
    var results: [Result]

    var body: some View {
        let means = Radar.means(for: results)
        VStack(alignment: .leading, spacing: ReelSpace.s1) {
            RadarPlate(fractions: means.map { $0.count == 0 ? 0.08 : Double($0.milli) / 1000 })
                .stroke(ReelColor.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(spoken(means))
            HStack(spacing: ReelSpace.s1) {
                ForEach(means, id: \.axis) { mean in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(latestGrade(mean.axis))
                            .font(ReelType.headline)
                            .foregroundStyle(ReelColor.ink)
                        Text(mean.axis.plate)
                            .font(ReelType.micro)
                            .foregroundStyle(ReelColor.muted)
                            .lineLimit(1)
                        Text(ReelFormat.mean(milli: mean.milli))
                            .font(ReelType.micro)
                            .foregroundStyle(ReelColor.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func latestGrade(_ axis: Axis) -> String {
        results.last { $0.axis == axis }?.grade.rawValue ?? "-"
    }

    private func spoken(_ means: [ArmMean]) -> String {
        means.map { "\($0.axis.plate) \(latestGrade($0.axis)) \(ReelFormat.mean(milli: $0.milli))" }.joined(separator: ", ")
    }
}
