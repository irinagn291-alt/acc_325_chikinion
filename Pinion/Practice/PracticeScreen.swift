import SwiftUI

/// Home is the reel. Roll, Pin, and Seal stay on this screen. Other rooms arrive as sheets.
struct PracticeScreen: View {
    @Bindable var model: PracticeModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var digitBox = ReelSpace.digit
    @State private var promptLip: CGFloat = 0
    @State private var screenFloor: CGFloat = 0
    @State private var sheetHeight: CGFloat = 360

    var body: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s2) {
            lip
            chrome
            if let warning = model.snapshot.warning, model.bare {
                StatusPage(
                    image: "pin_EmptyHome",
                    title: "The reel could not be read.",
                    line: warning,
                    action: "Retry",
                    role: .quiet
                ) {
                    Task { await model.reload() }
                }
            } else if model.bare {
                StatusPage(
                    image: "pin_EmptyHome",
                    title: "Run the first drill",
                    line: "Pin the digit that matches Prompt",
                    action: "Roll",
                    role: .primary
                ) {
                    Task { await model.roll() }
                }
                .disabled(!model.rollEnabled || model.inFlight)
            } else {
                if let warning = model.snapshot.warning {
                    saveFailure(warning)
                }
                instrument
                if let notice = model.notice {
                    Text(notice)
                        .font(ReelType.caption)
                        .foregroundStyle(ReelColor.ink)
                        .lineLimit(2)
                }
                Text(nextTap)
                    .font(ReelType.body)
                    .foregroundStyle(ReelColor.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(ReelSpace.s3)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            ZStack {
                ReelColor.bg
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScreenFloorKey.self,
                        value: geo.frame(in: .global).maxY
                    )
                }
            }
            .ignoresSafeArea()
        }
        .onPreferenceChange(PromptLipKey.self) { promptLip = $0; refreshSheetHeight() }
        .onPreferenceChange(ScreenFloorKey.self) { screenFloor = $0; refreshSheetHeight() }
        .safeAreaInset(edge: .bottom) {
            if !model.bare {
                verbs
                    .padding(.horizontal, ReelSpace.s3)
                    .padding(.bottom, ReelSpace.s2)
                    .background(ReelColor.bg)
            }
        }
        .sheet(item: $model.sheet) { sheet in
            sheetBody(sheet)
                .presentationDetents([.height(sheetHeight)])
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(ReelRadius.card)
                .presentationDragIndicator(.visible)
        }
    }

    /// Title and match plate. The sheet height stops under this lip.
    private var lip: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s2) {
            Text("Pin the number")
                .font(ReelType.title)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if !model.bare {
                promptPlate
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear.preference(
                    key: PromptLipKey.self,
                    value: geo.frame(in: .global).maxY
                )
            }
        }
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s1) {
            Image("pin_HeaderDecor")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: ReelSpace.decor)
                .clipped()
                .accessibilityHidden(true)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ReelSpace.s1) {
                    sheetButton("Library", .library)
                    sheetButton("Progress", .progress)
                    sheetButton("Settings", .settings)
                    sheetButton("Lock", .lock)
                }
            }
        }
    }

    @ViewBuilder
    private func sheetBody(_ sheet: CabinetSheet) -> some View {
        switch sheet {
        case .library:
            LibraryScreen(model: model)
        case .progress:
            ProgressScreen(model: model)
        case .settings:
            SettingsScreen(model: model)
        case .lock:
            LockSheet(model: model)
        case .roll:
            RollScreen(model: model)
        case .pin:
            PinScreen(model: model)
        case .seal:
            SealScreen(model: model)
        }
    }

    private func refreshSheetHeight() {
        guard promptLip > 0, screenFloor > promptLip + ReelSpace.s6 else { return }
        let next = screenFloor - promptLip - ReelSpace.s2
        if abs(next - sheetHeight) > 1 {
            sheetHeight = next
        }
    }

    private func saveFailure(_ warning: String) -> some View {
        VStack(alignment: .leading, spacing: ReelSpace.s1) {
            Text(warning)
                .font(ReelType.body)
                .foregroundStyle(ReelColor.ink)
                .lineLimit(3)
            Button("Retry") {
                Task { await model.reload() }
            }
            .buttonStyle(ReelPressStyle())
        }
        .padding(ReelSpace.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ReelRadius.card))
    }

    private func sheetButton(_ title: String, _ sheet: CabinetSheet) -> some View {
        Button(title) { model.sheet = sheet }
            .buttonStyle(ReelQuietStyle())
    }

    private var instrument: some View {
        ReelTimeline {
            digitReadout
                .layoutValue(key: ReelRoleKey.self, value: .digit)
            ForEach(marks) { mark in
                Text(mark.label)
                    .font(ReelType.micro)
                    .foregroundStyle(ReelColor.ink)
                    .padding(.horizontal, ReelSpace.s1)
                    .frame(minHeight: ReelSpace.hit)
                    .background(ReelColor.surface, in: RoundedRectangle(cornerRadius: ReelRadius.chip))
                    .layoutValue(key: ReelRoleKey.self, value: .mark)
                    .layoutValue(key: MarkAnchorKey.self, value: CGFloat(mark.tick))
            }
            RadarHero(results: model.root.results)
                .padding(ReelSpace.s2)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ReelRadius.card))
                .layoutValue(key: ReelRoleKey.self, value: .radar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var promptPlate: some View {
        VStack(alignment: .leading, spacing: ReelSpace.s1) {
            Text("Match")
                .font(ReelType.caption)
                .foregroundStyle(ReelColor.muted)
            HStack(alignment: .firstTextBaseline, spacing: ReelSpace.s2) {
                Text(promptText)
                    .font(ReelType.title)
                    .foregroundStyle(ReelColor.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .tracking(tightTracking)
                Text(axisText)
                    .font(ReelType.headline)
                    .foregroundStyle(ReelColor.ink)
                    .lineLimit(1)
            }
            if let held = model.root.axisLock.heldAxis {
                Button("Locked to \(held.plate)") { model.sheet = .lock }
                    .buttonStyle(ReelQuietStyle())
            }
        }
        .padding(ReelSpace.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: ReelRadius.card))
    }

    private var digitReadout: some View {
        Text(digitText)
            .font(ReelType.display)
            .foregroundStyle(ReelColor.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .tracking(tightTracking)
            .frame(width: digitBox, height: digitBox, alignment: .leading)
            .contentTransition(reduceMotion ? .opacity : .identity)
            .animation(reduceMotion ? .easeOut(duration: 0.25) : .easeOut(duration: 0.2), value: digitText)
            .accessibilityLabel("Live number \(digitText)")
    }

    private var verbs: some View {
        VStack(spacing: ReelSpace.s1) {
            switch model.root.live {
            case .rolling:
                verb("Pin", enabled: model.pinEnabled) { Task { await model.pin() } }
                HStack(spacing: ReelSpace.s1) {
                    verb("Roll", enabled: false) {}
                    verb("Seal", enabled: false) {}
                }
            case .pinned:
                verb("Seal", enabled: model.sealEnabled) { Task { await model.seal() } }
                HStack(spacing: ReelSpace.s1) {
                    verb("Roll", enabled: false) {}
                    verb("Pin", enabled: false) {}
                }
            case .idle, .sealed:
                verb("Roll", enabled: model.rollEnabled) { Task { await model.roll() } }
                HStack(spacing: ReelSpace.s1) {
                    verb("Pin", enabled: false) {}
                    verb("Seal", enabled: false) {}
                }
            }
        }
        .overlay(alignment: .top) {
            if model.sealFlash {
                Image("pin_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: ReelSpace.s6, height: ReelSpace.s6)
                    .transition(reduceMotion ? .opacity : .scale)
                    .animation(
                        reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.8),
                        value: model.sealFlash
                    )
                    .accessibilityHidden(true)
            }
        }
    }

    private func verb(_ title: String, enabled: Bool, act: @escaping () -> Void) -> some View {
        Button(title, action: act)
            .buttonStyle(ReelPressStyle(loading: model.inFlight && enabled))
            .disabled(!enabled || model.inFlight)
    }

    private var tightTracking: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? -1.5 : 0
    }

    private var promptText: String {
        if let pass = model.root.live.pass {
            return ReelFormat.whole(pass.prompt.digit.value)
        }
        return "Roll"
    }

    private var axisText: String {
        if let axis = model.root.live.pass?.prompt.axis {
            return axis.plate
        }
        if let held = model.root.axisLock.heldAxis {
            return held.plate
        }
        return model.selectedAxis.plate
    }

    private var digitText: String {
        if let pass = model.root.live.pass {
            return ReelFormat.whole(pass.digit.value)
        }
        return ReelFormat.whole(0)
    }

    private var nextTap: String {
        switch model.root.live {
        case .rolling(let pass):
            "Pin when the number reads " + ReelFormat.whole(pass.prompt.digit.value) + "."
        case .pinned:
            "File the grade."
        case .idle, .sealed:
            "Start the next pass."
        }
    }

    private var marks: [TimelineMark] {
        guard let pass = model.root.live.pass else { return [] }
        var rows: [TimelineMark] = []
        rows += pass.earlyMarks.map { TimelineMark(id: $0.id, tick: $0.tick, label: "Early") }
        rows += pass.skewMarks.map { TimelineMark(id: $0.id, tick: $0.tick, label: "Skew \(ReelFormat.whole($0.digit.value))") }
        rows += pass.pinMarks.map { TimelineMark(id: $0.id, tick: $0.tick, label: "Pin") }
        return rows
    }
}

private struct PromptLipKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ScreenFloorKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct TimelineMark: Identifiable {
    var id: UUID
    var tick: Int
    var label: String
}
