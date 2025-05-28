Task 3: Introduce "Treasures" for Intra-Run Progression
Treasures are the "loot" of this game. They are the primary way players will gain these new Modifiers, creating a satisfying progression loop within a single run.

Action: Create a Treasure model that can grant Modifiers.
Action: Create a new Consequence type to allow players to gain treasures.
Models.swift (Updates)

Swift

// In Models.swift

struct Treasure: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var description: String
    var grantedModifier: Modifier // The benefit this treasure provides
}

// Add to the Character struct
struct Character: Identifiable, Codable {
    // ...
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
}

// Add a new case to the Consequence enum
enum Consequence: Codable {
    // ... existing cases
    case gainTreasure(treasure: Treasure)
}
GameViewModel.swift (Updates)

We need to update our consequence processor to handle gaining treasures.

Swift

// In processConsequences() in GameViewModel

case .gainTreasure(let treasure):
    if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
        // Add the treasure to their inventory
        gameState.party[charIndex].treasures.append(treasure)
        // AND add its modifier to their active modifiers
        gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
        descriptions.append("Gained Treasure: \(treasure.name)!")
    }
Now, we can update our generateDungeon function to include a treasure as a reward:

Swift

// In generateDungeon(), inside an interactable's outcomes
let pedestalID = UUID()
let pedestalInteractable = Interactable(
    id: pedestalID,
    title: "Trapped Pedestal",
    //...
    outcomes: [
        .success: [
            .removeInteractable(id: pedestalID),
            .gainTreasure(treasure: Treasure(
                name: "Lens of True Sight",
                description: "This crystal lens reveals hidden things.",
                grantedModifier: Modifier(
                    improveEffect: true,
                    applicableToAction: "Survey",
                    uses: 2,
                    description: "from Lens of True Sight"
                )
            ))
        ],
        .failure: [.sufferHarm(level: .lesser, description: "Electric Jolt")]
    ]
)