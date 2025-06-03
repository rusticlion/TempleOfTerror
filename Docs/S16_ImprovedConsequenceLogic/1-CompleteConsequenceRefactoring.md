Complete the Consequence Refactoring (High Priority)
Task 1.1: Remove the Enum Definition
swift// In Models.swift - DELETE the enum version entirely
// Keep only the struct version
Task 1.2: Update processConsequences() to Use Struct Pattern
swift// In GameViewModel.swift
private func processConsequences(_ consequences: [Consequence], forCharacter character: Character, interactableID: String?) -> String {
    var descriptions: [String] = []
    
    for consequence in consequences {
        switch consequence.kind {
        case .gainStress:
            if let amount = consequence.amount {
                // Apply stress logic
            }
        case .sufferHarm:
            if let level = consequence.level, let familyId = consequence.familyId {
                // Apply harm logic
            }
        // ... etc
        }
    }
    return descriptions.joined(separator: "\n")
}
Task 1.3: Add Factory Methods for Common Consequences
swift// In Models.swift
extension Consequence {
    static func gainStress(_ amount: Int) -> Consequence {
        var c = Consequence(kind: .gainStress)
        c.amount = amount
        return c
    }
    
    static func sufferHarm(level: HarmLevel, familyId: String) -> Consequence {
        var c = Consequence(kind: .sufferHarm)
        c.level = level
        c.familyId = familyId
        return c
    }
    
    // ... more factory methods
}
Task 1.4: Fix All Consequence Creation Sites

Update DungeonGenerator.swift
Update any hardcoded consequences in GameViewModel
Ensure all use the new struct format