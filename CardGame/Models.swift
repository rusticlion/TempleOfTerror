import Foundation

struct GameState: Codable {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location
    // ... other global state can be added later
}

struct Character: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
}

struct HarmState: Codable {
    var lesser: [String] = []
    var moderate: [String] = []
    var severe: [String] = []
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

enum RollOutcome: String, Codable {
    case success
    case partial
    case failure
}

enum Consequence: Codable {
    case gainStress(amount: Int)
    case sufferHarm(level: HarmLevel, description: String)
    case tickClock(clockName: String, amount: Int)
    case unlockConnection(fromNodeID: UUID, toNodeID: UUID)
    case removeInteractable(id: UUID)
    case addInteractable(inNodeID: UUID, interactable: Interactable)
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

