Task 1: Project Setup & Core Data Models (The "Model" part of MVVM)
Action: Set up a new SwiftUI project in Xcode.

Action: Create the initial data model structs. These should be simple, Codable, and Identifiable where appropriate.

Swift

// In a file named Models.swift

struct GameState {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    // ... other global state
}

struct Character: Identifiable {
    let id = UUID()
    var name: String
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
}

struct HarmState {
    var lesser: [String] = []
    var moderate: [String] = []
    var severe: [String] = []
}

struct GameClock: Identifiable {
    let id = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
}

// Models for the interactable itself
struct Interactable {
    var title: String
    var description: String
    var availableActions: [ActionOption]
}

struct ActionOption {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
}

enum RollPosition { case controlled, risky, desperate }
enum RollEffect { case limited, standard, great }