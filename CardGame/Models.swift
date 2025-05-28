import Foundation

struct GameState: Codable {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
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
struct Interactable: Codable {
    var title: String
    var description: String
    var availableActions: [ActionOption]
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
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

