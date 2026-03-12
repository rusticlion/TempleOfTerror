import Foundation

enum RuntimeDefaults {
    static let defaultScenarioID = "temple_of_terror"
    static let genericDefeatText = "The expedition claims another party."
}

enum GameStatus: String, Codable {
    case playing
    case gameOver
}

enum RunOutcome: String, Codable {
    case defeat
    case escaped
    case victory
}

enum PartyBuildMode: String, Codable, Equatable {
    case randomNative
    case randomFullRoster
    case manualSelection
}

struct PartyBuildPlan: Codable, Equatable {
    var partySize: Int
    var nativeArchetypeIDs: [String]
    var selectedArchetypeIDs: [String]
    var mode: PartyBuildMode
}

enum ResistanceAttribute: String, Codable, CaseIterable {
    case insight
    case prowess
    case resolve

    var title: String {
        rawValue.capitalized
    }

    var actionTypes: [String] {
        switch self {
        case .insight:
            return ["Study", "Survey", "Hunt", "Tinker"]
        case .prowess:
            return ["Prowl", "Finesse", "Wreck", "Skirmish"]
        case .resolve:
            return ["Attune", "Command", "Consort", "Sway"]
        }
    }

    func dicePool(for character: Character) -> Int {
        actionTypes.reduce(0) { partialResult, actionType in
            partialResult + max(character.actions[actionType] ?? 0, 0)
        }
    }
}

struct ResistanceRule: Codable {
    var attribute: ResistanceAttribute
    var amount: Int? = nil
}

struct ConsequenceContext: Codable {
    let characterID: UUID
    let interactableID: String?
    let finalEffect: RollEffect
    let finalPosition: RollPosition
    let isCritical: Bool

    func character(in gameState: GameState) -> Character? {
        gameState.party.first(where: { $0.id == characterID })
    }
}

enum ResolutionSource: String, Codable {
    case roll
    case freeAction
}

struct PendingRollPresentation: Codable {
    var characterID: UUID
    var actionName: String
    var highestRoll: Int
    var outcome: String
    var actualDiceRolled: [Int]?
    var isCritical: Bool
    var finalEffect: RollEffect?
}

struct PendingChoiceState: Codable {
    var prompt: String?
    var options: [ChoiceOption]
}

struct PendingResistanceState: Codable {
    var consequence: Consequence
    var prompt: String?
    var attribute: ResistanceAttribute
    var title: String
    var summary: String
    var resistPreview: String
    var sequenceIndex: Int
    var sequenceTotal: Int

    init(
        consequence: Consequence,
        prompt: String?,
        attribute: ResistanceAttribute,
        title: String = "Consequence",
        summary: String = "",
        resistPreview: String = "",
        sequenceIndex: Int = 1,
        sequenceTotal: Int = 1
    ) {
        self.consequence = consequence
        self.prompt = prompt
        self.attribute = attribute
        self.title = title
        self.summary = summary
        self.resistPreview = resistPreview
        self.sequenceIndex = sequenceIndex
        self.sequenceTotal = sequenceTotal
    }

    enum CodingKeys: String, CodingKey {
        case consequence, prompt, attribute, title, summary, resistPreview
        case sequenceIndex, sequenceTotal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        consequence = try container.decode(Consequence.self, forKey: .consequence)
        prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
        attribute = try container.decode(ResistanceAttribute.self, forKey: .attribute)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Consequence"
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        resistPreview = try container.decodeIfPresent(String.self, forKey: .resistPreview) ?? ""
        sequenceIndex = max(try container.decodeIfPresent(Int.self, forKey: .sequenceIndex) ?? 1, 1)
        sequenceTotal = max(try container.decodeIfPresent(Int.self, forKey: .sequenceTotal) ?? 1, sequenceIndex)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(consequence, forKey: .consequence)
        try container.encodeIfPresent(prompt, forKey: .prompt)
        try container.encode(attribute, forKey: .attribute)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(resistPreview, forKey: .resistPreview)
        try container.encode(sequenceIndex, forKey: .sequenceIndex)
        try container.encode(sequenceTotal, forKey: .sequenceTotal)
    }
}

struct ConsequenceResolutionFrame: Codable {
    var context: ConsequenceContext
    var remainingConsequences: [Consequence]
}

struct PendingConsequenceResolution: Codable {
    var source: ResolutionSource
    var frames: [ConsequenceResolutionFrame]
    var resolvedDescriptions: [String]
    var pendingChoice: PendingChoiceState?
    var pendingResistance: PendingResistanceState?
    var rollPresentation: PendingRollPresentation?
    var requiresAcknowledgement: Bool = false
    var resolvedResistanceCount: Int = 0

    init(
        source: ResolutionSource,
        frames: [ConsequenceResolutionFrame],
        resolvedDescriptions: [String],
        pendingChoice: PendingChoiceState?,
        pendingResistance: PendingResistanceState?,
        rollPresentation: PendingRollPresentation?,
        requiresAcknowledgement: Bool = false,
        resolvedResistanceCount: Int = 0
    ) {
        self.source = source
        self.frames = frames
        self.resolvedDescriptions = resolvedDescriptions
        self.pendingChoice = pendingChoice
        self.pendingResistance = pendingResistance
        self.rollPresentation = rollPresentation
        self.requiresAcknowledgement = requiresAcknowledgement
        self.resolvedResistanceCount = resolvedResistanceCount
    }

    enum CodingKeys: String, CodingKey {
        case source, frames, resolvedDescriptions, pendingChoice
        case pendingResistance, rollPresentation, requiresAcknowledgement
        case resolvedResistanceCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(ResolutionSource.self, forKey: .source)
        frames = try container.decode([ConsequenceResolutionFrame].self, forKey: .frames)
        resolvedDescriptions = try container.decodeIfPresent([String].self, forKey: .resolvedDescriptions) ?? []
        pendingChoice = try container.decodeIfPresent(PendingChoiceState.self, forKey: .pendingChoice)
        pendingResistance = try container.decodeIfPresent(PendingResistanceState.self, forKey: .pendingResistance)
        rollPresentation = try container.decodeIfPresent(PendingRollPresentation.self, forKey: .rollPresentation)
        requiresAcknowledgement = try container.decodeIfPresent(Bool.self, forKey: .requiresAcknowledgement) ?? false
        resolvedResistanceCount = max(try container.decodeIfPresent(Int.self, forKey: .resolvedResistanceCount) ?? 0, 0)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(frames, forKey: .frames)
        try container.encode(resolvedDescriptions, forKey: .resolvedDescriptions)
        try container.encodeIfPresent(pendingChoice, forKey: .pendingChoice)
        try container.encodeIfPresent(pendingResistance, forKey: .pendingResistance)
        try container.encodeIfPresent(rollPresentation, forKey: .rollPresentation)
        try container.encode(requiresAcknowledgement, forKey: .requiresAcknowledgement)
        try container.encode(resolvedResistanceCount, forKey: .resolvedResistanceCount)
    }

