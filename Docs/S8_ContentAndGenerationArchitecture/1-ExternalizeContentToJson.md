Task 1: Externalize Content to JSON
Currently, our HarmLibrary and Interactable definitions live directly in the code. This is inflexible. By moving them to JSON files, we can edit, add, and balance content without recompiling the app.

Action: Create a Content directory in your project to hold new JSON files.
Action: Create harm_families.json, interactables.json, and treasures.json.
Action: Create a ContentLoader service to parse these files at launch.
Example: interactables.json

JSON

{
  "common_traps": [
    {
      "id": "template_pressure_plate",
      "title": "Pressure Plate",
      "description": "A slightly raised stone tile looks suspicious.",
      "availableActions": [
        {
          "name": "Deftly step over it",
          "actionType": "Finesse",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ]
          }
        }
      ]
    },
    {
      "id": "template_cursed_idol",
      "title": "Cursed Idol",
      "description": "A small, unnerving idol of a forgotten god.",
      "availableActions": [
        {
          "name": "Smash it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" },
              { "type": "gainTreasure", "treasureId": "treasure_purified_idol_shard" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "head_trauma" }
            ]
          }
        }
      ]
    }
  ]
}
(Note: We'll need to update our Consequence and ActionOption models to be initializable from these dictionary structures, often by adding a custom init(from decoder: Decoder) implementation that looks at a "type" field.)

ContentLoader.swift (New File)

Swift

import Foundation

class ContentLoader {
    static let shared = ContentLoader()

    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let treasureTemplates: [Treasure]

    private init() {
        // In a real app, you'd handle errors gracefully.
        self.interactableTemplates = Self.load("interactables.json")
        self.harmFamilies = Self.load("harm_families.json")
        self.treasureTemplates = Self.load("treasures.json")
    }

    static func load<T: Decodable>(_ filename: String) -> [T] {
        // Standard JSON file loading and decoding logic...
        // ...
        return [] // return decoded data
    }
}