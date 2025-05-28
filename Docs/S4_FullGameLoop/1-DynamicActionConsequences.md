Task 1: Create Dynamic Action Consequences
Right now, succeeding at an action only adds ticks to a clock. We need a system where actions can have specific, tangible outcomes, like unlocking a path or disabling an interactable.

Action: Introduce a Consequence model and link it to roll outcomes.
Action: Refactor performAction to process these new consequences.
Models.swift (Additions)

Swift

// In Models.swift

// Add an optional ID to Interactable to make it easier to find and remove
struct Interactable: Codable, Identifiable {
    let id: UUID = UUID() // NEW
    var title: String
    //...
}

// Define the types of consequences an action can have
enum Consequence: Codable {
    case gainStress(amount: Int)
    case sufferHarm(level: HarmLevel, description: String)
    case tickClock(clockName: String, amount: Int)
    case unlockConnection(fromNodeID: UUID, toNodeID: UUID)
    case removeInteractable(id: UUID)
    case addInteractable(inNodeID: UUID, interactable: Interactable)
    // We can add many more types later (gain item, etc.)
}

enum HarmLevel: String, Codable { case lesser, moderate, severe }

// Update ActionOption to include specific consequences for each outcome
struct ActionOption: Codable {
    // ... existing properties
    var outcomes: [RollOutcome: [Consequence]]
}

// Define a key for the dictionary
enum RollOutcome: String, Codable { case success, partial, failure }
GameViewModel.swift (Major Refactor)
This is the key task. We'll update an interactable to use this new system and refactor performAction to be a generic consequence processor.

Swift

// In generateDungeon(), update the "Sealed Stone Door" interactable
let stoneDoorID = UUID()
let doorInteractable = Interactable(
    id: stoneDoorID,
    title: "Sealed Stone Door",
    description: "A massive circular door covered in dust.",
    availableActions: [
        ActionOption(
            name: "Examine the Mechanism",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            outcomes: [ // The new outcomes dictionary
                .success: [
                    .unlockConnection(fromNodeID: startNodeID, toNodeID: secondNodeID),
                    .removeInteractable(id: stoneDoorID)
                ],
                .partial: [.gainStress(amount: 1)],
                .failure: [.tickClock(clockName: "The Guardian Wakes", amount: 1)]
            ]
        )
    ]
)

// In GameViewModel, refactor performAction
func performAction(for action: ActionOption, with character: Character) -> DiceRollResult {
    // ... (keep the dice rolling logic) ...

    var consequencesToApply: [Consequence] = []
    var outcomeString = ""

    switch highestRoll {
    case 6:
        outcomeString = "Full Success!"
        consequencesToApply = action.outcomes[.success] ?? []
    case 4...5:
        outcomeString = "Partial Success..."
        consequencesToApply = action.outcomes[.partial] ?? []
    default:
        outcomeString = "Failure."
        consequencesToApply = action.outcomes[.failure] ?? []
    }
    
    // Process the consequences
    let consequencesDescription = processConsequences(consequencesToApply, forCharacter: character)

    return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
}

private func processConsequences(_ consequences: [Consequence], forCharacter character: Character) -> String {
    var descriptions: [String] = []
    for consequence in consequences {
        switch consequence {
        case .gainStress(let amount):
            if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                gameState.party[charIndex].stress += amount
                descriptions.append("Gained \(amount) Stress.")
            }
        // ... Implement cases for .sufferHarm, .tickClock, etc.
        case .unlockConnection(let fromNodeID, let toNodeID):
            if let fromNodeIndex = gameState.dungeon?.nodes.firstIndex(where: { $0.key == fromNodeID }),
               let connIndex = gameState.dungeon?.nodes[fromNodeID]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                gameState.dungeon?.nodes[fromNodeID]?.connections[connIndex].isUnlocked = true
                descriptions.append("A path has opened!")
            }
        case .removeInteractable(let id):
            if let nodeID = gameState.currentNodeID {
                gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == id })
                descriptions.append("The way is clear.")
            }
        default:
            break
        }
    }
    return descriptions.joined(separator: "\n")
}
