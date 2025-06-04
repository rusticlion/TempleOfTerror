import Foundation

// Basic structure for a character class
struct CharacterClass {
    let id: String
    let name: String
    let description: String
    let defaultActions: [String: Int]
    // We can add other class-specific properties here later, like starting equipment, etc.
}

// Service to handle party generation
class PartyGenerationService {

    // Pool of available character classes
    private let classPool: [CharacterClass] = [
        CharacterClass(id: "scientist", name: "Scientist", description: "Uses intellect and gadgets.", defaultActions: ["Study": 3, "Tinker": 1]),
        CharacterClass(id: "mercenary", name: "Mercenary", description: "A hired gun, skilled in combat.", defaultActions: ["Skirmish": 2, "Wreck": 1, "Command": 1]),
        CharacterClass(id: "pilot", name: "Pilot", description: "Expert in navigation and quick maneuvers.", defaultActions: ["Finesse": 3, "Attune": 1]),
        CharacterClass(id: "scavenger", name: "Scavenger", description: "Resourceful and adept at finding things.", defaultActions: ["Hunt": 1, "Survey": 1, "Prowl": 1, "Consort": 1]),
        CharacterClass(id: "medic", name: "Medic", description: "Focuses on healing and support.", defaultActions: ["Study": 2, "Consort": 2]),
        CharacterClass(id: "engineer", name: "Engineer", description: "Builds and repairs contraptions.", defaultActions: ["Tinker": 2, "Wreck": 2])
    ]

    // Pool of names for random assignment
    private let namePool: [String] = [
        "Alex", "Jordan", "Morgan", "Riley", "Casey", "Jamie", "Skyler", "Quinn", "Taylor", "Drew",
        "Blake", "Cameron", "Dakota", "Emerson", "Finley", "Hayden", "Jesse", "Kai", "Logan", "Micah",
        "Noel", "Parker", "Rowan", "Sage", "Teagan", "Val", "Winter", "Zion", "Ashton", "Avery"
    ]

    func generateRandomParty(count: Int = 3) -> [Character] {
        var party: [Character] = []
        var availableClasses = classPool
        var availableNames = namePool

        guard count <= classPool.count else {
            print("Error: Requested party size is larger than the available unique classes.")
            // Fallback or error handling: maybe return a smaller party or throw an error
            return [] // Or handle appropriately
        }

        guard count <= namePool.count else {
            print("Error: Requested party size is larger than the available unique names.")
            // Fallback for names: could allow duplicate names or generate placeholder names
            return [] // Or handle appropriately
        }

        for _ in 0..<count {
            guard !availableClasses.isEmpty, !availableNames.isEmpty else { break }

            // Select a random class and remove it from the available pool to ensure uniqueness
            let classIndex = Int.random(in: 0..<availableClasses.count)
            let selectedClass = availableClasses.remove(at: classIndex)

            // Select a random name and remove it from the available pool
            let nameIndex = Int.random(in: 0..<availableNames.count)
            let selectedName = availableNames.remove(at: nameIndex)

            let newCharacter = Character(
                id: UUID(),
                name: selectedName,
                characterClass: selectedClass.name, // Using class name as characterClass string
                stress: 0,
                harm: HarmState(),
                actions: selectedClass.defaultActions
                // treasures and modifiers can be empty for a new character
            )
            party.append(newCharacter)
        }
        return party
    }
} 