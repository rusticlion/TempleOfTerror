import SwiftUI

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var rawDicePool: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String]
    var isActionBanned: Bool = false
}

/// Lightweight info about a selectable modifier for the DiceRollView.
struct SelectableModifierInfo: Identifiable {
    let id: UUID
    let description: String
    let detailedEffect: String
    let remainingUses: String
    let modifierData: Modifier
}

@MainActor
enum PartyMovementMode {
    case grouped
    case solo
}

struct RunDependencies {
    let runtime: ScenarioRuntime
    let rollRules: RollRulesEngine
    let saveStore: SaveGameStore

    init(
        runtime: ScenarioRuntime = ScenarioRuntime(),
        rollRules: RollRulesEngine = RollRulesEngine(),
        saveStore: SaveGameStore = SaveGameStore()
    ) {
        self.runtime = runtime
        self.rollRules = rollRules
        self.saveStore = saveStore
    }

    static func configuredForScenario(
        _ scenario: String,
        rollRules: RollRulesEngine = RollRulesEngine(),
        saveStore: SaveGameStore = SaveGameStore()
    ) -> Self {
        var runtime = ScenarioRuntime()
        _ = runtime.activateScenario(named: scenario)
        return Self(runtime: runtime, rollRules: rollRules, saveStore: saveStore)
    }
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var partyMovementMode: PartyMovementMode = .grouped
    @Published var debugFixedDiceEnabled: Bool = false
    @Published var debugFixedDiceValues: [Int] = [6]

    /// Enable verbose logging when processing consequences.
    static var debugConsequences = true
    let rollRules: RollRulesEngine
    var runtime: ScenarioRuntime
    let saveStore: SaveGameStore

    var activeContent: ContentLoader {
        runtime.content
    }

    var activeHarmFamilies: [String: HarmFamily] {
        activeContent.harmFamilyDict
    }

    var harmFamilies: [String: HarmFamily] {
        activeHarmFamilies
    }

    var pendingResolutionDriver: PendingResolutionDriver {
        PendingResolutionDriver(
            runtime: runtime,
            debugLogging: Self.debugConsequences
        )
    }

    var actionResolver: ActionResolver {
        ActionResolver(
            runtime: runtime,
            rollRules: rollRules,
            debugLogging: Self.debugConsequences
        )
    }

    var runSessionController: RunSessionController {
        RunSessionController(
            saveStore: saveStore
        )
    }

    /// Whether a saved game exists on disk.
    static var saveExists: Bool {
        SaveGameStore().saveExists()
    }

    /// Initialize a blank view model intended for loading a game.
    init(dependencies: RunDependencies) {
        self.gameState = GameState()
        self.rollRules = dependencies.rollRules
        self.runtime = dependencies.runtime
        self.saveStore = dependencies.saveStore
    }

    convenience init(
        runtime: ScenarioRuntime = ScenarioRuntime(),
        rollRules: RollRulesEngine = RollRulesEngine(),
        saveStore: SaveGameStore = SaveGameStore()
    ) {
        self.init(
            dependencies: RunDependencies(
                runtime: runtime,
                rollRules: rollRules,
                saveStore: saveStore
            )
        )
    }

    /// Initialize and immediately start a new game with the given scenario.
    convenience init(
        startNewWithScenario scenario: String,
        partyPlan: PartyBuildPlan? = nil,
        dependencies: RunDependencies
    ) {
        self.init(dependencies: dependencies)
        startNewRun(scenario: scenario, partyPlan: partyPlan)
    }

    /// Initialize and immediately start a new game with the given scenario.
    convenience init(
        startNewWithScenario scenario: String,
        partyPlan: PartyBuildPlan? = nil,
        runtime: ScenarioRuntime = ScenarioRuntime(),
        rollRules: RollRulesEngine = RollRulesEngine(),
        saveStore: SaveGameStore = SaveGameStore()
    ) {
        self.init(
            startNewWithScenario: scenario,
            partyPlan: partyPlan,
            dependencies: RunDependencies(
                runtime: runtime,
                rollRules: rollRules,
                saveStore: saveStore
            )
        )
    }

    /// Persist the current game state to disk.
    func saveGame() {
        do {
            print("Attempting to save game to: \(saveStore.saveURL.path)")
            try runSessionController.saveGame(gameState)
        } catch {
            print("Failed to save game: \(error)")
        }
    }

    /// Attempt to load a saved game from disk. Returns `true` on success.
    func loadGame() -> Bool {
        guard runSessionController.saveExists() else { return false }
        do {
            self.gameState = try runSessionController.loadGame(using: &runtime)
            return true
        } catch {
            print("Failed to load game: \(error)")
            return false
        }
    }

    // --- Core Logic Functions for the Sprint ---

    func calculateProjection(for action: ActionOption, with character: Character, interactableTags tags: [String] = []) -> RollProjectionDetails {
        rollRules.calculateProjection(
            for: action,
            with: character,
            interactableTags: tags,
            harmFamilies: activeHarmFamilies
        )
    }

