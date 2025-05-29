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
    let id: String
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

    private enum CodingKeys: String, CodingKey {
        case type, amount, actionType
    }

    private enum Kind: String, Codable {
        case reduceEffect
        case increaseStressCost
        case actionPenalty
        case banAction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .reduceEffect:
            self = .reduceEffect
        case .increaseStressCost:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .increaseStressCost(amount: amount)
        case .actionPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionPenalty(actionType: action)
        case .banAction:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .banAction(actionType: action)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reduceEffect:
            try container.encode(Kind.reduceEffect, forKey: .type)
        case .increaseStressCost(let amount):
            try container.encode(Kind.increaseStressCost, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .actionPenalty(let action):
            try container.encode(Kind.actionPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
        case .banAction(let action):
            try container.encode(Kind.banAction, forKey: .type)
            try container.encode(action, forKey: .actionType)
        }
    }
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

    private enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else if let uuid = try? container.decode(UUID.self, forKey: .id) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
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
    case removeSelfInteractable
    case addInteractable(inNodeID: UUID, interactable: Interactable)
    case addInteractableHere(interactable: Interactable)
    case gainTreasure(treasureId: String)

    private enum CodingKeys: String, CodingKey {
        case type, amount, level, familyId, clockName
        case fromNodeID, toNodeID, id, inNodeID
        case interactable, treasure, treasureId
    }

    private enum Kind: String, Codable {
        case gainStress
        case sufferHarm
        case tickClock
        case unlockConnection
        case removeInteractable
        case removeSelfInteractable
        case addInteractable
        case addInteractableHere
        case gainTreasure
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .gainStress:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .gainStress(amount: amount)
        case .sufferHarm:
            let level = try container.decode(HarmLevel.self, forKey: .level)
            let family = try container.decode(String.self, forKey: .familyId)
            self = .sufferHarm(level: level, familyId: family)
        case .tickClock:
            let name = try container.decode(String.self, forKey: .clockName)
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .tickClock(clockName: name, amount: amount)
        case .unlockConnection:
            let from = try container.decode(UUID.self, forKey: .fromNodeID)
            let to = try container.decode(UUID.self, forKey: .toNodeID)
            self = .unlockConnection(fromNodeID: from, toNodeID: to)
        case .removeInteractable:
            if let idString = try? container.decode(String.self, forKey: .id), idString == "self" {
                self = .removeSelfInteractable
            } else if let uuid = try? container.decode(UUID.self, forKey: .id) {
                self = .removeInteractable(id: uuid)
            } else {
                let idStr = try container.decode(String.self, forKey: .id)
                self = .removeInteractable(id: UUID(uuidString: idStr) ?? UUID())
            }
        case .removeSelfInteractable:
            self = .removeSelfInteractable
        case .addInteractable:
            if let nodeString = try? container.decode(String.self, forKey: .inNodeID), nodeString == "current" {
                let interactable = try container.decode(Interactable.self, forKey: .interactable)
                self = .addInteractableHere(interactable: interactable)
            } else {
                let node = try container.decode(UUID.self, forKey: .inNodeID)
                let interactable = try container.decode(Interactable.self, forKey: .interactable)
                self = .addInteractable(inNodeID: node, interactable: interactable)
            }
        case .addInteractableHere:
            let interactable = try container.decode(Interactable.self, forKey: .interactable)
            self = .addInteractableHere(interactable: interactable)
        case .gainTreasure:
            if let treasureId = try? container.decode(String.self, forKey: .treasureId) {
                self = .gainTreasure(treasureId: treasureId)
            } else if let treasure = try? container.decode(Treasure.self, forKey: .treasure) {
                // Fallback to embedded treasure object
                self = .gainTreasure(treasureId: treasure.id)
            } else {
                self = .gainTreasure(treasureId: "")
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gainStress(let amount):
            try container.encode(Kind.gainStress, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .sufferHarm(let level, let family):
            try container.encode(Kind.sufferHarm, forKey: .type)
            try container.encode(level, forKey: .level)
            try container.encode(family, forKey: .familyId)
        case .tickClock(let name, let amount):
            try container.encode(Kind.tickClock, forKey: .type)
            try container.encode(name, forKey: .clockName)
            try container.encode(amount, forKey: .amount)
        case .unlockConnection(let from, let to):
            try container.encode(Kind.unlockConnection, forKey: .type)
            try container.encode(from, forKey: .fromNodeID)
            try container.encode(to, forKey: .toNodeID)
        case .removeInteractable(let id):
            try container.encode(Kind.removeInteractable, forKey: .type)
            try container.encode(id, forKey: .id)
        case .removeSelfInteractable:
            try container.encode(Kind.removeSelfInteractable, forKey: .type)
        case .addInteractable(let node, let interactable):
            try container.encode(Kind.addInteractable, forKey: .type)
            try container.encode(node, forKey: .inNodeID)
            try container.encode(interactable, forKey: .interactable)
        case .addInteractableHere(let interactable):
            try container.encode(Kind.addInteractable, forKey: .type)
            try container.encode("current", forKey: .inNodeID)
            try container.encode(interactable, forKey: .interactable)
        case .gainTreasure(let treasureId):
            try container.encode(Kind.gainTreasure, forKey: .type)
            try container.encode(treasureId, forKey: .treasureId)
        }
    }
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
    var soundProfile: String
    var interactables: [Interactable]
    var connections: [NodeConnection]
    var theme: String? = nil
    var isDiscovered: Bool = false // To support fog of war
}

// Represents a path from one node to another
struct NodeConnection: Codable {
    var toNodeID: UUID
    var isUnlocked: Bool = true // A path could be locked initially
    var description: String // e.g., "A dark tunnel", "A rickety bridge"
}

