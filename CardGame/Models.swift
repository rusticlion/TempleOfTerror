import Foundation

enum GameStatus: String, Codable {
    case playing
    case gameOver
}

struct GameState: Codable {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location
    var status: GameStatus = .playing
    // ... other global state can be added later
}

/// A general-purpose modifier that can adjust action rolls.
struct Modifier: Codable {
    var bonusDice: Int = 0
    var improvePosition: Bool = false
    var improveEffect: Bool = false
    var applicableToAction: String? = nil
    var uses: Int = 1
    var description: String
}

/// A collectible treasure that grants a modifier when acquired.
struct Treasure: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var description: String
    var grantedModifier: Modifier
}

struct Character: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
}

/// Defines a single tier of a harm family.
struct HarmTier: Codable {
    var description: String
    var penalty: Penalty? // Penalty is optional for the "Fatal" tier
}

/// Defines a full "family" of related harms, from minor to fatal.
struct HarmFamily: Codable, Identifiable {
    let id: String // e.g., "head_trauma", "leg_injury"
    var lesser: HarmTier
    var moderate: HarmTier
    var severe: HarmTier
    var fatal: HarmTier // The "game over" description
}

/// The mechanical penalty imposed by a HarmTier.
enum Penalty: Codable {
    case reduceEffect               // All actions are one effect level lower.
    case increaseStressCost(amount: Int) // Stress costs are increased.
    case actionPenalty(actionType: String) // Specific action suffers –1 die.
    case banAction(actionType: String) // An action is impossible without effort
}

/// HarmState now tracks detailed conditions rather than simple strings.
struct HarmState: Codable {
    // We store the family ID along with the specific description.
    var lesser: [(familyId: String, description: String)] = []
    var moderate: [(familyId: String, description: String)] = []
    var severe: [(familyId: String, description: String)] = []

    static let lesserSlots = 2
    static let moderateSlots = 2
    static let severeSlots = 1

    private struct Entry: Codable {
        var familyId: String
        var description: String
    }

    private enum CodingKeys: String, CodingKey {
        case lesser, moderate, severe
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lesserEntries = try container.decodeIfPresent([Entry].self, forKey: .lesser) ?? []
        let moderateEntries = try container.decodeIfPresent([Entry].self, forKey: .moderate) ?? []
        let severeEntries = try container.decodeIfPresent([Entry].self, forKey: .severe) ?? []
        self.lesser = lesserEntries.map { ($0.familyId, $0.description) }
        self.moderate = moderateEntries.map { ($0.familyId, $0.description) }
        self.severe = severeEntries.map { ($0.familyId, $0.description) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lesser.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .lesser)
        try container.encode(moderate.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .moderate)
        try container.encode(severe.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .severe)
    }
}

/// Central catalog of all harm families available in the game.
struct HarmLibrary {
    static let families: [String: HarmFamily] = [
        "head_trauma": HarmFamily(
            id: "head_trauma",
            lesser: HarmTier(description: "Headache", penalty: .actionPenalty(actionType: "Study")),
            moderate: HarmTier(description: "Migraine", penalty: .reduceEffect),
            severe: HarmTier(description: "Brain Lightning", penalty: .banAction(actionType: "Study")),
            fatal: HarmTier(description: "Head Explosion", penalty: nil)
        ),
        "leg_injury": HarmFamily(
            id: "leg_injury",
            lesser: HarmTier(description: "Twisted Ankle", penalty: .actionPenalty(actionType: "Finesse")),
            moderate: HarmTier(description: "Torn Muscle", penalty: .reduceEffect),
            severe: HarmTier(description: "Shattered Knee", penalty: .banAction(actionType: "Finesse")),
            fatal: HarmTier(description: "Crippled Beyond Recovery", penalty: nil)
        ),
        "electric_shock": HarmFamily(
            id: "electric_shock",
            lesser: HarmTier(description: "Electric Jolt", penalty: nil),
            moderate: HarmTier(description: "Seared Nerves", penalty: .reduceEffect),
            severe: HarmTier(description: "Nerve Damage", penalty: .banAction(actionType: "Tinker")),
            fatal: HarmTier(description: "Heart Stops", penalty: nil)
        )
        // Additional families can be added here
    ]
}

struct GameClock: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
}

// Models for the interactable itself
struct Interactable: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var availableActions: [ActionOption]

    init(id: UUID = UUID(), title: String, description: String, availableActions: [ActionOption]) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
    }
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    var outcomes: [RollOutcome: [Consequence]] = [:]
}

extension ActionOption: Identifiable {
    var id: String { name }
}

enum RollOutcome: String, Codable {
    case success
    case partial
    case failure
}

enum Consequence: Codable {
    case gainStress(amount: Int)
    case sufferHarm(level: HarmLevel, familyId: String)
    case tickClock(clockName: String, amount: Int)
    case unlockConnection(fromNodeID: UUID, toNodeID: UUID)
    case removeInteractable(id: UUID)
    case addInteractable(inNodeID: UUID, interactable: Interactable)
    case gainTreasure(treasure: Treasure)
}

enum HarmLevel: String, Codable {
    case lesser
    case moderate
    case severe
}

enum RollPosition: String, Codable {
    case controlled
    case risky
    case desperate
}

enum RollEffect: String, Codable {
    case limited
    case standard
    case great

    /// Returns a reduced effect level, clamping at `.limited`.
    func decreased() -> RollEffect {
        switch self {
        case .great: return .standard
        case .standard: return .limited
        case .limited: return .limited
        }
    }
}


// Represents the entire dungeon layout
struct DungeonMap: Codable {
    var nodes: [UUID: MapNode] // Use a dictionary for quick node lookup by ID
    var startingNodeID: UUID
}

// Represents a single room or location on the map
struct MapNode: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var interactables: [Interactable]
    var connections: [NodeConnection]
    var isDiscovered: Bool = false // To support fog of war
}

// Represents a path from one node to another
struct NodeConnection: Codable {
    var toNodeID: UUID
    var isUnlocked: Bool = true // A path could be locked initially
    var description: String // e.g., "A dark tunnel", "A rickety bridge"
}