    var resolvedText: String {
        resolvedDescriptions.joined(separator: "\n")
    }

    var isAwaitingDecision: Bool {
        pendingChoice != nil || pendingResistance != nil
    }

    var isComplete: Bool {
        !isAwaitingDecision && frames.isEmpty
    }

    var activeContext: ConsequenceContext? {
        frames.first?.context
    }
}

struct GameState: Codable {
    /// Identifier for the scenario that generated this run. Used when loading
    /// to reinitialize the `ContentLoader` with the correct data bundle.
    var scenarioName: String = RuntimeDefaults.defaultScenarioID

    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location (legacy)
    // Use String keys for JSON compatibility
    var characterLocations: [String: UUID] = [:] // Individual character locations
    var status: GameStatus = .playing
    var runOutcome: RunOutcome? = nil
    var runOutcomeText: String? = nil
    var scenarioFlags: [String: Bool] = [:]
    var scenarioCounters: [String: Int] = [:]
    var launchPartyPlan: PartyBuildPlan? = nil
    var pendingResolution: PendingConsequenceResolution? = nil
    // ... other global state can be added later

    enum CodingKeys: String, CodingKey {
        case scenarioName, party, activeClocks, dungeon, currentNodeID
        case characterLocations, status, runOutcome, runOutcomeText
        case scenarioFlags, scenarioCounters, launchPartyPlan, pendingResolution
    }

    init(
        scenarioName: String = RuntimeDefaults.defaultScenarioID,
        party: [Character] = [],
        activeClocks: [GameClock] = [],
        dungeon: DungeonMap? = nil,
        currentNodeID: UUID? = nil,
        characterLocations: [String: UUID] = [:],
        status: GameStatus = .playing,
        runOutcome: RunOutcome? = nil,
        runOutcomeText: String? = nil,
        scenarioFlags: [String: Bool] = [:],
        scenarioCounters: [String: Int] = [:],
        launchPartyPlan: PartyBuildPlan? = nil,
        pendingResolution: PendingConsequenceResolution? = nil
    ) {
        self.scenarioName = scenarioName
        self.party = party
        self.activeClocks = activeClocks
        self.dungeon = dungeon
        self.currentNodeID = currentNodeID
        self.characterLocations = characterLocations
        self.status = status
        self.runOutcome = runOutcome
        self.runOutcomeText = runOutcomeText
        self.scenarioFlags = scenarioFlags
        self.scenarioCounters = scenarioCounters
        self.launchPartyPlan = launchPartyPlan
        self.pendingResolution = pendingResolution
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scenarioName = try container.decodeIfPresent(String.self, forKey: .scenarioName) ?? RuntimeDefaults.defaultScenarioID
        party = try container.decodeIfPresent([Character].self, forKey: .party) ?? []
        activeClocks = try container.decodeIfPresent([GameClock].self, forKey: .activeClocks) ?? []
        dungeon = try container.decodeIfPresent(DungeonMap.self, forKey: .dungeon)
        currentNodeID = try container.decodeIfPresent(UUID.self, forKey: .currentNodeID)
        characterLocations = try container.decodeIfPresent([String: UUID].self, forKey: .characterLocations) ?? [:]
        status = try container.decodeIfPresent(GameStatus.self, forKey: .status) ?? .playing
        runOutcome = try container.decodeIfPresent(RunOutcome.self, forKey: .runOutcome)
        runOutcomeText = try container.decodeIfPresent(String.self, forKey: .runOutcomeText)
        scenarioFlags = try container.decodeIfPresent([String: Bool].self, forKey: .scenarioFlags) ?? [:]
        scenarioCounters = try container.decodeIfPresent([String: Int].self, forKey: .scenarioCounters) ?? [:]
        launchPartyPlan = try container.decodeIfPresent(PartyBuildPlan.self, forKey: .launchPartyPlan)
        pendingResolution = try container.decodeIfPresent(PendingConsequenceResolution.self, forKey: .pendingResolution)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scenarioName, forKey: .scenarioName)
        try container.encode(party, forKey: .party)
        try container.encode(activeClocks, forKey: .activeClocks)
        try container.encodeIfPresent(dungeon, forKey: .dungeon)
        try container.encodeIfPresent(currentNodeID, forKey: .currentNodeID)
        try container.encode(characterLocations, forKey: .characterLocations)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(runOutcome, forKey: .runOutcome)
        try container.encodeIfPresent(runOutcomeText, forKey: .runOutcomeText)
        if !scenarioFlags.isEmpty {
            try container.encode(scenarioFlags, forKey: .scenarioFlags)
        }
        if !scenarioCounters.isEmpty {
            try container.encode(scenarioCounters, forKey: .scenarioCounters)
        }
        try container.encodeIfPresent(launchPartyPlan, forKey: .launchPartyPlan)
        try container.encodeIfPresent(pendingResolution, forKey: .pendingResolution)
    }
}

