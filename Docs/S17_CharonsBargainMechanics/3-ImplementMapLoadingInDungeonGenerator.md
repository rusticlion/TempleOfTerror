Implement Pre-Designed Map Loading in DungeonGenerator
Goal: Enable the DungeonGenerator to load a complete DungeonMap structure from a JSON file specific to a scenario, allowing for fixed, narrative-driven environments alongside procedural generation for other scenarios.

Rationale: Many authored adventures, like "Charon's Bargain," have specific layouts that are crucial to their story and pacing. This task provides the infrastructure to support these fixed maps, giving designers more control over the player experience for specific scenarios. The existing procedural generation can remain as a fallback or for different scenario types.

Prerequisites:

ContentLoader capable of loading arbitrary JSON files from scenario directories.
Defined DungeonMap, MapNode, and NodeConnection structs in Models.swift.
Implementation Plan:

Define Map JSON Structure:

Action: Create a JSON file schema that directly represents the DungeonMap structure, including all its MapNodes, their properties (id, name, soundProfile, theme, isDiscovered), Interactables (potentially by ID, to be cross-referenced with interactables.json, or fully defined inline), and NodeConnections (including toNodeID, isUnlocked, description).
Example (Content/Scenarios/charons_bargain/map_styx_transporter.json):
JSON

{
  "startingNodeID": "docking_bay_node_id", // UUID as string
  "nodes": {
    "docking_bay_node_id": {
      "id": "docking_bay_node_id",
      "name": "Docking Bay",
      "soundProfile": "metal_echoes", // New sound profile
      "theme": "industrial_docking",
      "isDiscovered": true,
      "interactables": [
        {
          "id": "emergency_beacon_interactable_id",
          "title": "Damaged Emergency Beacon",
          "description": "Sparks fly from the panel. Close inspection reveals hasty, bloody work. Last message fragment: '...medical emergency...Dr. Thorne requests immediate...aid...'",
          // ActionOptions defined here or referenced
        }
      ],
      "connections": [
        {
          "toNodeID": "main_corridor_node_id",
          "description": "Proceed to Main Corridor",
          "isUnlocked": true
        }
      ]
    },
    "main_corridor_node_id": {
      // ... definition for Main Corridor ...
    }
    // ... other nodes from Charon's Bargain
  }
}
Enhance ContentLoader for Map Files:

Action: Add a method to ContentLoader to load and decode a scenario-specific map file (e.g., loadMap(forScenario: String) -> DungeonMap?). This will be similar to how it loads other JSON content but will parse into the DungeonMap struct.
Update ScenarioManifest:

Action: Add an optional mapFile: String? property to ScenarioManifest in ContentLoader.swift. This will store the name of the JSON file containing the pre-designed map for that scenario.
Swift

// In ContentLoader.swift
struct ScenarioManifest: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var entryNode: String? // Could be deprecated if mapFile defines startingNodeID
    var mapFile: String?   // New
}
Modify DungeonGenerator.generate():

Action: Refactor DungeonGenerator.generate(level: Int) (or a new overload like generate(forScenarioManifest manifest: ScenarioManifest)) to check if the ScenarioManifest includes a mapFile.
If mapFile is present:
Use the ContentLoader to load the specified JSON file into a DungeonMap object.
Return this loaded DungeonMap.
If mapFile is not present or loading fails:
Fall back to the existing procedural generation logic.
A warning should be logged if a mapFile was specified but failed to load.
Integrate with GameViewModel.startNewRun():

Action: When starting a new run, GameViewModel should pass the loaded ScenarioManifest to the DungeonGenerator.
The DungeonGenerator will then decide whether to load a predefined map or generate one based on the manifest.
GameState.startingNodeID will be set from the DungeonMap (either loaded or generated).