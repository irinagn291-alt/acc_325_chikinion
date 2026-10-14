import SwiftUI

/// Review key `roll`. Arm, idle reel, and the control that starts the pass.
private struct PassBeat: Identifiable {
    var tick: Int
    var title: String
    var current: Bool
    var id: Int { tick }
}

struct RollScreen: View {
    @Bindable var model: PracticeModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ReelSpace.s3) {
                armPlate
                reelPlate
                start
            }
            .padding(ReelSpace.s3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.regularMaterial)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { close }
        }
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(ReelRadius.card)
    }

    private var armPlate: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s2) {
            Text("Arm")
                .font(ReelType.caption)
                .foregroundStyle(ReelColor.muted)
            Text(model.selectedAxis.plate)
                .font(ReelType.title)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(detentLine)
                .font(ReelType.caption)
                .foregroundStyle(ReelColor.ink)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ReelSpace.s1) {
                    ForEach(Axis.allCases) { axis in
                        Button {
                            model.choose(axis, dismiss: false)
                        } label: {
                            Text(axis.plate)
                                .font(ReelType.caption)
                                .foregroundStyle(model.selectedAxis == axis ? ReelColor.surface : ReelColor.ink)
                                .lineLimit(1)
                                .frame(minHeight: ReelSpace.hit)
                                .padding(.horizontal, ReelSpace.s2)
                                .background(
                                    model.selectedAxis == axis ? ReelColor.accent : ReelColor.surface,
                                    in: Capsule()
                                )
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var reelPlate: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s2) {
            Text(reelStatus)
                .font(ReelType.caption)
                .foregroundStyle(ReelColor.muted)
            Text(reelDigit)
                .font(ReelType.display)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if let match = matchLine {
                Text(match)
                    .font(ReelType.headline)
                    .foregroundStyle(ReelColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            passTimeline
        }
        .padding(ReelSpace.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ReelColor.surface, in: RoundedRectangle(cornerRadius: ReelRadius.card))
    }

    /// Window beats for the pass about to start, or the live tick when a reel is already rolling.
    private var passTimeline: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s1) {
            Text("Pass")
                .font(ReelType.caption)
                .foregroundStyle(ReelColor.muted)
            HStack(alignment: .top, spacing: ReelSpace.s1) {
                ForEach(passBeats, id: \.tick) { beat in
                    VStack(alignment: .leading, spacing: ReelSpace.s1) {
                        Text(beat.title)
                            .font(ReelType.micro)
                            .foregroundStyle(beat.current ? ReelColor.accent : ReelColor.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Capsule()
                            .fill(beat.current ? ReelColor.accent : ReelColor.ink.opacity(0.28))
                            .frame(height: 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var passBeats: [PassBeat] {
        let live = model.root.live.pass?.tick
        return [
            PassBeat(tick: 0, title: "Early", current: live == 0),
            PassBeat(tick: Seal.windowOpensOnTick, title: "Open", current: live == Seal.windowOpensOnTick),
            PassBeat(tick: Seal.windowOpensOnTick + 1, title: "Hold", current: live == Seal.windowOpensOnTick + 1),
            PassBeat(tick: Seal.windowOpensOnTick + 2, title: "Late", current: live == Seal.windowOpensOnTick + 2),
            PassBeat(tick: Seal.windowClosesOnTick, title: "Close", current: live == Seal.windowClosesOnTick)
        ]
    }

    private var start: some View {
        Button("Start") {
            Task { await model.roll() }
        }
        .buttonStyle(ReelPressStyle(loading: model.inFlight && model.rollEnabled))
        .disabled(!model.rollEnabled || model.inFlight)
    }

    private var title: String { "Roll" }

    private var detentLine: String {
        "Speed detent " + ReelFormat.whole(model.root.bounds.detent)
    }

    private var reelStatus: String {
        if case .idle = model.root.live { return "Idle" }
        return "Live"
    }

    private var reelDigit: String {
        if let pass = model.root.live.pass {
            return ReelFormat.whole(pass.digit.value)
        }
        return ReelFormat.whole(0)
    }

    private var matchLine: String? {
        guard let pass = model.root.live.pass else { return nil }
        return "Match " + ReelFormat.whole(pass.prompt.digit.value)
    }

    private var close: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                model.sheet = nil
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }
    }
}