/// A general-purpose modifier that can adjust action rolls.
struct Modifier: Codable {
    var id: UUID = UUID()
    var bonusDice: Int = 0
    var improvePosition: Bool = false
    var improveEffect: Bool = false
    var applicableToAction: String? = nil
    /// New: list of action types this modifier applies to. Supersedes
    /// `applicableToAction` when provided.
    var applicableActions: [String]? = nil
    /// Optional tag that the interactable must have for this modifier to apply.
    var requiredTag: String? = nil
    var uses: Int = 1
    var isOptionalToApply: Bool = true
    var description: String
    var usedLegacyActionTypeAlias: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, bonusDice, improvePosition, improveEffect
        case applicableToAction, applicableActions, actionType
        case requiredTag, uses, isOptionalToApply, description
    }

    init(id: UUID = UUID(),
         bonusDice: Int = 0,
         improvePosition: Bool = false,
         improveEffect: Bool = false,
         applicableToAction: String? = nil,
         applicableActions: [String]? = nil,
         requiredTag: String? = nil,
         uses: Int = 1,
         isOptionalToApply: Bool = true,
         description: String) {
        self.id = id
        self.bonusDice = bonusDice
        self.improvePosition = improvePosition
        self.improveEffect = improveEffect
        self.applicableToAction = applicableToAction
        self.applicableActions = applicableActions
        self.requiredTag = requiredTag
        self.uses = uses
        self.isOptionalToApply = isOptionalToApply
        self.description = description
        self.usedLegacyActionTypeAlias = false
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        bonusDice = try container.decodeIfPresent(Int.self, forKey: .bonusDice) ?? 0
        improvePosition = try container.decodeIfPresent(Bool.self, forKey: .improvePosition) ?? false
        improveEffect = try container.decodeIfPresent(Bool.self, forKey: .improveEffect) ?? false
        let legacyActionType = try container.decodeIfPresent(String.self, forKey: .actionType)
        applicableToAction = try container.decodeIfPresent(String.self, forKey: .applicableToAction) ?? legacyActionType
        applicableActions = try container.decodeIfPresent([String].self, forKey: .applicableActions)
        requiredTag = try container.decodeIfPresent(String.self, forKey: .requiredTag)
        if applicableActions == nil, let single = applicableToAction {
            applicableActions = [single]
        }
        uses = try container.decodeIfPresent(Int.self, forKey: .uses) ?? 1
        isOptionalToApply = try container.decodeIfPresent(Bool.self, forKey: .isOptionalToApply) ?? true
        description = try container.decode(String.self, forKey: .description)
        usedLegacyActionTypeAlias = legacyActionType != nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bonusDice, forKey: .bonusDice)
        try container.encode(improvePosition, forKey: .improvePosition)
        try container.encode(improveEffect, forKey: .improveEffect)
        if let actions = applicableActions {
            if actions.count == 1 {
                try container.encode(actions.first, forKey: .applicableToAction)
            } else {
                try container.encode(actions, forKey: .applicableActions)
            }
        } else if let applicableToAction {
            try container.encode(applicableToAction, forKey: .applicableToAction)
        }
        try container.encodeIfPresent(requiredTag, forKey: .requiredTag)
        try container.encode(uses, forKey: .uses)
        try container.encode(isOptionalToApply, forKey: .isOptionalToApply)
        try container.encode(description, forKey: .description)
    }

    /// Short summary combining mechanical effects for compact displays.
    var shortDescription: String {
        var parts: [String] = []
        if bonusDice != 0 { parts.append("+\(bonusDice)d") }
        if improvePosition { parts.append("Pos+") }
        if improveEffect { parts.append("Effect+") }
        if parts.isEmpty { return description }
        return parts.joined(separator: ", ")
    }

    /// Detailed description including effect keywords and base text.
    var longDescription: String {
        var parts: [String] = []
        if bonusDice != 0 { parts.append("+\(bonusDice)d") }
        if improvePosition { parts.append("Improved Position") }
        if improveEffect { parts.append("+1 Effect") }
        let detail = parts.joined(separator: ", ")
        if detail.isEmpty { return description }
        return "\(detail) - \(description)"
    }
}

/// A collectible treasure that grants a modifier when acquired.
struct Treasure: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var grantedModifier: Modifier
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, name, description, grantedModifier, tags
    }

    init(id: String,
         name: String,
         description: String,
         grantedModifier: Modifier,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.description = description
        var mod = grantedModifier
        mod.isOptionalToApply = true
        self.grantedModifier = mod
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        var mod = try container.decode(Modifier.self, forKey: .grantedModifier)
        mod.isOptionalToApply = true
        grantedModifier = mod
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(grantedModifier, forKey: .grantedModifier)
        if !tags.isEmpty {
            try container.encode(tags, forKey: .tags)
        }
    }
}

struct Character: Identifiable, Codable {
    let id: UUID
    var name: String
    var archetypeID: String?
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
    var traitTags: [String] = []
    var stateTags: [String] = []
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
    /// Whether this character can still act. Characters become defeated after
    /// suffering Fatal Harm.
    var isDefeated: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, name, archetypeID, characterClass, stress, harm, actions
        case traitTags, stateTags, treasures, modifiers, isDefeated
    }

    init(id: UUID,
         name: String,
         archetypeID: String? = nil,
         characterClass: String,
         stress: Int,
         harm: HarmState,
         actions: [String: Int],
         traitTags: [String] = [],
         stateTags: [String] = [],
         treasures: [Treasure] = [],
         modifiers: [Modifier] = [],
         isDefeated: Bool = false) {
        self.id = id
        self.name = name
        self.archetypeID = archetypeID
        self.characterClass = characterClass
        self.stress = stress
        self.harm = harm
        self.actions = actions
        self.traitTags = Character.normalizedTags(traitTags)
        self.stateTags = Character.normalizedTags(stateTags)
        self.treasures = treasures
        self.modifiers = modifiers
        self.isDefeated = isDefeated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        archetypeID = try container.decodeIfPresent(String.self, forKey: .archetypeID)
        characterClass = try container.decode(String.self, forKey: .characterClass)
        stress = try container.decode(Int.self, forKey: .stress)
        harm = try container.decode(HarmState.self, forKey: .harm)
        actions = try container.decode([String: Int].self, forKey: .actions)
        traitTags = Character.normalizedTags(
            try container.decodeIfPresent([String].self, forKey: .traitTags) ?? []
        )
        stateTags = Character.normalizedTags(
            try container.decodeIfPresent([String].self, forKey: .stateTags) ?? []
        )
        treasures = try container.decodeIfPresent([Treasure].self, forKey: .treasures) ?? []
        modifiers = try container.decodeIfPresent([Modifier].self, forKey: .modifiers) ?? []
        isDefeated = try container.decodeIfPresent(Bool.self, forKey: .isDefeated) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(archetypeID, forKey: .archetypeID)
        try container.encode(characterClass, forKey: .characterClass)
        try container.encode(stress, forKey: .stress)
        try container.encode(harm, forKey: .harm)
        try container.encode(actions, forKey: .actions)
        if !traitTags.isEmpty {
            try container.encode(traitTags, forKey: .traitTags)
        }
        if !stateTags.isEmpty {
            try container.encode(stateTags, forKey: .stateTags)
        }
        if !treasures.isEmpty {
            try container.encode(treasures, forKey: .treasures)
        }
        if !modifiers.isEmpty {
            try container.encode(modifiers, forKey: .modifiers)
        }
        if isDefeated {
            try container.encode(isDefeated, forKey: .isDefeated)
        }
    }

    var allTags: [String] {
        Character.normalizedTags(traitTags + stateTags)
    }

    func hasTag(_ tag: String) -> Bool {
        allTags.contains(tag)
    }

    mutating func addStateTag(_ tag: String) -> Bool {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !stateTags.contains(trimmed), !traitTags.contains(trimmed) else { return false }
        stateTags.append(trimmed)
        stateTags = Character.normalizedTags(stateTags)
        return true
    }

    mutating func removeStateTag(_ tag: String) -> Bool {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let originalCount = stateTags.count
        stateTags.removeAll { $0 == trimmed }
        return stateTags.count != originalCount
    }

    private static func normalizedTags(_ tags: [String]) -> [String] {
        var seen: Set<String> = []
        var normalized: [String] = []
        for tag in tags {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(trimmed).inserted else { continue }
            normalized.append(trimmed)
        }
        return normalized
    }
}

