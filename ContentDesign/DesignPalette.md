1. Scenario Package Layout
A playable scenario lives in Content/Scenarios/<scenario‑id>/ and normally contains:

File	Purpose	Required
scenario.json	Metadata record (see §2)	✓
interactables.json	Library of interactable templates (see §4)	✓
treasures.json	Loot definitions (see §7)	✓
harm_families.json	Harm families used in this scenario (see §6)	✓
clocks.json	Pre‑seeded clocks (optional) (see §8)	–
map_…​.json	Author‑built dungeon map, if you want fixed layout (see §9)	–

Place any additional art or audio referenced by your content next to these JSON files.

2. Scenario Manifest – scenario.json
```jsonc
{
  "id": "charons_bargain",
  "title": "Charon's Bargain",
  "description": "Investigate a derelict medical transport…​",
  "entryNode": "main_corridor_node_id",   // optional if you use a map file
  "mapFile": "map_charons_bargain.json"    // optional; omit for procedural map
}
```
Fields mirror the ScenarioManifest struct in code
.

3. Universal Design Building Block – Modifier
```jsonc
{
  "id": "uuid‑string",            // omit for auto‑gen
  "bonusDice": 1,                 // +d6 to pool
  "improvePosition": true,        // bump Controlled→Risky, Risky→Desperate
  "improveEffect": false,         // bump Limited→Standard→Great
  "applicableActions": ["Tinker"],
  "requiredTag": "Mechanical",    // Interactable must carry this tag
  "uses": 2,                      // 0 = inexhaustible
  "isOptionalToApply": true,      // if false it is always on
  "description": "from Fine Tools"
}
```
This same object shape is reused inside Treasures (§7) and Harm boons (§6)
.

4. Interactable Templates – interactables.json
Top level may be an array or a dictionary of arrays for grouping.
Each entry:

```jsonc
{
  "id": "template_pressure_plate",
  "title": "Pressure Plate",
  "description": "A slightly raised stone tile looks suspicious.",
  "isThreat": false,          // see §4.4
  "tags": ["Mechanical","Trap"],
  "availableActions": [ … ]   // see §5
}
```
4.1 Tags
Free‑form strings enabling conditional logic and UI chips (e.g., give treasures the "Light Source" tag and require it on a dark‑room Interactable). Tags are already parsed by the engine for gating and bonuses
.

4.2 Threats
Set "isThreat": true for hazards that block movement until removed (UI draws a red border)
.

5. Action Options – inside availableActions
```jsonc
{
  "name": "Cross Carefully",
  "actionType": "Finesse",          // must exist on Character.actions
  "position": "desperate",          // controlled | risky | desperate
  "effect": "standard",             // limited | standard | great
  "requiresTest": true,             // false = free action
  "isGroupAction": false,           // true = everyone rolls, leader takes Stress
  "requiredTag": "Light Source",    // optional gating
  "outcomes": {                     // keyed by roll outcome
    "success": [ … ],               // see §5.1
    "partial": [ … ],
    "failure": [ … ]
  }
}
```
5.1 Consequences Array
Each element is a Consequence (§5.2). Example abridged from docs
:

```jsonc
{
  "type": "sufferHarm",
  "level": "moderate",
  "familyId": "leg_injury"
}
```
5.2 Consequence catalogue
The type field selects the variant; optional parameters in italics.

type	Parameters	Effect
gainStress	amount	Add stress
sufferHarm	level, familyId	Apply harm tier
tickClock	clockName, amount	Advance clock
unlockConnection	fromNodeID, toNodeID	Unlock a map path
removeInteractable	id ("self" allowed)	Delete object
removeAction	id, actionName	Strip one action
addAction	id, action (inline ActionOption)	Insert new action
addInteractable	inNodeID | "current", interactable	Spawn new interactable
gainTreasure	treasureId	Give item to actor
modifyDice	amount, duration ("nextRoll" etc.)	Temp dice buff/debuff
createChoice	options (array of {title, consequences})	Branching prompt
triggerEvent	eventId	Fires custom event hook
triggerConsequences	consequences	Fire a nested list

All have optional conditions array for gating (see next).

6. Conditional Logic – GameCondition
```jsonc
{
  "type": "requiresMinEffectLevel",  // see table
  "effectParam": "standard"
}
```
Supported type values:

Condition	Fields
requiresMinEffectLevel	effectParam
requiresExactEffectLevel	effectParam
requiresMinPositionLevel	positionParam
requiresExactPositionLevel	positionParam
characterHasTreasureId	stringParam (treasure id)
partyHasTreasureWithTag	stringParam (tag)
clockProgress	stringParam (clock name), intParam ≥, optional intParamMax ≤

