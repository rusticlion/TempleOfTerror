### Task 2: Model Conditional Consequences (Gating Logic)

**Goal:** Define the data structures in `Models.swift` that allow consequences to have prerequisites (conditions) for their application, based on game state, roll position/effect, or player inventory.

**Actions:**

1.  **Define `GameCondition` struct/enum in `CardGame/Models.swift`:**
    ```swift
    struct GameCondition: Codable {
        enum ConditionType: String, Codable {
            case requiresMinEffectLevel
            case requiresExactEffectLevel
            case requiresMinPositionLevel
            case requiresExactPositionLevel
            case characterHasTreasureId   // Param: treasureId (String)
            case partyHasTreasureWithTag  // Param: treasureTag (String)
            case clockProgress           // Params: clockName (String), minProgress (Int), maxProgress (Int, optional)
            // Future: characterHasHarm, characterClass, etc.
        }

        let type: ConditionType
        // Using a dictionary for flexible parameters, or add specific optional fields
        let stringParam: String?   // e.g., treasureId, clockName, tag
        let intParam: Int?         // e.g., clock minProgress
        let intParamMax: Int?      // e.g., clock maxProgress
        let effectParam: RollEffect? // For requiresMinEffectLevel, requiresExactEffectLevel
        let positionParam: RollPosition? // For requiresMinPositionLevel, requiresExactPositionLevel

        // Example Initializer (you'll need custom Codable conformance if params are too varied)
        init(type: ConditionType, stringParam: String? = nil, intParam: Int? = nil, intParamMax: Int? = nil, effectParam: RollEffect? = nil, positionParam: RollPosition? = nil) {
            self.type = type
            self.stringParam = stringParam
            self.intParam = intParam
            self.intParamMax = intParamMax
            self.effectParam = effectParam
            self.positionParam = positionParam
        }
    }
    ```

2.  **Refactor `Consequence` in `CardGame/Models.swift`:**
    * It's highly recommended to refactor `Consequence` from an `enum` with associated values to a `struct`. This makes it much easier to add common properties like `conditions`.
    ```swift
    struct Consequence: Codable {
        // Define the actual effect of the consequence
        enum ConsequenceKind: String, Codable {
            case gainStress, sufferHarm, tickClock, unlockConnection, removeInteractable, removeSelfInteractable, addInteractable, addInteractableHere, gainTreasure
        }
        let kind: ConsequenceKind
        // Parameters for the consequence itself
        let amount: Int?
        let level: HarmLevel?
        let familyId: String?
        let clockName: String?
        let fromNodeID: UUID?
        let toNodeID: UUID?
        let interactableId: String? // For removeInteractable
        let inNodeID: UUID? // For addInteractable
        let newInteractable: Interactable? // For addInteractable/addInteractableHere
        let treasureId: String? // For gainTreasure

        // Gating Conditions
        var conditions: [GameCondition]?

        // You will need custom init(from: Decoder) and encode(to: Encoder) to handle this structure,
        // similar to how you've done for other complex enums/structs.
        // It would map a "type" field in JSON to 'kind' and then decode relevant parameters.
    }
    ```
    *If refactoring `Consequence` now is too large a step, you'll need a more complex way to associate conditions with enum cases during JSON parsing and processing, which can be error-prone.*

3.  **Update `CardGame/ContentLoader.swift`:**
    * Modify JSON parsing logic to correctly decode `Consequence` structs including their optional `conditions` arrays and parameters. This will involve careful handling in your `JSONDecoder` setup, potentially for `ActionOption` and `Interactable` where consequences are defined.