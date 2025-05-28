Task 1: Overhaul the Harm System
Harm should be more than a simple damage counter; it should be a narrative and mechanical complication that players have to actively work around.

Action: Redefine the HarmState and introduce HarmCondition and Penalty models.
Action: Update the GameViewModel to apply penalties from Harm to a character's actions.
Models.swift (Updates)

Swift

// In Models.swift

// A specific injury or affliction with a mechanical effect.
struct HarmCondition: Codable, Identifiable {
    let id: UUID = UUID()
    var description: String // e.g., "Shattered Hand", "Spiraling Paranoia"
    var penalty: Penalty
}

// The mechanical penalty imposed by a HarmCondition.
enum Penalty: Codable {
    case reduceEffect // All actions are one effect level lower.
    case increaseStressCost(amount: Int) // Pushing yourself or resisting costs more stress.
    case actionPenalty(actionType: String) // A specific action (e.g., "Wreck") is at a disadvantage (e.g., -1d).
    // Future penalties could include locking an action entirely.
}

// HarmState now holds specific conditions instead of just strings.
struct HarmState: Codable {
    var lesser: [HarmCondition] = []
    var moderate: [HarmCondition] = []
    var severe: [HarmCondition] = []
}
GameViewModel.swift (Updates)

We need to update calculateProjection to reflect these penalties before the roll.

Swift

// In GameViewModel.swift

func calculateProjection(for action: ActionOption, with character: Character) -> String {
    var diceCount = character.actions[action.actionType] ?? 0
    var position = action.position
    var effect = action.effect
    var notes: [String] = []

    // Apply penalties from all active harm conditions
    let allHarm = character.harm.lesser + character.harm.moderate + character.harm.severe
    for condition in allHarm {
        switch condition.penalty {
        case .reduceEffect:
            effect = effect.decreased() // We'll need to add this helper function to the enum
            notes.append("(-1 Effect from \(condition.description))")
        case .actionPenalty(let actionType) where actionType == action.actionType:
            diceCount -= 1
            notes.append("(-1d from \(condition.description))")
        default:
            break
        }
    }
    diceCount = max(diceCount, 0) // Can't roll negative dice

    let notesString = notes.isEmpty ? "" : " " + notes.joined(separator: ", ")
    return "Roll \(diceCount)d6. Position: \(position.rawValue), Effect: \(effect.rawValue)\(notesString)"
}

// We'll also need a helper on RollEffect enum in Models.swift
enum RollEffect: String, Codable {
    // ... cases
    func decreased() -> RollEffect {
        switch self {
        case .great: return .standard
        case .standard: return .limited
        case .limited: return .limited
        }
    }
}