7. Treasure Definitions – treasures.json
```jsonc
{
  "id": "treasure_steadying_herbs",
  "name": "Steadying Herbs",
  "description": "Chewing these calms the nerves, for a time.",
  "grantedModifier": {
    "improvePosition": true,
    "uses": 1,
    "description": "from Steadying Herbs"
  },
  "tags": ["Consumable","Herb"]     // optional
}
```
Tag support came in with the tag system update
.

8. Harm System – harm_families.json
```jsonc
{
  "id": "leg_injury",
  "lesser": {
    "description": "Twisted Ankle",
    "penalty": { "type": "actionPenalty", "actionType": "Prowl" }
  },
  "moderate": {
    "description": "Fractured Tibia",
    "penalty": { "type": "actionPenalty", "actionType": "Finesse" }
  },
  "severe": {
    "description": "Shattered Femur",
    "penalty": { "type": "banAction", "actionType": "Prowl" }
  },
  "fatal": { "description": "Exsanguination" }
}
```
penalty must be one of the Penalty enum variants; boon (optional) embeds a Modifier and is auto‑applied while the harm is active
.

9. Game Clock Templates – clocks.json
```jsonc
{
  "name": "Torchlight Fading",
  "segments": 4,
  "progress": 0,
  "onTickConsequences": [ … ],      // optional
  "onCompleteConsequences": [ … ]   // optional
}
```
Clock struct supports both tick‑time and completion triggers
.

10. Authored Dungeon Maps – map_…​.json
```jsonc
{
  "startingNodeID": "00000000-0000-0000-0000-000000000001",
  "nodes": {
    "00000000‑…​0001": {
      "id": "00000000‑…​0001",
      "name": "Docking Bay",
      "soundProfile": "metal_echoes",
      "theme": "industrial_docking",
      "isDiscovered": true,          // usually true only for entry
      "interactables": [ /* inline full objects or IDs */ ],
      "connections": [
        {
          "toNodeID": "00000000‑…​0002",
          "description": "Proceed to Main Corridor",
          "isUnlocked": true
        }
      ]
    }
    /* additional nodes */
  }
}
```
The schema is identical to the DungeonMap / MapNode / NodeConnection structs in code, and the docs give a worked example
.

11. ID & Linking Guidelines
IDs must be unique across the whole scenario (treasures, interactables, nodes).

References anywhere in JSON are plain strings (UUIDs or human identifiers).

Use "self" where a consequence targets the interactable that triggered it.

When spawning interactables at runtime (addInteractableHere) you may inline a whole object—no template lookup required.

12. Putting It Together – Minimal Playable Example
```jsonc
// Content/Scenarios/demo_tomb/scenario.json
{
  "id": "demo_tomb",
  "title": "The Demo Tomb",
  "description": "A bite‑sized scenario to show the JSON format."
}

// Content/Scenarios/demo_tomb/interactables.json
[
  {
    "id": "loose_flagstone",
    "title": "Loose Flagstone",
    "description": "One stone lies slightly higher than the rest.",
    "tags": ["Mechanical","Trap"],
    "availableActions": [
      {
        "name": "Step Over",
        "actionType": "Finesse",
        "position": "risky",
        "effect": "standard",
        "outcomes": {
          "success": [
            { "type": "removeInteractable", "id": "self" }
          ],
          "failure": [
            { "type": "sufferHarm",
              "level": "lesser",
              "familyId": "leg_injury" }
          ]
        }
      },
      {
        "name": "Wedge It",
        "actionType": "Tinker",
        "position": "controlled",
        "effect": "limited",
        "requiresTest": false,
        "outcomes": {
          "success": [
            { "type": "removeInteractable", "id": "self" },
            { "type": "gainTreasure", "treasureId": "ancient_coin" }
          ]
        }
      }
    ]
  }
]

// Content/Scenarios/demo_tomb/treasures.json
[
  {
    "id": "ancient_coin",
    "name": "Ancient Coin",
    "description": "A tarnished silver coin.  Maybe valuable?",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableActions": ["Survey"],
      "uses": 1,
      "description": "from Ancient Coin"
    },
    "tags": ["Currency"]
  }
]

// Content/Scenarios/demo_tomb/harm_families.json
[
  {
    "id": "leg_injury",
    "lesser": { "description": "Twisted Ankle",
                "penalty": { "type": "actionPenalty", "actionType": "Prowl" } },
    "moderate": { "description": "Fractured Tibia",
                  "penalty": { "type": "banAction", "actionType": "Prowl" } },
    "severe": { "description": "Shattered Femur",
                "penalty": { "type": "banAction", "actionType": "Finesse" } },
    "fatal": { "description": "Exsanguination" }
  }
]
```