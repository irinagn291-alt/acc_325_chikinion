import Foundation

/// Seam between the reel fold and storage. Views talk to this type, never to UserDefaults.
actor ReelStore {
    static let storageKey = "pin.reel.v1"
    static let backupKey = "pin.reel.v1.backup"
    static let demoFlag = "pin.demo.v1"
    static let debounceNanoseconds: UInt64 = 300_000_000

    private let keys: any ReelKeyStore
    private let directory: URL
    private let fileURL: URL
    private let backupURL: URL
    private var root: ReelRoot
    private var warning: String?
    private var saveTask: Task<Void, Never>?
    private var dirty = false

    init(keys: any ReelKeyStore = UserDefaultsKeyStore(), directory: URL? = nil) {
        self.keys = keys
        let folder = directory ?? ReelStore.supportDirectory()
        self.directory = folder
        self.fileURL = folder.appendingPathComponent("pin.reel.v1.json")
        self.backupURL = folder.appendingPathComponent("pin.reel.v1.json.backup")
        self.root = .empty
    }

    func snapshot() -> ReelSnapshot {
        ReelSnapshot(root: root, warning: warning)
    }

    func load() async {
        switch await readProjection() {
        case .loaded(let loaded):
            root = loaded
            warning = nil
        case .unreadable(let notice):
            root = .empty
            warning = notice
        }
    }

    func roll(axis: Axis, prompt: Digit, start: Digit, now: Date = Date()) -> ReelEffect {
        var fold = ReelFold(root: root)
        let refusal = fold.roll(axis: axis, prompt: prompt, start: start, now: now)
        return commit(fold.root, refusal: refusal, mutated: refusal != .rollWhileBusy && refusal != .pinNotRolling && refusal != .sealNotPinned)
    }

    func pin(now: Date = Date()) -> ReelEffect {
        var fold = ReelFold(root: root)
        let before = root
        let refusal = fold.pin(now: now)
        return commit(fold.root, refusal: refusal, mutated: fold.root != before)
    }

    func seal(now: Date = Date()) -> ReelEffect {
        var fold = ReelFold(root: root)
        let before = root
        let refusal = fold.seal(now: now)
        return commit(fold.root, refusal: refusal, mutated: fold.root != before)
    }

    func tick(now: Date = Date()) -> ReelEffect {
        var fold = ReelFold(root: root)
        let before = root
        fold.tick(now: now)
        return commit(fold.root, refusal: nil, mutated: fold.root != before)
    }

    /// Writes the in-memory root immediately. Scene inactive and background call this.
    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        guard dirty else { return }
        await writeProjection()
    }

    /// Deletes the reel key and the file projection. Used by tests and Settings.
    func resetAllData() async {
        saveTask?.cancel()
        saveTask = nil
        root = .empty
        warning = nil
        dirty = false
        keys.removeObject(forKey: Self.storageKey)
        keys.removeObject(forKey: Self.backupKey)
        let manager = FileManager.default
        if manager.fileExists(atPath: fileURL.path) {
            do {
                try manager.removeItem(at: fileURL)
            } catch {
                warning = "Reset could not remove the saved reel."
            }
        }
        if manager.fileExists(atPath: backupURL.path) {
            do {
                try manager.removeItem(at: backupURL)
            } catch {
                warning = "Reset could not remove the reel backup."
            }
        }
    }

    /// Runs once on Simulator. The flag is not written from a device build.
    func finishOnboarding() -> ReelSnapshot {
        root.onboardingComplete = true
        root.bounds = .opening
        scheduleSave()
        return snapshot()
    }

    func reopenOnboarding() -> ReelSnapshot {
        root.onboardingComplete = false
        scheduleSave()
        return snapshot()
    }

    /// In-memory only. The roll review frame needs an idle reel and an enabled Start.
    func presentIdleReel() -> ReelSnapshot {
        root.live = .idle
        return snapshot()
    }

    func apply(bounds: RollBounds) -> ReelSnapshot {
        root.bounds = bounds.clamped()
        scheduleSave()
        return snapshot()
    }

    func resetRadarBaseline() -> ReelSnapshot {
        root.results = []
        root.axisLock = .pending
        root.arms = RadarArm.five
        scheduleSave()
        return snapshot()
    }

    func addProgram(name: String, emphasis: Axis) -> ReelSnapshot {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return snapshot() }
        root.programs.append(Program(id: UUID(), name: trimmed, emphasis: emphasis))
        scheduleSave()
        return snapshot()
    }

    func applySimulatorSeedIfNeeded(now: Date = Date()) async {
        guard !keys.hasObject(forKey: Self.demoFlag) else { return }
        root = ReelRoot.demo(now: now)
        dirty = true
        await writeProjection()
        keys.setFlag(true, forKey: Self.demoFlag)
    }

    private func commit(_ next: ReelRoot, refusal: ReelRefusal?, mutated: Bool) -> ReelEffect {
        if mutated {
            root = next
            scheduleSave()
        }
        return ReelEffect(snapshot: snapshot(), refusal: refusal)
    }

    private func scheduleSave() {
        dirty = true
        saveTask?.cancel()
        let delay = Self.debounceNanoseconds
        saveTask = Task {
            var slept = false
            do {
                try await Task.sleep(nanoseconds: delay)
                slept = true
            } catch {
                slept = false
            }
            guard slept else { return }
            await self.writeProjection()
        }
    }

    private func writeProjection() async {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        let payload: Data
        do {
            payload = try encoder.encode(root)
        } catch {
            warning = "The reel could not be saved."
            return
        }
        let previous = keys.data(forKey: Self.storageKey)
        if let previous {
            keys.setData(previous, forKey: Self.backupKey)
        }
        let manager = FileManager.default
        do {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            if manager.fileExists(atPath: fileURL.path) {
                if manager.fileExists(atPath: backupURL.path) {
                    try manager.removeItem(at: backupURL)
                }
                try manager.copyItem(at: fileURL, to: backupURL)
            }
            try payload.write(to: fileURL, options: .atomic)
            keys.setData(payload, forKey: Self.storageKey)
            dirty = false
        } catch {
            warning = "The reel could not be saved."
        }
    }

    private func readProjection() async -> LoadOutcome {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let manager = FileManager.default
        if let data = readFile(fileURL, manager: manager), let root = decode(data, decoder: decoder) {
            return .loaded(root)
        }
        if let data = keys.data(forKey: Self.storageKey), let root = decode(data, decoder: decoder) {
            return .loaded(root)
        }
        if let data = readFile(backupURL, manager: manager), let root = decode(data, decoder: decoder) {
            return .loaded(root)
        }
        if let data = keys.data(forKey: Self.backupKey), let root = decode(data, decoder: decoder) {
            return .loaded(root)
        }
        let hadBytes = readFile(fileURL, manager: manager) != nil || keys.data(forKey: Self.storageKey) != nil
        if hadBytes {
            return .unreadable("Saved drills could not be read. Started empty.")
        }
        return .loaded(.empty)
    }

    private func readFile(_ url: URL, manager: FileManager) -> Data? {
        guard manager.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    private func decode(_ data: Data, decoder: JSONDecoder) -> ReelRoot? {
        do {
            return try decoder.decode(ReelRoot.self, from: data)
        } catch {
            return nil
        }
    }

    private static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("Chikinion", isDirectory: true)
    }
}

protocol ReelKeyStore: Sendable {
    func data(forKey key: String) -> Data?
    func setData(_ data: Data?, forKey key: String)
    func hasObject(forKey key: String) -> Bool
    func setFlag(_ value: Bool, forKey key: String)
    func removeObject(forKey key: String)
}

/// `UserDefaults` is not `Sendable`, but its storage is synchronized.
/// This box never leaves a defaults reference on the reel actor, and it only
/// forwards the reel keys.
final class UserDefaultsKeyStore: ReelKeyStore, @unchecked Sendable {
    private let defaults: UserDefaults

    init(_ defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func setData(_ data: Data?, forKey key: String) {
        if let data {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    func hasObject(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }

    func setFlag(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func removeObject(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}

private enum LoadOutcome: Sendable {
    case loaded(ReelRoot)
    case unreadable(String)
}

struct ReelSnapshot: Equatable, Sendable {
    var root: ReelRoot
    var warning: String?
}

struct ReelEffect: Equatable, Sendable {
    var snapshot: ReelSnapshot
    var refusal: ReelRefusal?
}
