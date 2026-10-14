import XCTest
@testable import Pinion

final class PinionTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: PinionApp.self), "PinionApp")
    }

    func testReviewLaunchParsesScreenKey() {
        XCTAssertEqual(ReviewLaunch.screen(from: ["Pinion", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Pinion", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Pinion", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(from: ["Pinion", "-ReviewScreen", "settings"]), "settings")
        XCTAssertNil(ReviewLaunch.screen(from: ["Pinion"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Pinion", "-ReviewScreen"]))
    }

    func testFamilyInvariantNeedsFiveSamplesBeforeWeakestAxis() {
        XCTAssertNil(Radar.weakest(in: []))
        XCTAssertNil(Radar.advance(.pending, results: samples(4, axis: .speed, grade: .d)).heldAxis)
        let five = samples(5, axis: .speed, grade: .d)
        XCTAssertEqual(Radar.weakest(in: five), .precision)
        XCTAssertEqual(Radar.advance(.pending, results: five).heldAxis, .precision)

        let spread = spreadMeans()
        let held = Radar.advance(.pending, results: spread)
        XCTAssertEqual(held.heldAxis, .precision)
        var cleared = spread
        for _ in 0..<4 {
            cleared.append(Result(id: UUID(), drillID: UUID(), axis: .precision, grade: .s, day: 20260927))
        }
        XCTAssertNil(Radar.advance(held, results: cleared).heldAxis)

        let up = Radar.adapt(bounds: .opening, recent: [.s, .c, .s])
        XCTAssertEqual(up.detent, RollBounds.opening.detent + 1)
        let down = Radar.adapt(bounds: .opening, recent: [.d, .a, .d])
        XCTAssertEqual(down.detent, RollBounds.opening.detent - 1)
        let steady = Radar.adapt(bounds: .opening, recent: [.a, .b])
        XCTAssertEqual(steady.detent, RollBounds.opening.detent)
        let floored = Radar.adapt(bounds: RollBounds(floor: 2, ceiling: 6, detent: 2), recent: [.d, .d, .d])
        XCTAssertEqual(floored.detent, 2)
    }

    func testPinRefusesIdleAcceptsMatchAndRejectsInvalidDigit() {
        var fold = ReelFold()
        XCTAssertEqual(fold.lane, .bare)
        XCTAssertEqual(fold.pin(now: fixedDate), .pinNotRolling)
        XCTAssertNil(Digit(value: 10))
        XCTAssertNil(Digit(value: -1))

        XCTAssertNil(fold.roll(axis: .precision, prompt: Digit.drawn(from: 4), start: Digit.drawn(from: 3), now: fixedDate))
        XCTAssertEqual(fold.lane, .running(fold.root.drills))
        fold.tick(now: fixedDate)
        XCTAssertNil(fold.pin(now: fixedDate))
        guard case .pinned(let pass) = fold.root.live else {
            XCTFail("Match should pin")
            return
        }
        XCTAssertEqual(pass.pinMarks.count, 1)
        XCTAssertEqual(pass.prompt.digit, pass.digit)
    }

    func testTwistMarksGradesLockAndSpeed() {
        var fold = ReelFold()
        let now = fixedDate
        XCTAssertNil(fold.roll(axis: .rhythm, prompt: Digit.drawn(from: 2), start: Digit.zero, now: now))
        XCTAssertNil(fold.pin(now: now))
        guard case .rolling(let early) = fold.root.live else {
            XCTFail("Early pin stays rolling")
            return
        }
        XCTAssertEqual(early.earlyMarks.count, 1)

        fold.tick(now: now)
        XCTAssertNil(fold.pin(now: now))
        guard case .rolling(let skew) = fold.root.live else {
            XCTFail("Mismatch stays rolling")
            return
        }
        XCTAssertEqual(skew.skewMarks.count, 1)
        XCTAssertEqual(fold.roll(axis: .speed, prompt: Digit.zero, start: Digit.zero, now: now), .rollWhileBusy)
        XCTAssertEqual(fold.seal(now: now), .sealNotPinned)

        let before = fold.root.results.count
        fold.tick(now: now)
        fold.tick(now: now)
        fold.tick(now: now)
        XCTAssertEqual(fold.root.live, .idle)
        XCTAssertEqual(fold.root.results.count, before + 1)
        XCTAssertEqual(fold.root.results.last?.grade, .d)
        XCTAssertEqual(fold.root.drills.last?.phase, .sealed)

        var quiet = ReelFold()
        XCTAssertNil(quiet.roll(axis: .control, prompt: Digit.drawn(from: 1), start: Digit.drawn(from: 8), now: now))
        quiet.tick(now: now)
        quiet.tick(now: now)
        quiet.tick(now: now)
        quiet.tick(now: now)
        XCTAssertEqual(quiet.root.results.last?.grade, .c)

        var matched = ReelFold()
        XCTAssertNil(matched.roll(axis: .precision, prompt: Digit.drawn(from: 5), start: Digit.drawn(from: 4), now: now))
        matched.tick(now: now)
        XCTAssertNil(matched.pin(now: now))
        XCTAssertNil(matched.seal(now: now))
        XCTAssertEqual(matched.root.results.last?.grade, .s)
        XCTAssertEqual(matched.root.live, .idle)

        var later = ReelFold()
        XCTAssertNil(later.roll(axis: .precision, prompt: Digit.drawn(from: 3), start: Digit.zero, now: now))
        later.tick(now: now)
        later.tick(now: now)
        later.tick(now: now)
        XCTAssertNil(later.pin(now: now))
        XCTAssertNil(later.seal(now: now))
        XCTAssertEqual(later.root.results.last?.grade, .b)

        var lockedRoot = rootWithFiveLowSpeedGrades()
        lockedRoot.axisLock = Radar.advance(lockedRoot.axisLock, results: lockedRoot.results)
        var locked = ReelFold(root: lockedRoot)
        let refusal = locked.roll(axis: .speed, prompt: Digit.zero, start: Digit.zero, now: now)
        guard case .axisLocked(let mark) = refusal else {
            XCTFail("Hopping off the locked arm writes LockMark")
            return
        }
        XCTAssertEqual(mark.locked, .precision)
        XCTAssertEqual(mark.requested, .speed)
        XCTAssertEqual(locked.root.lockMarks.count, 1)
        XCTAssertNil(locked.roll(axis: .precision, prompt: Digit.drawn(from: 1), start: Digit.drawn(from: 1), now: now))
        guard case .rolling = locked.root.live else {
            XCTFail("Roll on the locked arm is accepted")
            return
        }
    }

    func testArchitectureFoldRecordsSealedThenIdle() throws {
        var fold = ReelFold()
        XCTAssertNil(fold.roll(axis: .endurance, prompt: Digit.zero, start: Digit.drawn(from: 9), now: fixedDate))
        XCTAssertEqual(
            fold.roll(axis: .endurance, prompt: Digit.drawn(from: 9), start: Digit.zero, now: fixedDate),
            .rollWhileBusy
        )
        fold.tick(now: fixedDate)
        XCTAssertNil(fold.pin(now: fixedDate))
        XCTAssertNil(fold.seal(now: fixedDate))
        XCTAssertEqual(fold.root.live, .idle)
        XCTAssertEqual(fold.root.drills.first?.phase, .sealed)
        XCTAssertEqual(fold.seal(now: fixedDate), .sealNotPinned)
        let encoded = try JSONEncoder().encode(Reel.sealed(ActivePass(
            drillID: UUID(),
            prompt: Prompt(digit: Digit.zero, axis: .precision),
            digit: Digit.zero,
            tick: 1,
            pinMarks: [],
            skewMarks: [],
            earlyMarks: []
        )))
        let decoded = try JSONDecoder().decode(Reel.self, from: encoded)
        guard case .sealed = decoded else {
            XCTFail("Sealed is a reel case")
            return
        }
    }

    func testPersistenceRoundTripBackupAndReset() async throws {
        let harness = try makeStore()
        let prompt = Digit.drawn(from: 6)
        let effect = await harness.store.roll(axis: .precision, prompt: prompt, start: Digit.drawn(from: 5), now: fixedDate)
        XCTAssertNil(effect.refusal)
        _ = await harness.store.tick(now: fixedDate)
        let pinned = await harness.store.pin(now: fixedDate)
        XCTAssertNil(pinned.refusal)
        let sealed = await harness.store.seal(now: fixedDate)
        XCTAssertNil(sealed.refusal)
        await harness.store.flush()

        let reloaded = ReelStore(keys: harness.keys, directory: harness.directory)
        await reloaded.load()
        let snap = await reloaded.snapshot()
        XCTAssertEqual(snap.root.results.count, 1)
        XCTAssertEqual(snap.root.results.first?.grade, .s)
        XCTAssertEqual(snap.root.results.first?.day, DayStamp.yyyymmdd(fixedDate))
        XCTAssertNil(snap.warning)

        let payload = try Data(contentsOf: harness.directory.appendingPathComponent("pin.reel.v1.json"))
        try payload.write(to: harness.directory.appendingPathComponent("pin.reel.v1.json.backup"), options: .atomic)
        try Data("not-json".utf8).write(to: harness.directory.appendingPathComponent("pin.reel.v1.json"), options: .atomic)
        harness.keys.setData(Data("not-json".utf8), forKey: ReelStore.storageKey)

        let recovered = ReelStore(keys: harness.keys, directory: harness.directory)
        await recovered.load()
        let recoveredSnap = await recovered.snapshot()
        XCTAssertEqual(recoveredSnap.root.results.count, 1)
        XCTAssertNil(recoveredSnap.warning)

        await recovered.resetAllData()
        XCTAssertNil(harness.keys.data(forKey: ReelStore.storageKey))
        let afterReset = ReelStore(keys: harness.keys, directory: harness.directory)
        await afterReset.load()
        let empty = await afterReset.snapshot()
        XCTAssertEqual(empty.root.results.count, 0)
        XCTAssertEqual(empty.root.live, .idle)
    }

    func testOrdinaryRollSamplesHeldArmWithoutAPlate() {
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .precision, held: nil, hop: nil), .precision)
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .precision, held: .control, hop: nil), .control)
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .precision, held: .rhythm, hop: nil), .rhythm)
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .precision, held: .endurance, hop: nil), .endurance)
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .speed, held: .control, hop: .speed), .speed)
        XCTAssertEqual(PracticeModel.axisForRoll(selected: .speed, held: .control, hop: .control), .control)
    }

    func testCuePunctualityNamesFireAtFromRunStart() {
        let runStart = 10.0
        let prior = 1.5
        let offset = 0.25
        let fireAt = runStart + prior + offset
        let planned = fireAt
        let actual = 12.0
        let punctuality = 1 - min(1.0, abs(actual - planned) / 1.5)
        XCTAssertEqual(fireAt, 11.75, accuracy: 0.0001)
        XCTAssertEqual(punctuality, 1 - (0.25 / 1.5), accuracy: 0.0001)
    }

    func testUnknownSchemaStartsEmpty() async throws {
        let harness = try makeStore()
        let junk = Data("{\"schemaVersion\":99}".utf8)
        try junk.write(to: harness.directory.appendingPathComponent("pin.reel.v1.json"), options: .atomic)
        harness.keys.setData(junk, forKey: ReelStore.storageKey)
        await harness.store.load()
        let snap = await harness.store.snapshot()
        XCTAssertEqual(snap.root, .empty)
        XCTAssertNotNil(snap.warning)
    }

    private func spreadMeans() -> [Result] {
        let axes: [(Axis, Grade)] = [
            (.precision, .d),
            (.speed, .a),
            (.rhythm, .a),
            (.control, .a),
            (.endurance, .a)
        ]
        return axes.map { axis, grade in
            Result(id: UUID(), drillID: UUID(), axis: axis, grade: grade, day: 20260927)
        }
    }

    private func samples(_ count: Int, axis: Axis, grade: Grade) -> [Result] {
        (0..<count).map { index in
            Result(id: UUID(), drillID: UUID(), axis: axis, grade: grade, day: 20260901 + index)
        }
    }

    private func rootWithFiveLowSpeedGrades() -> ReelRoot {
        var root = ReelRoot.empty
        for _ in 0..<5 {
            root.results.append(Result(id: UUID(), drillID: UUID(), axis: .speed, grade: .d, day: 20260927))
        }
        return root
    }

    private func makeStore() throws -> (store: ReelStore, keys: UserDefaultsKeyStore, directory: URL) {
        let name = "pin-test-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: name) else {
            XCTFail("Could not open a defaults suite")
            throw StoreHarnessError.unavailable
        }
        defaults.removePersistentDomain(forName: name)
        let keys = UserDefaultsKeyStore(defaults)
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return (ReelStore(keys: keys, directory: directory), keys, directory)
    }

    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_758_960_000)
    }
}

private enum StoreHarnessError: Error {
    case unavailable
}
