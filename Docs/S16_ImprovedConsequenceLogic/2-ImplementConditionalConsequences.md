Implement Conditional Consequences
Task 2.1: Implement areConditionsMet() Check
The code already has this partially implemented but it needs to be integrated:
swift// In processConsequences(), before applying each consequence:
if !areConditionsMet(conditions: consequence.conditions, 
                     forCharacter: character, 
                     finalEffect: currentEffect, 
                     finalPosition: currentPosition) {
    continue // Skip this consequence
}
Task 2.2: Add Position/Effect to Consequence Processing Context
swiftstruct ConsequenceContext {
    let character: Character
    let interactableID: String?
    let finalEffect: RollEffect
    let finalPosition: RollPosition
    let isCritical: Bool
}

private func processConsequences(_ consequences: [Consequence], 
                                context: ConsequenceContext) -> String
Task 2.3: Create Test Content
Add interactables that demonstrate conditional consequences:
json{
  "id": "template_mystical_altar",
  "title": "Mystical Altar",
  "description": "An altar radiating ancient power",
  "availableActions": [{
    "name": "Channel Power",
    "actionType": "Attune",
    "position": "risky",
    "effect": "standard",
    "outcomes": {
      "success": [
        {
          "type": "gainTreasure",
          "treasureId": "treasure_minor_blessing",
          "conditions": [{
            "type": "requiresExactEffectLevel",
            "effectParam": "limited"
          }]
        },
        {
          "type": "gainTreasure",
          "treasureId": "treasure_major_blessing",
          "conditions": [{
            "type": "requiresMinEffectLevel",
            "effectParam": "great"
          }]
        }
      ]
    }
  }]
}