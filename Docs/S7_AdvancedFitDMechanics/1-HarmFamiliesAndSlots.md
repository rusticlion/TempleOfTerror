Task 1: Model Harm Families and Slots
We need to evolve our data models to understand the concept of a "family" of related harms and the limited slots at each tier.

Action: Create a HarmFamily model to define the progression of a specific injury.
Action: Refactor HarmState to use these families and respect the slot limits.
Models.swift (Updates)

Swift

// In Models.swift

// Defines a single tier of a harm family.
struct HarmTier: Codable {
    var description: String
    var penalty: Penalty? // Penalty is optional for the "Fatal" tier
}

// Defines a full "family" of related harms, from minor to fatal.
struct HarmFamily: Codable, Identifiable {
    let id: String // e.g., "head_trauma", "leg_injury"
    var lesser: HarmTier
    var moderate: HarmTier
    var severe: HarmTier
    var fatal: HarmTier // The "game over" description
}

// Overhaul HarmState to use slots.
struct HarmState: Codable {
    // We now store the FAMILY ID and the specific DESCRIPTION of the harm taken.
    // The number of slots is defined by the array's capacity.
    var lesser: [(familyId: String, description: String)] = []
    var moderate: [(familyId: String, description: String)] = []
    var severe: [(familyId: String, description: String)] = []

    // Define the capacity of each tier.
    static let lesserSlots = 2
    static let moderateSlots = 2
    static let severeSlots = 1
}

// We'll also need a central place to define all our harm families.
// This could be a static property or loaded from a JSON file.
struct HarmLibrary {
    static let families: [String: HarmFamily] = [
        "head_trauma": HarmFamily(
            id: "head_trauma",
            lesser: HarmTier(description: "Headache", penalty: .actionPenalty(actionType: "Study")),
            moderate: HarmTier(description: "Migraine", penalty: .reduceEffect),
            severe: HarmTier(description: "Brain Lightning", penalty: .banAction(actionType: "Study")),
            fatal: HarmTier(description: "Head Explosion")
        ),
        "leg_injury": HarmFamily(
            id: "leg_injury",
            lesser: HarmTier(description: "Twisted Ankle", penalty: .actionPenalty(actionType: "Finesse")),
            moderate: HarmTier(description: "Torn Muscle", penalty: .reduceEffect),
            severe: HarmTier(description: "Shattered Knee", penalty: .banAction(actionType: "Finesse")),
            fatal: HarmTier(description: "Crippled Beyond Recovery")
        )
        // ... add more families
    ]
}

// Add the new penalty type to the Penalty enum
enum Penalty: Codable {
    // ... existing cases
    case banAction(actionType: String) // An action is impossible without a special effort
}