    func getRollContext(for action: ActionOption, with character: Character, interactableTags tags: [String] = []) -> (baseProjection: RollProjectionDetails, optionalModifiers: [SelectableModifierInfo]) {
        rollRules.getRollContext(
            for: action,
            with: character,
            interactableTags: tags,
            harmFamilies: activeHarmFamilies
        )
    }

    func calculateEffectiveProjection(baseProjection: RollProjectionDetails, applying chosenModifierStructs: [Modifier]) -> RollProjectionDetails {
        rollRules.calculateEffectiveProjection(baseProjection: baseProjection, applying: chosenModifierStructs)
    }

    func clearPendingResolution() {
        gameState.pendingResolution = nil
        saveGame()
    }

    func pendingResolutionText() -> String {
        gameState.pendingResolution?.resolvedText ?? ""
    }

    func pendingResolutionEntries() -> [String] {
        gameState.pendingResolution?.resolvedDescriptions ?? []
    }

    func pendingResolutionCharacter() -> Character? {
        guard let context = gameState.pendingResolution?.activeContext else { return nil }
        return context.character(in: gameState)
    }

    func pendingResistanceAttribute() -> ResistanceAttribute? {
        gameState.pendingResolution?.pendingResistance?.attribute
    }

    func pendingResistanceDicePool() -> Int? {
        guard let attribute = pendingResistanceAttribute(),
              let character = pendingResolutionCharacter() else { return nil }
        return attribute.dicePool(for: character)
    }

    func pendingResistanceQueuePreview(limit: Int = 3) -> [PendingResistanceState] {
        pendingResolutionDriver.previewUpcomingResistances(
            in: gameState,
            limit: limit
        )
    }

    @discardableResult
    func choosePendingChoice(at index: Int) -> String {
        let result = pendingResolutionDriver.choosePendingChoice(
            at: index,
            in: &gameState
        )
        saveGame()
        return result
    }

    @discardableResult
    func acceptPendingResistance() -> String {
        let result = pendingResolutionDriver.acceptPendingResistance(
            in: &gameState
        )
        saveGame()
        return result
    }

    @discardableResult
    func resistPendingConsequence(usingDice diceResults: [Int]? = nil) -> ConsequenceExecutor.ResistanceRollOutcome? {
        let resolvedDice = diceResults ?? debugResistanceDiceOverride()
        guard let rollOutcome = pendingResolutionDriver.resistPendingConsequence(
            usingDice: resolvedDice,
            in: &gameState
        ) else {
            return nil
        }
        saveGame()
        return rollOutcome
    }

    /// Executes a free action that does not require a roll, applying its success
    /// consequences immediately.
    func performFreeAction(for action: ActionOption, with character: Character, interactableID: String?) -> String {
        if let unavailableMessage = unavailableActionMessage(
            for: action,
            interactableID: interactableID,
            characterID: character.id
        ) {
            return unavailableMessage
        }
        let description = actionResolver.performFreeAction(
            for: action,
            with: character,
            interactableID: interactableID,
            in: &gameState
        )
        saveGame()
        return description
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption,
                       with character: Character,
                       interactableID: String?,
                       usingDice diceResults: [Int]? = nil,
                       chosenOptionalModifierIDs: [UUID] = []) -> DiceRollResult {
        if let unavailableMessage = unavailableActionMessage(
            for: action,
            interactableID: interactableID,
            characterID: character.id
        ) {
            return DiceRollResult(
                highestRoll: 0,
                outcome: "Cannot",
                consequences: unavailableMessage,
                actualDiceRolled: nil,
                isCritical: nil,
                finalEffect: nil,
                isAwaitingDecision: false
            )
        }
        let result = actionResolver.performAction(
            for: action,
            with: character,
            interactableID: interactableID,
            usingDice: diceResults,
            chosenOptionalModifierIDs: chosenOptionalModifierIDs,
            partyMovementMode: partyMovementMode,
            in: &gameState
        )
        saveGame()
        return result
    }

    func pushYourself(forCharacter character: Character) {
        actionResolver.pushYourself(for: character, in: &gameState)
    }

    /// Starts a brand new run, resetting the game state. The scenario id
    /// corresponds to a folder within `Content/Scenarios`.
    func startNewRun(scenario: String = RuntimeDefaults.defaultScenarioID, partyPlan: PartyBuildPlan? = nil) {
        do {
            self.gameState = try runSessionController.startNewRun(
                scenario: scenario,
                partyPlan: partyPlan,
                using: &runtime
            )
        } catch {
            print("Failed to start new run: \(error)")
        }
    }

    func restartCurrentScenario() {
        do {
            self.gameState = try runSessionController.restartCurrentScenario(
                from: gameState,
                using: &runtime
            )
        } catch {
            print("Failed to restart scenario: \(error)")
        }
    }

    /// Move one or all party members depending on the current movement mode.
    func move(characterID: UUID, to connection: NodeConnection) {
        do {
            _ = try runSessionController.move(
                characterID: characterID,
                to: connection,
                movingGroupedParty: partyMovementMode == .grouped,
                using: &runtime,
                in: &gameState
            )
        } catch {
            print("Failed to move party: \(error)")
        }
    }

}
