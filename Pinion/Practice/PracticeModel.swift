import SwiftUI
import UIKit

/// Presentation seam. Screens talk to the reel store here. The fold itself stays in ReelFold.
@MainActor
@Observable
final class PracticeModel {
    private let store: ReelStore
    private(set) var snapshot = ReelSnapshot(root: .empty, warning: nil)
    var sheet: CabinetSheet?
    var selectedAxis: Axis = .precision
    /// Set only when a plate is chosen against the held arm. Ordinary Roll ignores the default axis.
    private var explicitHop: Axis?
    var notice: String?
    var ready = false
    var showSpinner = false
    var sealFlash = false
    var inFlight = false
    var draftName = ""
    var draftAxis: Axis = .precision
    private var clock: Task<Void, Never>?
    private var launchConsumed = false
    private var booted = false

    init(store: ReelStore) {
        self.store = store
    }

    var root: ReelRoot { snapshot.root }

    var bare: Bool {
        if case .bare = ReelFold.lane(of: root.drills) { return true }
        return false
    }

    var rollEnabled: Bool {
        if case .idle = root.live { return true }
        return false
    }

    var pinEnabled: Bool {
        if case .rolling = root.live { return true }
        return false
    }

    var sealEnabled: Bool {
        if case .pinned = root.live { return true }
        return false
    }

    func boot() async {
        guard !booted else { return }
        booted = true
        let spinner = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !ready { showSpinner = true }
        }
        await store.load()
        #if targetEnvironment(simulator)
        await store.applySimulatorSeedIfNeeded()
        if ReviewLaunch.screen == "roll" {
            adopt(await store.presentIdleReel())
        }
        #endif
        adopt(await store.snapshot())
        spinner.cancel()
        showSpinner = false
        ready = true
        consumeLaunchIfReady()
        syncClock()
    }

    func consumeLaunchIfReady() {
        guard ready, root.onboardingComplete, !launchConsumed else { return }
        launchConsumed = true
        switch ReviewLaunch.screen {
        case "log":
            sheet = .progress
        case "goals":
            sheet = .library
        case "settings":
            sheet = .settings
        case "lock":
            sheet = .lock
        case "roll":
            sheet = .roll
        case "pin":
            sheet = .pin
        case "seal":
            sheet = .seal
        case "library":
            sheet = .library
        case "progress":
            sheet = .progress
        default:
            sheet = nil
        }
    }

    func roll() async {
        guard !inFlight else { return }
        inFlight = true
        defer { inFlight = false }
        var generator = SystemRandomNumberGenerator()
        let prompt = Digit.drawn(from: generator.next())
        var start = Digit.drawn(from: generator.next())
        if start == prompt {
            start = start.advanced()
        }
        let axis = Self.axisForRoll(selected: selectedAxis, held: root.axisLock.heldAxis, hop: explicitHop)
        let effect = await store.roll(axis: axis, prompt: prompt, start: start)
        apply(effect, haptic: effect.refusal == nil)
    }

    func pin() async {
        guard !inFlight else { return }
        inFlight = true
        defer { inFlight = false }
        let effect = await store.pin()
        let matched = effect.refusal == nil && {
            if case .pinned = effect.snapshot.root.live { return true }
            return false
        }()
        apply(effect, haptic: matched)
    }

    func seal() async {
        guard !inFlight else { return }
        inFlight = true
        defer { inFlight = false }
        let before = root.results.count
        let effect = await store.seal()
        let filed = effect.snapshot.root.results.count > before
        apply(effect, haptic: filed)
        if filed {
            sealFlash = true
            try? await Task.sleep(nanoseconds: 700_000_000)
            sealFlash = false
        }
    }

    func finishOnboarding() async {
        adopt(await store.finishOnboarding())
        consumeLaunchIfReady()
    }

    func reopenOnboarding() async {
        adopt(await store.reopenOnboarding())
        sheet = nil
    }

    func applyBounds(_ bounds: RollBounds) async {
        adopt(await store.apply(bounds: bounds))
    }

    func resetRadar() async {
        adopt(await store.resetRadarBaseline())
        notice = "Baseline cleared."
        syncClock()
    }

    func resetAll() async {
        await store.resetAllData()
        adopt(await store.snapshot())
        notice = nil
        sheet = nil
        syncClock()
    }

    func addProgram() async {
        adopt(await store.addProgram(name: draftName, emphasis: draftAxis))
        draftName = ""
    }

    func reload() async {
        await store.load()
        adopt(await store.snapshot())
    }

    /// A library plate or arm pick. A pick that leaves the held arm is one hop, then ordinary Roll returns to that arm.
    func choose(_ axis: Axis, dismiss: Bool = true) {
        selectedAxis = axis
        if let held = root.axisLock.heldAxis, axis != held {
            explicitHop = axis
        } else {
            explicitHop = nil
        }
        if dismiss { sheet = nil }
    }

    /// Held arm wins unless this roll is an explicit hop onto another arm.
    nonisolated static func axisForRoll(selected: Axis, held: Axis?, hop: Axis?) -> Axis {
        if let held {
            if let hop, hop != held { return hop }
            return held
        }
        return selected
    }

    private func adopt(_ next: ReelSnapshot) {
        snapshot = next
        if explicitHop == nil, let held = next.root.axisLock.heldAxis {
            selectedAxis = held
        }
    }

    private func apply(_ effect: ReelEffect, haptic: Bool) {
        switch effect.refusal {
        case .none, .axisLocked:
            explicitHop = nil
        default:
            break
        }
        adopt(effect.snapshot)
        notice = effect.refusal.map(Self.spoken)
        if haptic {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        syncClock()
    }

    private static func spoken(_ refusal: ReelRefusal) -> String {
        switch refusal {
        case .rollWhileBusy:
            "Reel is busy."
        case .pinNotRolling:
            "Pin waits for a roll."
        case .sealNotPinned:
            "Seal waits for a pin."
        case .axisLocked(let mark):
            "Locked to \(mark.locked.plate)."
        }
    }

    private func syncClock() {
        guard case .rolling = root.live else {
            clock?.cancel()
            clock = nil
            return
        }
        guard clock == nil else { return }
        clock = Task { [weak self] in
            await self?.runClock()
        }
    }

    private func runClock() async {
        while !Task.isCancelled {
            guard case .rolling = root.live else { break }
            let detent = max(root.bounds.detent, 1)
            let nanos = UInt64(1_000_000_000 / detent)
            try? await Task.sleep(nanoseconds: nanos)
            if Task.isCancelled { break }
            guard case .rolling = root.live else { break }
            let effect = await store.tick()
            adopt(effect.snapshot)
            if let refusal = effect.refusal {
                notice = Self.spoken(refusal)
            }
        }
        clock = nil
        if case .rolling = root.live {
            syncClock()
        }
    }
}

enum CabinetSheet: String, Identifiable {
    case library
    case progress
    case settings
    case lock
    case roll
    case pin
    case seal

    var id: String { rawValue }
}