/// Defines a single tier of a harm family.
struct HarmTier: Codable {
    var description: String
    var penalty: Penalty? // Penalty is optional for the "Fatal" tier
    var boon: Modifier? // Optional boon granted while this harm is active

    enum CodingKeys: String, CodingKey {
        case description, penalty, boon
    }

    init(description: String, penalty: Penalty? = nil, boon: Modifier? = nil) {
        self.description = description
        self.penalty = penalty
        if var mod = boon {
            mod.isOptionalToApply = false
            self.boon = mod
        } else {
            self.boon = nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        penalty = try container.decodeIfPresent(Penalty.self, forKey: .penalty)
        if var mod = try container.decodeIfPresent(Modifier.self, forKey: .boon) {
            mod.isOptionalToApply = false
            boon = mod
        } else {
            boon = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(penalty, forKey: .penalty)
        try container.encodeIfPresent(boon, forKey: .boon)
    }
}

/// Defines a full "family" of related harms, from minor to fatal.
struct HarmFamily: Codable, Identifiable {
    let id: String // e.g., "head_trauma", "leg_injury"
    var lesser: HarmTier
    var moderate: HarmTier
    var severe: HarmTier
    var fatal: HarmTier // The "game over" description
}

/// The mechanical penalty imposed by a HarmTier.
enum Penalty: Codable {
    case reduceEffect(requiredTag: String? = nil)               // All actions are one effect level lower.
    case increaseStressCost(amount: Int, requiredTag: String? = nil) // Stress costs are increased.
    case actionPenalty(actionType: String, requiredTag: String? = nil) // Specific action suffers –1 die.
    case banAction(actionType: String, requiredTag: String? = nil) // An action is impossible without effort
    case actionPositionPenalty(actionType: String, requiredTag: String? = nil) // Specific action worsens position
    case actionEffectPenalty(actionType: String, requiredTag: String? = nil) // Specific action suffers -1 Effect

    /// Short summary suitable for compact UI displays.
    var shortDescription: String {
        switch self {
        case .reduceEffect:
            return "-1 Effect"
        case .increaseStressCost(let amount, _):
            return "+\(amount) Stress cost"
        case .actionPenalty(let actionType, _):
            return "\(actionType) -1d"
        case .banAction(let actionType, _):
            return "No \(actionType)"
        case .actionPositionPenalty(let actionType, _):
            return "\(actionType) Pos-"
        case .actionEffectPenalty(let actionType, _):
            return "\(actionType) Eff-"
        }
    }

    /// Full sentence explanation of the penalty.
    var longDescription: String {
        switch self {
        case .reduceEffect:
            return "All actions suffer -1 Effect."
        case .increaseStressCost(let amount, _):
            return "Stress costs are increased by \(amount)."
        case .actionPenalty(let actionType, _):
            return "\(actionType) rolls -1 die."
        case .banAction(let actionType, _):
            return "Cannot perform \(actionType)."
        case .actionPositionPenalty(let actionType, _):
            return "\(actionType) rolls at worse Position."
        case .actionEffectPenalty(let actionType, _):
            return "\(actionType) suffers -1 Effect."
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, amount, actionType, requiredTag
    }

    private enum Kind: String, Codable {
        case reduceEffect
        case increaseStressCost
        case actionPenalty
        case banAction
        case actionPositionPenalty
        case actionEffectPenalty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        let tag = try container.decodeIfPresent(String.self, forKey: .requiredTag)
        switch kind {
        case .reduceEffect:
            self = .reduceEffect(requiredTag: tag)
        case .increaseStressCost:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .increaseStressCost(amount: amount, requiredTag: tag)
        case .actionPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionPenalty(actionType: action, requiredTag: tag)
        case .banAction:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .banAction(actionType: action, requiredTag: tag)
        case .actionPositionPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionPositionPenalty(actionType: action, requiredTag: tag)
        case .actionEffectPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionEffectPenalty(actionType: action, requiredTag: tag)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reduceEffect(let tag):
            try container.encode(Kind.reduceEffect, forKey: .type)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        case .increaseStressCost(let amount, let tag):
            try container.encode(Kind.increaseStressCost, forKey: .type)
            try container.encode(amount, forKey: .amount)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        case .actionPenalty(let action, let tag):
            try container.encode(Kind.actionPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        case .banAction(let action, let tag):
            try container.encode(Kind.banAction, forKey: .type)
            try container.encode(action, forKey: .actionType)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        case .actionPositionPenalty(let action, let tag):
            try container.encode(Kind.actionPositionPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        case .actionEffectPenalty(let action, let tag):
            try container.encode(Kind.actionEffectPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
            try container.encodeIfPresent(tag, forKey: .requiredTag)
        }
    }
}

/// HarmState now tracks detailed conditions rather than simple strings.
struct HarmState: Codable {
    // We store the family ID along with the specific description.
    var lesser: [(familyId: String, description: String)] = []
    var moderate: [(familyId: String, description: String)] = []
    var severe: [(familyId: String, description: String)] = []

    static let lesserSlots = 2
    static let moderateSlots = 2
    static let severeSlots = 1

    private struct Entry: Codable {
        var familyId: String
        var description: String
    }

    private enum CodingKeys: String, CodingKey {
        case lesser, moderate, severe
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lesserEntries = try container.decodeIfPresent([Entry].self, forKey: .lesser) ?? []
        let moderateEntries = try container.decodeIfPresent([Entry].self, forKey: .moderate) ?? []
        let severeEntries = try container.decodeIfPresent([Entry].self, forKey: .severe) ?? []
        self.lesser = lesserEntries.map { ($0.familyId, $0.description) }
        self.moderate = moderateEntries.map { ($0.familyId, $0.description) }
        self.severe = severeEntries.map { ($0.familyId, $0.description) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lesser.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .lesser)
        try container.encode(moderate.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .moderate)
        try container.encode(severe.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .severe)
    }
}

struct ArchetypeDefinition: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var description: String
    var defaultActions: [String: Int]
    var personalityTagPool: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, name, description, defaultActions, personalityTagPool
    }

    init(
        id: String,
        name: String,
        description: String,
        defaultActions: [String: Int],
        personalityTagPool: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultActions = defaultActions
        self.personalityTagPool = personalityTagPool
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        defaultActions = try container.decode([String: Int].self, forKey: .defaultActions)
        personalityTagPool = try container.decodeIfPresent([String].self, forKey: .personalityTagPool)?
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(defaultActions, forKey: .defaultActions)
        if !personalityTagPool.isEmpty {
            try container.encode(personalityTagPool, forKey: .personalityTagPool)
        }
    }
}

struct GameClock: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
    var onCompleteConsequences: [Consequence]? = nil
    var onTickConsequences: [Consequence]? = nil

    enum CodingKeys: String, CodingKey {
        case name, segments, progress
        case onCompleteConsequences, onTickConsequences
    }

    init(name: String,
         segments: Int,
         progress: Int,
         onCompleteConsequences: [Consequence]? = nil,
         onTickConsequences: [Consequence]? = nil) {
        self.name = name
        self.segments = segments
        self.progress = progress
        self.onCompleteConsequences = onCompleteConsequences
        self.onTickConsequences = onTickConsequences
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        segments = try container.decode(Int.self, forKey: .segments)
        progress = try container.decode(Int.self, forKey: .progress)
        onCompleteConsequences = try container.decodeIfPresent([Consequence].self, forKey: .onCompleteConsequences)
        onTickConsequences = try container.decodeIfPresent([Consequence].self, forKey: .onTickConsequences)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(segments, forKey: .segments)
        try container.encode(progress, forKey: .progress)
        try container.encodeIfPresent(onCompleteConsequences, forKey: .onCompleteConsequences)
        try container.encodeIfPresent(onTickConsequences, forKey: .onTickConsequences)
    }
}

// Models for the interactable itself
struct Interactable: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var availableActions: [ActionOption]
    var conditions: [GameCondition]? = nil
    var isThreat: Bool = false
    var usableUnderThreat: Bool = false
    var isDisplayOnly: Bool = false
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions, conditions
        case isThreat, usableUnderThreat, isDisplayOnly, tags
    }

    init(id: String,
         title: String,
         description: String,
         availableActions: [ActionOption],
         conditions: [GameCondition]? = nil,
         isThreat: Bool = false,
         usableUnderThreat: Bool = false,
         isDisplayOnly: Bool = false,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
        self.conditions = conditions
        self.isThreat = isThreat
        self.usableUnderThreat = usableUnderThreat
        self.isDisplayOnly = isDisplayOnly
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
        conditions = try container.decodeIfPresent([GameCondition].self, forKey: .conditions)
        isThreat = try container.decodeIfPresent(Bool.self, forKey: .isThreat) ?? false
        usableUnderThreat = try container.decodeIfPresent(Bool.self, forKey: .usableUnderThreat) ?? false
        isDisplayOnly = try container.decodeIfPresent(Bool.self, forKey: .isDisplayOnly) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(availableActions, forKey: .availableActions)
        try container.encodeIfPresent(conditions, forKey: .conditions)
        if isThreat {
            try container.encode(isThreat, forKey: .isThreat)
        }
        if usableUnderThreat {
            try container.encode(usableUnderThreat, forKey: .usableUnderThreat)
        }
        if isDisplayOnly {
            try container.encode(isDisplayOnly, forKey: .isDisplayOnly)
        }
        if !tags.isEmpty {
            try container.encode(tags, forKey: .tags)
        }
    }
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    /// Whether this action requires a dice roll. If false, success consequences
    /// are applied immediately when tapped.
    var requiresTest: Bool = true
    var isGroupAction: Bool = false
    var requiredTag: String? = nil
    var conditions: [GameCondition]? = nil
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, requiresTest
        case isGroupAction, requiredTag, conditions, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         isGroupAction: Bool = false,
         requiresTest: Bool = true,
         requiredTag: String? = nil,
         conditions: [GameCondition]? = nil,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.requiresTest = requiresTest
        self.isGroupAction = isGroupAction
        self.requiredTag = requiredTag
        self.conditions = conditions
        self.outcomes = outcomes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actionType = try container.decode(String.self, forKey: .actionType)
        position = try container.decode(RollPosition.self, forKey: .position)
        effect = try container.decode(RollEffect.self, forKey: .effect)
        isGroupAction = try container.decodeIfPresent(Bool.self, forKey: .isGroupAction) ?? false
        requiresTest = try container.decodeIfPresent(Bool.self, forKey: .requiresTest) ?? true
        requiredTag = try container.decodeIfPresent(String.self, forKey: .requiredTag)
        conditions = try container.decodeIfPresent([GameCondition].self, forKey: .conditions)
        let rawOutcomes = try container.decodeIfPresent([String: [Consequence]].self, forKey: .outcomes) ?? [:]
        var mapped: [RollOutcome: [Consequence]] = [:]
        for (key, value) in rawOutcomes {
            if let outcome = RollOutcome(rawValue: key) {
                mapped[outcome] = value
            }
        }
        outcomes = mapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(actionType, forKey: .actionType)
        try container.encode(position, forKey: .position)
        try container.encode(effect, forKey: .effect)
        if !requiresTest {
            try container.encode(requiresTest, forKey: .requiresTest)
        }
        if isGroupAction {
            try container.encode(isGroupAction, forKey: .isGroupAction)
        }
        try container.encodeIfPresent(requiredTag, forKey: .requiredTag)
        try container.encodeIfPresent(conditions, forKey: .conditions)
        var raw: [String: [Consequence]] = [:]
        for (key, value) in outcomes { raw[key.rawValue] = value }
        try container.encode(raw, forKey: .outcomes)
    }
}

