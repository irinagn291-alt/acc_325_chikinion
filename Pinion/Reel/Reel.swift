import Foundation

/// Live session as a fold: Idle, Rolling, Pinned, or Sealed.
/// The lane is a fold over Drills. An empty lane is Bare.
/// Roll is accepted only from Idle. Pin is accepted only while Rolling.
/// Seal is accepted only from Pinned, then the live reel returns to Idle.
enum Reel: Hashable, Equatable, Sendable {
    case idle
    case rolling(ActivePass)
    case pinned(ActivePass)
    case sealed(ActivePass)

    var pass: ActivePass? {
        switch self {
        case .idle: nil
        case .rolling(let pass), .pinned(let pass), .sealed(let pass): pass
        }
    }
}

/// Digits and marks for the drill currently on the reel.
struct ActivePass: Hashable, Equatable, Codable, Sendable {
    var drillID: UUID
    var prompt: Prompt
    var digit: Digit
    var tick: Int
    var pinMarks: [PinMark]
    var skewMarks: [SkewMark]
    var earlyMarks: [EarlyMark]

    var hadFault: Bool { !skewMarks.isEmpty || !earlyMarks.isEmpty }
}

enum LaneFold: Equatable, Sendable {
    case bare
    case running([Drill])
}

enum ReelRefusal: Equatable, Sendable {
    case rollWhileBusy
    case pinNotRolling
    case sealNotPinned
    case axisLocked(LockMark)
}

/// Pure fold over the reel root. Storage is a separate seam.
struct ReelFold: Equatable, Sendable {
    var root: ReelRoot

    init(root: ReelRoot = .empty) {
        self.root = root
    }

    static func lane(of drills: [Drill]) -> LaneFold {
        drills.isEmpty ? .bare : .running(drills)
    }

    var lane: LaneFold { Self.lane(of: root.drills) }

    @discardableResult
    mutating func roll(axis: Axis, prompt: Digit, start: Digit, now: Date) -> ReelRefusal? {
        if case .idle = root.live {
            if let locked = root.axisLock.heldAxis, locked != axis {
                let mark = LockMark(
                    id: UUID(),
                    requested: axis,
                    locked: locked,
                    day: DayStamp.yyyymmdd(now)
                )
                root.lockMarks.append(mark)
                return .axisLocked(mark)
            }
            let drillID = UUID()
            let prompt = Prompt(digit: prompt, axis: axis)
            let pass = ActivePass(
                drillID: drillID,
                prompt: prompt,
                digit: start,
                tick: 0,
                pinMarks: [],
                skewMarks: [],
                earlyMarks: []
            )
            root.live = .rolling(pass)
            root.drills.append(
                Drill(
                    id: drillID,
                    prompt: prompt,
                    phase: .rolling,
                    pinMarks: [],
                    skewMarks: [],
                    earlyMarks: [],
                    resultID: nil
                )
            )
            if root.sessions.isEmpty {
                root.sessions.append(Session(id: UUID(), drillIDs: [drillID]))
            } else {
                root.sessions[root.sessions.count - 1].drillIDs.append(drillID)
            }
            return nil
        }
        return .rollWhileBusy
    }

    @discardableResult
    mutating func pin(now: Date) -> ReelRefusal? {
        guard case .rolling(var pass) = root.live else { return .pinNotRolling }
        if pass.tick < Seal.windowOpensOnTick {
            let mark = EarlyMark(id: UUID(), drillID: pass.drillID, tick: pass.tick)
            pass.earlyMarks.append(mark)
            root.live = .rolling(pass)
            writeBack(pass, phase: .rolling)
            return nil
        }
        if !Seal.windowIsOpen(tick: pass.tick) {
            closeWindow(pass: pass, now: now)
            return nil
        }
        if pass.digit == pass.prompt.digit {
            let mark = PinMark(id: UUID(), drillID: pass.drillID, tick: pass.tick)
            pass.pinMarks.append(mark)
            root.live = .pinned(pass)
            writeBack(pass, phase: .pinned)
            return nil
        }
        let mark = SkewMark(id: UUID(), drillID: pass.drillID, tick: pass.tick, digit: pass.digit)
        pass.skewMarks.append(mark)
        root.live = .rolling(pass)
        writeBack(pass, phase: .rolling)
        return nil
    }

    @discardableResult
    mutating func seal(now: Date) -> ReelRefusal? {
        guard case .pinned(let pass) = root.live else { return .sealNotPinned }
        guard let pin = pass.pinMarks.last, let grade = Seal.grade(forPinTick: pin.tick) else {
            return .sealNotPinned
        }
        file(grade: grade, pass: pass, now: now)
        return nil
    }

    /// Advances the odometer one tick. A window that ends while still Rolling files the miss.
    mutating func tick(now: Date) {
        guard case .rolling(var pass) = root.live else { return }
        pass.tick += 1
        pass.digit = pass.digit.advanced()
        if pass.tick >= Seal.windowClosesOnTick {
            closeWindow(pass: pass, now: now)
            return
        }
        root.live = .rolling(pass)
        writeBack(pass, phase: .rolling)
    }

    private mutating func closeWindow(pass: ActivePass, now: Date) {
        let grade = Seal.missGrade(hadFault: pass.hadFault)
        file(grade: grade, pass: pass, now: now)
    }

    private mutating func file(grade: Grade, pass: ActivePass, now: Date) {
        let result = Result(
            id: UUID(),
            drillID: pass.drillID,
            axis: pass.prompt.axis,
            grade: grade,
            day: DayStamp.yyyymmdd(now)
        )
        root.results.append(result)
        root.live = .sealed(pass)
        if let index = root.drills.firstIndex(where: { $0.id == pass.drillID }) {
            root.drills[index].phase = .sealed
            root.drills[index].pinMarks = pass.pinMarks
            root.drills[index].skewMarks = pass.skewMarks
            root.drills[index].earlyMarks = pass.earlyMarks
            root.drills[index].resultID = result.id
        }
        let recent = Radar.recentGrades(on: pass.prompt.axis, results: root.results)
        root.bounds = Radar.adapt(bounds: root.bounds, recent: recent)
        root.axisLock = Radar.advance(root.axisLock, results: root.results)
        root.live = .idle
    }

    private mutating func writeBack(_ pass: ActivePass, phase: DrillPhase) {
        guard let index = root.drills.firstIndex(where: { $0.id == pass.drillID }) else { return }
        root.drills[index].phase = phase
        root.drills[index].pinMarks = pass.pinMarks
        root.drills[index].skewMarks = pass.skewMarks
        root.drills[index].earlyMarks = pass.earlyMarks
    }
}
