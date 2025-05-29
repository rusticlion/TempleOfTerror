Task 1: Expand Placeholder Content Definitions (JSON)
The goal here is not final writing, but to create a diverse set of templates that exercise all your systems.

harm_families.json:

Action: Add 2-3 new HarmFamily definitions.
Details:
One family focused on mental or sensory effects (e.g., "Growing Dread" -> "Hallucinations" -> "Maddening Visions"). Penalties could include increaseStressCost or actionPenalty on Attune or Survey.
One family focused on equipment damage or loss (e.g., "Frayed Rope" -> "Broken Tools" -> "Lost Map"). Penalties could banAction for Tinker or make certain Finesse checks automatically result in limited effect.
Example Snippet (to add to your existing JSON structure):
JSON

{
  "id": "mental_anguish",
  "lesser": { "description": "Unease", "penalty": { "type": "increaseStressCost", "amount": 1 } },
  "moderate": { "description": "Fleeting Shadows", "penalty": { "type": "actionPenalty", "actionType": "Survey" } },
  "severe": { "description": "Terror", "penalty": { "type": "reduceEffect" } },
  "fatal": { "description": "Mind Broken" }
}
treasures.json:

Action: Add 3-5 new Treasure definitions.
Details: Aim for variety in the grantedModifier.
One that grants bonusDice to a specific action type.
One that improvePosition for one use.
One that grants a temporary (1-2 uses) resistance to a specific HarmFamily (this would require a new Modifier type or a very specific description and manual check in applyHarm if we want to avoid model changes for now). For simplicity this sprint, let's stick to existing modifier types.
One that is purely narrative or unlocks a specific, rare interactable if we want to go complex (can be just text for now).
Example Snippet:
JSON

{
  "id": "treasure_steadying_herbs",
  "name": "Steadying Herbs",
  "description": "Chewing these calms the nerves, for a time.",
  "grantedModifier": {
    "improvePosition": true,
    "uses": 1,
    "description": "from Steadying Herbs"
  }
}
interactables.json:

Action: Add 5-7 new Interactable templates. This is where we test the breadth of the Consequence system.
Details: Each template should vary:
Action Types Used: Ensure all your action types (Study, Wreck, Finesse, Tinker, Attune, Survey) are used.
Position/Effect Defaults: Mix these up.
Consequences:
Have outcomes that apply the new Harm Families.
Have outcomes that tickClock on different named clocks (e.g., "Ancient Machinery Grinds," "The Walls Are Closing In").
Have outcomes that gainTreasure using your new treasure templates.
Have outcomes that unlockConnection (we'll make the generator use this).
Have outcomes that removeInteractable (itself or another specific placeholder ID if we want linked interactables).
Have outcomes that addInteractable (e.g., successfully disarming a trap reveals a treasure chest interactable).
Example Snippet (for one new interactable):
JSON

{
  "id": "template_crumbling_ledge",
  "title": "Crumbling Ledge",
  "description": "A narrow ledge over a dark chasm. It looks unstable.",
  "availableActions": [
    {
      "name": "Cross Carefully",
      "actionType": "Finesse",
      "position": "desperate",
      "effect": "standard",
      "outcomes": {
        "success": [
          { "type": "removeInteractable", "id": "self" } // Ledge is crossed
        ],
        "partial": [
          { "type": "gainStress", "amount": 2 },
          { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
        ],
        "failure": [
          { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" },
          { "type": "tickClock", "clockName": "Chasm Peril", "amount": 2 }
        ]
      }
    },
    {
      "name": "Test its Stability",
      "actionType": "Survey",
      "position": "risky",
      "effect": "limited",
      "outcomes": {
        "success": [
          // Could add a temporary modifier: "Insight: Ledge is weak" +1d Finesse
        ],
        "failure": [
           { "type": "gainStress", "amount": 1 }
        ]
      }
    }
  ]
}