extension ActionOption: Identifiable {
    var id: String { name }
}

enum RollOutcome: String, Codable {
    case success
    case partial
    case failure
}

// MARK: - Conditional Consequences Support

struct GameCondition: Codable {
    enum ConditionType: String, Codable {
        case requiresMinEffectLevel
        case requiresExactEffectLevel
        case requiresMinPositionLevel
        case requiresExactPositionLevel
        case characterHasTreasureId
        case characterHasTag
        case characterLacksTag
        case partyHasTreasureWithTag
        case partyHasMemberWithTag
        case clockProgress
        case scenarioFlagSet
        case scenarioCounter
    }

    let type: ConditionType
    let stringParam: String?
    let intParam: Int?
    let intParamMax: Int?
    let effectParam: RollEffect?
    let positionParam: RollPosition?

    init(type: ConditionType,
         stringParam: String? = nil,
         intParam: Int? = nil,
         intParamMax: Int? = nil,
         effectParam: RollEffect? = nil,
         positionParam: RollPosition? = nil) {
        self.type = type
        self.stringParam = stringParam
        self.intParam = intParam
        self.intParamMax = intParamMax
        self.effectParam = effectParam
        self.positionParam = positionParam
    }
}

struct ScenarioEvent: Codable, Identifiable {
    let id: String
    var description: String?
    var conditions: [GameCondition]?
    var consequences: [Consequence]
}

