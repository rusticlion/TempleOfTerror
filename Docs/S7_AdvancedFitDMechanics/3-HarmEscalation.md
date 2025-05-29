Task 3: Implement Harm Escalation Logic
This is the most critical part. When harm is applied, we need to check if the slots are full and upgrade it if necessary.

Action: Create a new, dedicated applyHarm function in the GameViewModel that encapsulates this complex logic.
Action: Update the processConsequences function to call this new helper.
GameViewModel.swift (Logic Updates)

Swift

// In GameViewModel

// This new function handles all the complex escalation logic.
private func applyHarm(familyId: String, level: HarmLevel, toCharacter characterId: UUID) -> String {
    guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterId }) else { return "" }
    guard let harmFamily = HarmLibrary.families[familyId] else { return "" }
    
    var currentLevel = level

    // The Escalation Loop
    while true {
        switch currentLevel {
        case .lesser:
            if gameState.party[charIndex].harm.lesser.count < HarmState.lesserSlots {
                let harm = harmFamily.lesser
                gameState.party[charIndex].harm.lesser.append((familyId, harm.description))
                return "Suffered Lesser Harm: \(harm.description)."
            } else {
                currentLevel = .moderate // Upgrade!
            }
        case .moderate:
            if gameState.party[charIndex].harm.moderate.count < HarmState.moderateSlots {
                let harm = harmFamily.moderate
                gameState.party[charIndex].harm.moderate.append((familyId, harm.description))
                return "Suffered Moderate Harm: \(harm.description)."
            } else {
                currentLevel = .severe // Upgrade!
            }
        case .severe:
            if gameState.party[charIndex].harm.severe.count < HarmState.severeSlots {
                let harm = harmFamily.severe
                gameState.party[charIndex].harm.severe.append((familyId, harm.description))
                return "Suffered SEVERE Harm: \(harm.description)."
            } else {
                // FATAL HARM!
                gameState.status = .gameOver
                let fatalDescription = harmFamily.fatal.description
                return "Suffered FATAL Harm: \(fatalDescription)."
            }
        }
    }
}

// Refactor processConsequences to use the new system.
private func processConsequences(_ consequences: [Consequence], forCharacter character: Character) -> String {
    var descriptions: [String] = []
    for consequence in consequences {
        switch consequence {
        // ... other cases ...
        case .sufferHarm(let level, let familyId): // We now pass the family ID
            let description = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
            descriptions.append(description)
        // ...
        }
    }
    return descriptions.joined(separator: "\n")
}