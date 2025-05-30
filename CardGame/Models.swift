import Foundation

enum GameStatus: String, Codable {
    case playing
    case gameOver
}

struct GameState: Codable {
    /// Identifier for the scenario that generated this run. Used when loading
    /// to reinitialize the `ContentLoader` with the correct data bundle.
    var scenarioName: String = "tomb"

    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location (legacy)
    // Use String keys for JSON compatibility
    var characterLocations: [String: UUID] = [:] // Individual character locations
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

    enum CodingKeys: String, CodingKey {
        case bonusDice, improvePosition, improveEffect, applicableToAction, uses, description
    }

    init(bonusDice: Int = 0,
         improvePosition: Bool = false,
         improveEffect: Bool = false,
         applicableToAction: String? = nil,
         uses: Int = 1,
         description: String) {
        self.bonusDice = bonusDice
        self.improvePosition = improvePosition
        self.improveEffect = improveEffect
        self.applicableToAction = applicableToAction
        self.uses = uses
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bonusDice = try container.decodeIfPresent(Int.self, forKey: .bonusDice) ?? 0
        improvePosition = try container.decodeIfPresent(Bool.self, forKey: .improvePosition) ?? false
        improveEffect = try container.decodeIfPresent(Bool.self, forKey: .improveEffect) ?? false
        applicableToAction = try container.decodeIfPresent(String.self, forKey: .applicableToAction)
        uses = try container.decodeIfPresent(Int.self, forKey: .uses) ?? 1
        description = try container.decode(String.self, forKey: .description)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bonusDice, forKey: .bonusDice)
        try container.encode(improvePosition, forKey: .improvePosition)
        try container.encode(improveEffect, forKey: .improveEffect)
        try container.encodeIfPresent(applicableToAction, forKey: .applicableToAction)
        try container.encode(uses, forKey: .uses)
        try container.encode(description, forKey: .description)
    }
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
/// This dictionary is populated from the JSON content loaded by `ContentLoader`.
struct HarmLibrary {
    /// Access the harm families for the currently loaded scenario.
    static var families: [String: HarmFamily] {
        return ContentLoader.shared.harmFamilyDict
    }
}

struct GameClock: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
}

// Models for the interactable itself
struct Interactable: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var availableActions: [ActionOption]
    var isThreat: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions, isThreat
    }

    init(id: String,
         title: String,
         description: String,
         availableActions: [ActionOption],
         isThreat: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
        self.isThreat = isThreat
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
        isThreat = try container.decodeIfPresent(Bool.self, forKey: .isThreat) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(availableActions, forKey: .availableActions)
        if isThreat {
            try container.encode(isThreat, forKey: .isThreat)
        }
    }
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    var isGroupAction: Bool = false
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, isGroupAction, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         isGroupAction: Bool = false,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.isGroupAction = isGroupAction
        self.outcomes = outcomes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actionType = try container.decode(String.self, forKey: .actionType)
        position = try container.decode(RollPosition.self, forKey: .position)
        effect = try container.decode(RollEffect.self, forKey: .effect)
        isGroupAction = try container.decodeIfPresent(Bool.self, forKey: .isGroupAction) ?? false
        let rawOutcomes = try container.decodeIfPresent([String: [Consequence]].self, forKey: .outcomes) ?? [:]
        var mapped: [RollOutcome: [Consequence]] = [:]
        for (key, value) in rawOutcomes {
            if let outcome = RollOutcome(rawValue: key) {
                mapped[outcome] = value
            }
        }
        outcomes = mapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(actionType, forKey: .actionType)
        try container.encode(position, forKey: .position)
        try container.encode(effect, forKey: .effect)
        if isGroupAction {
            try container.encode(isGroupAction, forKey: .isGroupAction)
        }
        var raw: [String: [Consequence]] = [:]
        for (key, value) in outcomes { raw[key.rawValue] = value }
        try container.encode(raw, forKey: .outcomes)
    }
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
    case removeInteractable(id: String)
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
            let idString = try container.decode(String.self, forKey: .id)
            if idString == "self" {
                self = .removeSelfInteractable
            } else {
                self = .removeInteractable(id: idString)
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

    /// Returns a one-step improved position, clamping at `.controlled`.
    func improved() -> RollPosition {
        switch self {
        case .desperate: return .risky
        case .risky: return .controlled
        case .controlled: return .controlled
        }
    }
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

    /// Returns an increased effect level, clamping at `.great`.
    func increased() -> RollEffect {
        switch self {
        case .limited: return .standard
        case .standard: return .great
        case .great: return .great
        }
    }
}


// Represents the entire dungeon layout
struct DungeonMap: Codable {
    // Store node IDs as strings so JSONEncoder produces a valid object
    var nodes: [String: MapNode] // Use a dictionary for quick node lookup by ID
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

// MARK: - Persistence Helpers

extension GameState {
    /// Encode the game state and write it to the specified URL.
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }

    /// Load a `GameState` from the given file URL.
    static func load(from url: URL) throws -> GameState {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(GameState.self, from: data)
    }
}