/// Represents a selectable option in a `createChoice` consequence.
struct ChoiceOption: Codable {
    var title: String
    var consequences: [Consequence]
}

struct Consequence: Codable {
    enum ConsequenceKind: String, Codable {
        case gainStress
        case adjustStress
        case sufferHarm
        case tickClock
        case unlockConnection
        case removeInteractable
        case removeSelfInteractable
        case removeAction
        case addAction
        case addInteractable
        case addInteractableHere
        case gainTreasure
        case modifyDice
        case createChoice
        case triggerEvent
        case triggerConsequences
        case healHarm
        case setScenarioFlag
        case clearScenarioFlag
        case incrementScenarioCounter
        case setScenarioCounter
        case addCharacterTag
        case removeCharacterTag
        case endRun
    }

    var kind: ConsequenceKind

    // Parameters for the consequence itself
    var amount: Int?
    var level: HarmLevel?
    var familyId: String?
    var clockName: String?
    var fromNodeID: UUID?
    var toNodeID: UUID?
    var interactableId: String?
    var actionName: String?
    var newAction: ActionOption?
    var inNodeID: UUID?
    var newInteractable: Interactable?
    var interactableTemplateID: String?
    var treasureId: String?
    var duration: String?
    var choiceOptions: [ChoiceOption]?
    var eventId: String?
    var triggered: [Consequence]?
    var flagId: String?
    var counterId: String?
    var tag: String?
    var endingOutcome: RunOutcome?
    var endingText: String?
    var resistance: ResistanceRule?

    // Gating Conditions
    var conditions: [GameCondition]?
    
    // Narrative description of the consequence
    var description: String?

    private enum CodingKeys: String, CodingKey {
        case type, amount, level, familyId, clockName
        case fromNodeID, toNodeID, id, inNodeID
        case interactable, interactableTemplateID, treasure, treasureId
        case duration, options, eventId, consequences
        case actionName, action, conditions, description
        case flagId, counterId, tag, runOutcome, runOutcomeText, resistance
    }

