Task 2: Implement a General-Purpose Modifier System
This system will allow items, boons, or special circumstances to temporarily grant bonuses to a roll.

Action: Define a Modifier model.
Action: Add a list of active modifiers to the Character model.
Models.swift (Additions)

Swift

// In Models.swift, a universal modifier struct.

struct Modifier: Codable {
    var bonusDice: Int = 0
    var improvePosition: Bool = false // e.g., Risky -> Controlled
    var improveEffect: Bool = false   // e.g., Standard -> Great
    var applicableToAction: String? = nil // Optional: only applies to a specific action like "Tinker"
    var uses: Int = 1 // How many times it can be used. -1 for infinite.
    var description: String // e.g., "From 'Fine Tools'"
}

// Add to the Character struct
struct Character: Identifiable, Codable {
    // ... existing properties
    var modifiers: [Modifier] = []
}