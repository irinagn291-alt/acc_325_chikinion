import Foundation

/// One Codable reel record: programs, sessions, results, five radar arms, and the live marks.
struct ReelRoot: Equatable, Sendable {
    static let schema = 1

    var schemaVersion: Int
    var programs: [Program]
    var sessions: [Session]
    var results: [Result]
    var arms: [RadarArm]
    var drills: [Drill]
    var lockMarks: [LockMark]
    var live: Reel
    var bounds: RollBounds
    var onboardingComplete: Bool
    var axisLock: AxisLock

    static let empty = ReelRoot(
        schemaVersion: schema,
        programs: [],
        sessions: [],
        results: [],
        arms: RadarArm.five,
        drills: [],
        lockMarks: [],
        live: .idle,
        bounds: .opening,
        onboardingComplete: false,
        axisLock: .pending
    )

    /// Simulator happy path: four filed results, reel already Rolling, window open, digit one tick from Prompt.
    static func demo(now: Date = Date()) -> ReelRoot {
        var root = ReelRoot.empty
        root.onboardingComplete = true
        root.programs = [
            Program(id: DemoID.precision, name: "Precision plate", emphasis: .precision),
            Program(id: DemoID.speed, name: "Speed plate", emphasis: .speed)
        ]
        let day = DayStamp.yyyymmdd(now)
        let samples: [(UUID, Axis, Grade)] = [
            (DemoID.resultPrecision, .precision, .s),
            (DemoID.resultSpeed, .speed, .a),
            (DemoID.resultRhythm, .rhythm, .b),
            (DemoID.resultControl, .control, .c)
        ]
        var drillIDs: [UUID] = []
        for (resultID, axis, grade) in samples {
            let drillID = UUID()
            drillIDs.append(drillID)
            let prompt = Prompt(digit: Digit.drawn(from: 4), axis: axis)
            root.drills.append(
                Drill(
                    id: drillID,
                    prompt: prompt,
                    phase: .sealed,
                    pinMarks: [],
                    skewMarks: [],
                    earlyMarks: [],
                    resultID: resultID
                )
            )
            root.results.append(
                Result(id: resultID, drillID: drillID, axis: axis, grade: grade, day: day)
            )
        }
        let liveID = DemoID.liveDrill
        let promptDigit = Digit.drawn(from: 7)
        let prompt = Prompt(digit: promptDigit, axis: .endurance)
        let start = promptDigit.advanced().advanced().advanced().advanced().advanced()
            .advanced().advanced().advanced().advanced()
        let pass = ActivePass(
            drillID: liveID,
            prompt: prompt,
            digit: start,
            tick: Seal.windowOpensOnTick,
            pinMarks: [],
            skewMarks: [],
            earlyMarks: []
        )
        root.drills.append(
            Drill(
                id: liveID,
                prompt: prompt,
                phase: .rolling,
                pinMarks: [],
                skewMarks: [],
                earlyMarks: [],
                resultID: nil
            )
        )
        drillIDs.append(liveID)
        root.sessions = [Session(id: DemoID.session, drillIDs: drillIDs)]
        root.live = .rolling(pass)
        root.arms = RadarArm.five
        return root
    }
}

enum DemoID {
    static let precision = UUID(uuidString: "A1000001-0000-4000-8000-000000000001") ?? UUID()
    static let speed = UUID(uuidString: "A1000001-0000-4000-8000-000000000002") ?? UUID()
    static let resultPrecision = UUID(uuidString: "A1000001-0000-4000-8000-000000000011") ?? UUID()
    static let resultSpeed = UUID(uuidString: "A1000001-0000-4000-8000-000000000012") ?? UUID()
    static let resultRhythm = UUID(uuidString: "A1000001-0000-4000-8000-000000000013") ?? UUID()
    static let resultControl = UUID(uuidString: "A1000001-0000-4000-8000-000000000014") ?? UUID()
    static let liveDrill = UUID(uuidString: "A1000001-0000-4000-8000-000000000021") ?? UUID()
    static let session = UUID(uuidString: "A1000001-0000-4000-8000-000000000031") ?? UUID()
}

extension ReelRoot: Codable {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case programs
        case sessions
        case results
        case arms
        case drills
        case lockMarks
        case live
        case bounds
        case onboardingComplete
        case axisLock
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            programs = try container.decode([Program].self, forKey: .programs)
            sessions = try container.decode([Session].self, forKey: .sessions)
            results = try container.decode([Result].self, forKey: .results)
            arms = try container.decode([RadarArm].self, forKey: .arms)
            drills = try container.decode([Drill].self, forKey: .drills)
            lockMarks = try container.decode([LockMark].self, forKey: .lockMarks)
            live = try container.decode(Reel.self, forKey: .live)
            bounds = try container.decode(RollBounds.self, forKey: .bounds).clamped()
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
            axisLock = try container.decodeIfPresent(AxisLock.self, forKey: .axisLock) ?? .pending
            axisLock = Radar.advance(axisLock, results: results)
            if arms.count != Axis.allCases.count {
                throw DecodingError.dataCorruptedError(
                    forKey: .arms,
                    in: container,
                    debugDescription: "Radar requires five arms"
                )
            }
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unknown reel schema \(version)")
            )
        }
    }
}

extension Reel: Codable {
    private enum Kind: String, Codable {
        case idle
        case rolling
        case pinned
        case sealed
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case pass
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .idle:
            self = .idle
        case .rolling:
            self = .rolling(try container.decode(ActivePass.self, forKey: .pass))
        case .pinned:
            self = .pinned(try container.decode(ActivePass.self, forKey: .pass))
        case .sealed:
            self = .sealed(try container.decode(ActivePass.self, forKey: .pass))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .idle:
            try container.encode(Kind.idle, forKey: .kind)
        case .rolling(let pass):
            try container.encode(Kind.rolling, forKey: .kind)
            try container.encode(pass, forKey: .pass)
        case .pinned(let pass):
            try container.encode(Kind.pinned, forKey: .kind)
            try container.encode(pass, forKey: .pass)
        case .sealed(let pass):
            try container.encode(Kind.sealed, forKey: .kind)
            try container.encode(pass, forKey: .pass)
        }
    }
}