    init(kind: ConsequenceKind) {
        self.kind = kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var resolvedKind = try container.decode(ConsequenceKind.self, forKey: .type)

        amount = try container.decodeIfPresent(Int.self, forKey: .amount)
        level = try container.decodeIfPresent(HarmLevel.self, forKey: .level)
        familyId = try container.decodeIfPresent(String.self, forKey: .familyId)
        clockName = try container.decodeIfPresent(String.self, forKey: .clockName)
        fromNodeID = try container.decodeIfPresent(UUID.self, forKey: .fromNodeID)
        toNodeID = try container.decodeIfPresent(UUID.self, forKey: .toNodeID)
        interactableId = try container.decodeIfPresent(String.self, forKey: .id)
        actionName = try container.decodeIfPresent(String.self, forKey: .actionName)
        newAction = nil
        inNodeID = nil
        newInteractable = nil
        interactableTemplateID = nil
        treasureId = nil
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
        choiceOptions = try container.decodeIfPresent([ChoiceOption].self, forKey: .options)
        eventId = try container.decodeIfPresent(String.self, forKey: .eventId)
        triggered = try container.decodeIfPresent([Consequence].self, forKey: .consequences)
        flagId = try container.decodeIfPresent(String.self, forKey: .flagId)
        counterId = try container.decodeIfPresent(String.self, forKey: .counterId)
        tag = try container.decodeIfPresent(String.self, forKey: .tag)
        endingOutcome = try container.decodeIfPresent(RunOutcome.self, forKey: .runOutcome)
        endingText = try container.decodeIfPresent(String.self, forKey: .runOutcomeText)
        resistance = try container.decodeIfPresent(ResistanceRule.self, forKey: .resistance)

        if resolvedKind == .removeInteractable, interactableId == "self" {
            resolvedKind = .removeSelfInteractable
            interactableId = nil
        }
        if resolvedKind == .removeAction, interactableId == "self" {
            interactableId = nil
        }

        if resolvedKind == .addAction {
            newAction = try container.decodeIfPresent(ActionOption.self, forKey: .action)
            if interactableId == "self" {
                interactableId = nil
            }
        } else if resolvedKind == .addInteractable {
            if let nodeString = try? container.decode(String.self, forKey: .inNodeID), nodeString == "current" {
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
                interactableTemplateID = try container.decodeIfPresent(String.self, forKey: .interactableTemplateID)
                resolvedKind = .addInteractableHere
            } else {
                inNodeID = try container.decodeIfPresent(UUID.self, forKey: .inNodeID)
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
                interactableTemplateID = try container.decodeIfPresent(String.self, forKey: .interactableTemplateID)
            }
        } else if resolvedKind == .addInteractableHere {
            newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
            interactableTemplateID = try container.decodeIfPresent(String.self, forKey: .interactableTemplateID)
        }

        if resolvedKind == .gainTreasure {
            if let tid = try container.decodeIfPresent(String.self, forKey: .treasureId) {
                treasureId = tid
            } else if let treasure = try container.decodeIfPresent(Treasure.self, forKey: .treasure) {
                treasureId = treasure.id
            }
        }

        conditions = try container.decodeIfPresent([GameCondition].self, forKey: .conditions)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        kind = resolvedKind
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch kind {
        case .gainStress:
            try container.encode(ConsequenceKind.gainStress, forKey: .type)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .adjustStress:
            try container.encode(ConsequenceKind.adjustStress, forKey: .type)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .sufferHarm:
            try container.encode(ConsequenceKind.sufferHarm, forKey: .type)
            try container.encodeIfPresent(level, forKey: .level)
            try container.encodeIfPresent(familyId, forKey: .familyId)
        case .tickClock:
            try container.encode(ConsequenceKind.tickClock, forKey: .type)
            try container.encodeIfPresent(clockName, forKey: .clockName)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .unlockConnection:
            try container.encode(ConsequenceKind.unlockConnection, forKey: .type)
            try container.encodeIfPresent(fromNodeID, forKey: .fromNodeID)
            try container.encodeIfPresent(toNodeID, forKey: .toNodeID)
        case .removeInteractable:
            try container.encode(ConsequenceKind.removeInteractable, forKey: .type)
            try container.encodeIfPresent(interactableId, forKey: .id)
            try container.encodeIfPresent(actionName, forKey: .actionName)
        case .removeSelfInteractable:
            try container.encode(ConsequenceKind.removeInteractable, forKey: .type)
            try container.encode("self", forKey: .id)
            try container.encodeIfPresent(actionName, forKey: .actionName)
        case .removeAction:
            try container.encode(ConsequenceKind.removeAction, forKey: .type)
            if let id = interactableId {
                try container.encode(id, forKey: .id)
            } else {
                try container.encode("self", forKey: .id)
            }
            try container.encodeIfPresent(actionName, forKey: .actionName)
        case .addAction:
            try container.encode(ConsequenceKind.addAction, forKey: .type)
            if let id = interactableId {
                try container.encode(id, forKey: .id)
            } else {
                try container.encode("self", forKey: .id)
            }
            try container.encodeIfPresent(newAction, forKey: .action)
        case .addInteractable:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encodeIfPresent(inNodeID, forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
            try container.encodeIfPresent(interactableTemplateID, forKey: .interactableTemplateID)
        case .addInteractableHere:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encode("current", forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
            try container.encodeIfPresent(interactableTemplateID, forKey: .interactableTemplateID)
        case .gainTreasure:
            try container.encode(ConsequenceKind.gainTreasure, forKey: .type)
            try container.encodeIfPresent(treasureId, forKey: .treasureId)
        case .modifyDice:
            try container.encode(ConsequenceKind.modifyDice, forKey: .type)
            try container.encodeIfPresent(amount, forKey: .amount)
            try container.encodeIfPresent(duration, forKey: .duration)
        case .createChoice:
            try container.encode(ConsequenceKind.createChoice, forKey: .type)
            try container.encodeIfPresent(choiceOptions, forKey: .options)
        case .triggerEvent:
            try container.encode(ConsequenceKind.triggerEvent, forKey: .type)
            try container.encodeIfPresent(eventId, forKey: .eventId)
        case .triggerConsequences:
            try container.encode(ConsequenceKind.triggerConsequences, forKey: .type)
            try container.encodeIfPresent(triggered, forKey: .consequences)
        case .healHarm:
            try container.encode(ConsequenceKind.healHarm, forKey: .type)
        case .setScenarioFlag:
            try container.encode(ConsequenceKind.setScenarioFlag, forKey: .type)
            try container.encodeIfPresent(flagId, forKey: .flagId)
        case .clearScenarioFlag:
            try container.encode(ConsequenceKind.clearScenarioFlag, forKey: .type)
            try container.encodeIfPresent(flagId, forKey: .flagId)
        case .incrementScenarioCounter:
            try container.encode(ConsequenceKind.incrementScenarioCounter, forKey: .type)
            try container.encodeIfPresent(counterId, forKey: .counterId)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .setScenarioCounter:
            try container.encode(ConsequenceKind.setScenarioCounter, forKey: .type)
            try container.encodeIfPresent(counterId, forKey: .counterId)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .addCharacterTag:
            try container.encode(ConsequenceKind.addCharacterTag, forKey: .type)
            try container.encodeIfPresent(tag, forKey: .tag)
        case .removeCharacterTag:
            try container.encode(ConsequenceKind.removeCharacterTag, forKey: .type)
            try container.encodeIfPresent(tag, forKey: .tag)
        case .endRun:
            try container.encode(ConsequenceKind.endRun, forKey: .type)
            try container.encodeIfPresent(endingOutcome, forKey: .runOutcome)
            try container.encodeIfPresent(endingText, forKey: .runOutcomeText)
        }

        try container.encodeIfPresent(conditions, forKey: .conditions)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(resistance, forKey: .resistance)
    }
}

extension Consequence {
    var effectiveResistanceRule: ResistanceRule? {
        if let resistance {
            return resistance
        }

        switch kind {
        case .sufferHarm:
            return ResistanceRule(attribute: .prowess, amount: 1)
        case .gainStress, .adjustStress:
            return ResistanceRule(attribute: .resolve, amount: 2)
        case .tickClock:
            return ResistanceRule(attribute: .insight, amount: 2)
        default:
            return nil
        }
    }
}

extension Consequence {
    /// Convenience constructor for unlocking a connection between two nodes.
    static func unlockConnection(fromNodeID: UUID, toNodeID: UUID) -> Consequence {
        var consequence = Consequence(kind: .unlockConnection)
        consequence.fromNodeID = fromNodeID
        consequence.toNodeID = toNodeID
        return consequence
    }

    /// Convenience value used when an action removes the interactable that
    /// triggered it.
    static var removeSelfInteractable: Consequence {
        Consequence(kind: .removeSelfInteractable)
    }

    /// Apply stress to the acting character.
    static func gainStress(_ amount: Int) -> Consequence {
        var c = Consequence(kind: .gainStress)
        c.amount = amount
        return c
    }

    /// Adjust stress by a signed amount. Negative values recover stress.
    static func adjustStress(_ amount: Int) -> Consequence {
        var c = Consequence(kind: .adjustStress)
        c.amount = amount
        return c
    }

    /// Inflict harm from a specified family at the given level.
    static func sufferHarm(level: HarmLevel, familyId: String) -> Consequence {
        var c = Consequence(kind: .sufferHarm)
        c.level = level
        c.familyId = familyId
        return c
    }

    /// Progress a named clock by the provided amount.
    static func tickClock(name: String, amount: Int) -> Consequence {
        var c = Consequence(kind: .tickClock)
        c.clockName = name
        c.amount = amount
        return c
    }

    /// Remove the specified interactable from the current node.
    static func removeInteractable(id: String) -> Consequence {
        var c = Consequence(kind: .removeInteractable)
        c.interactableId = id
        return c
    }

    /// Remove a specific action from the given interactable.
    static func removeAction(name: String, fromInteractable id: String) -> Consequence {
        var c = Consequence(kind: .removeAction)
        c.actionName = name
        c.interactableId = id
        return c
    }

    /// Add a specific action to the given interactable.
    static func addAction(_ action: ActionOption, toInteractable id: String) -> Consequence {
        var c = Consequence(kind: .addAction)
        c.newAction = action
        c.interactableId = id
        return c
    }

    /// Add an interactable to the given node.
    static func addInteractable(_ interactable: Interactable, inNodeID: UUID) -> Consequence {
        var c = Consequence(kind: .addInteractable)
        c.newInteractable = interactable
        c.inNodeID = inNodeID
        return c
    }

    /// Add an interactable template to the given node.
    static func addInteractable(templateID: String, inNodeID: UUID) -> Consequence {
        var c = Consequence(kind: .addInteractable)
        c.interactableTemplateID = templateID
        c.inNodeID = inNodeID
        return c
    }

    /// Add an interactable in the acting character's current location.
    static func addInteractableHere(_ interactable: Interactable) -> Consequence {
        var c = Consequence(kind: .addInteractableHere)
        c.newInteractable = interactable
        return c
    }

    /// Add an interactable template in the acting character's current location.
    static func addInteractableHere(templateID: String) -> Consequence {
        var c = Consequence(kind: .addInteractableHere)
        c.interactableTemplateID = templateID
        return c
    }

    /// Grant a treasure by id to the acting character.
    static func gainTreasure(id: String) -> Consequence {
        var c = Consequence(kind: .gainTreasure)
        c.treasureId = id
        return c
    }

    /// Temporarily modify dice rolled for future actions.
    static func modifyDice(amount: Int, duration: String) -> Consequence {
        var c = Consequence(kind: .modifyDice)
        c.amount = amount
        c.duration = duration
        return c
    }

    /// Present the player with a choice of options.
    static func createChoice(options: [ChoiceOption]) -> Consequence {
        var c = Consequence(kind: .createChoice)
        c.choiceOptions = options
        return c
    }

    /// Trigger a named event.
    static func triggerEvent(id: String) -> Consequence {
        var c = Consequence(kind: .triggerEvent)
        c.eventId = id
        return c
    }

    static func setScenarioFlag(_ flagId: String) -> Consequence {
        var c = Consequence(kind: .setScenarioFlag)
        c.flagId = flagId
        return c
    }

    static func clearScenarioFlag(_ flagId: String) -> Consequence {
        var c = Consequence(kind: .clearScenarioFlag)
        c.flagId = flagId
        return c
    }

    static func addCharacterTag(_ tag: String) -> Consequence {
        var c = Consequence(kind: .addCharacterTag)
        c.tag = tag
        return c
    }

    static func removeCharacterTag(_ tag: String) -> Consequence {
        var c = Consequence(kind: .removeCharacterTag)
        c.tag = tag
        return c
    }

    static func incrementScenarioCounter(_ counterId: String, amount: Int = 1) -> Consequence {
        var c = Consequence(kind: .incrementScenarioCounter)
        c.counterId = counterId
        c.amount = amount
        return c
    }

    static func setScenarioCounter(_ counterId: String, value: Int) -> Consequence {
        var c = Consequence(kind: .setScenarioCounter)
        c.counterId = counterId
        c.amount = value
        return c
    }

    static func endRun(_ outcome: RunOutcome, text: String? = nil) -> Consequence {
        var c = Consequence(kind: .endRun)
        c.endingOutcome = outcome
        c.endingText = text
        return c
    }

    /// Trigger another set of consequences.
    static func triggerConsequences(_ consequences: [Consequence]) -> Consequence {
        var c = Consequence(kind: .triggerConsequences)
        c.triggered = consequences
        return c
    }

    /// Heal all existing harm by one level.
    static var healHarm: Consequence {
        Consequence(kind: .healHarm)
    }

}

enum HarmLevel: String, Codable {
    case lesser
    case moderate
    case severe
}

enum RollPosition: String, Codable {
    case controlled
    case risky
    case desperate

    /// Returns a one-step improved position, clamping at `.controlled`.
    func improved() -> RollPosition {
        switch self {
        case .desperate: return .risky
        case .risky: return .controlled
        case .controlled: return .controlled
        }
    }

    /// Returns a one-step worse position, clamping at `.desperate`.
    func decreased() -> RollPosition {
        switch self {
        case .controlled: return .risky
        case .risky: return .desperate
        case .desperate: return .desperate
        }
    }

    /// Numeric ordering used for comparisons (desperate > risky > controlled).
    var orderValue: Int {
        switch self {
        case .controlled: return 0
        case .risky: return 1
        case .desperate: return 2
        }
    }

    /// Returns `true` if `self` is worse (>=) than the provided position.
    func isWorseThanOrEqualTo(_ other: RollPosition) -> Bool {
        return self.orderValue >= other.orderValue
    }
}

enum RollEffect: String, Codable {
    case limited
    case standard
    case great

    /// Returns a reduced effect level, clamping at `.limited`.
    func decreased() -> RollEffect {
        switch self {
        case .great: return .standard
        case .standard: return .limited
        case .limited: return .limited
        }
    }

    /// Returns an increased effect level, clamping at `.great`.
    func increased() -> RollEffect {
        switch self {
        case .limited: return .standard
        case .standard: return .great
        case .great: return .great
        }
    }

    /// Numeric ordering used for comparisons (great > standard > limited).
    var orderValue: Int {
        switch self {
        case .limited: return 0
        case .standard: return 1
        case .great: return 2
        }
    }

    /// Returns `true` if `self` is better (>=) than the provided effect.
    func isBetterThanOrEqualTo(_ other: RollEffect) -> Bool {
        return self.orderValue >= other.orderValue
    }
}

/// Result information returned after performing a dice roll.
struct DiceRollResult {
    let highestRoll: Int
    let outcome: String
    let consequences: String
    let actualDiceRolled: [Int]?
    let isCritical: Bool?
    let finalEffect: RollEffect?
    let isAwaitingDecision: Bool
}


// Represents the entire dungeon layout
struct DungeonMap: Codable {
    // Store node IDs as strings so JSONEncoder produces a valid object
    var nodes: [String: MapNode] // Use a dictionary for quick node lookup by ID
    var startingNodeID: UUID
}

// Represents a single room or location on the map
struct MapNode: Identifiable, Codable {
    let id: UUID
    var name: String
    var soundProfile: String
    var interactables: [Interactable]
    var connections: [NodeConnection]
    var theme: String? = nil
    var isDiscovered: Bool = false // To support fog of war
}

// Represents a path from one node to another
struct NodeConnection: Codable {
    var toNodeID: UUID
    var isUnlocked: Bool = true // A path could be locked initially
    var description: String // e.g., "A dark tunnel", "A rickety bridge"
}

// MARK: - Persistence Helpers

extension GameState {
    /// Encode the game state and write it to the specified URL.
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }

    /// Load a `GameState` from the given file URL.
    static func load(from url: URL) throws -> GameState {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(GameState.self, from: data)
    }
}
