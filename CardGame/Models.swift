import Foundation

enum GameStatus: String, Codable {
    case playing
    case gameOver
}

struct GameState: Codable {
    /// Identifier for the scenario that generated this run. Used when loading
    /// to reinitialize the `ContentLoader` with the correct data bundle.
    var scenarioName: String = "tomb"

    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location (legacy)
    // Use String keys for JSON compatibility
    var characterLocations: [String: UUID] = [:] // Individual character locations
    var status: GameStatus = .playing
    // ... other global state can be added later
}

/// A general-purpose modifier that can adjust action rolls.
struct Modifier: Codable {
    var id: UUID = UUID()
    var bonusDice: Int = 0
    var improvePosition: Bool = false
    var improveEffect: Bool = false
    var applicableToAction: String? = nil
    var uses: Int = 1
    var isOptionalToApply: Bool = true
    var description: String

    enum CodingKeys: String, CodingKey {
        case id, bonusDice, improvePosition, improveEffect, applicableToAction, uses, isOptionalToApply, description
    }

    init(id: UUID = UUID(),
         bonusDice: Int = 0,
         improvePosition: Bool = false,
         improveEffect: Bool = false,
         applicableToAction: String? = nil,
         uses: Int = 1,
         isOptionalToApply: Bool = true,
         description: String) {
        self.id = id
        self.bonusDice = bonusDice
        self.improvePosition = improvePosition
        self.improveEffect = improveEffect
        self.applicableToAction = applicableToAction
        self.uses = uses
        self.isOptionalToApply = isOptionalToApply
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        bonusDice = try container.decodeIfPresent(Int.self, forKey: .bonusDice) ?? 0
        improvePosition = try container.decodeIfPresent(Bool.self, forKey: .improvePosition) ?? false
        improveEffect = try container.decodeIfPresent(Bool.self, forKey: .improveEffect) ?? false
        applicableToAction = try container.decodeIfPresent(String.self, forKey: .applicableToAction)
        uses = try container.decodeIfPresent(Int.self, forKey: .uses) ?? 1
        isOptionalToApply = try container.decodeIfPresent(Bool.self, forKey: .isOptionalToApply) ?? true
        description = try container.decode(String.self, forKey: .description)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bonusDice, forKey: .bonusDice)
        try container.encode(improvePosition, forKey: .improvePosition)
        try container.encode(improveEffect, forKey: .improveEffect)
        try container.encodeIfPresent(applicableToAction, forKey: .applicableToAction)
        try container.encode(uses, forKey: .uses)
        try container.encode(isOptionalToApply, forKey: .isOptionalToApply)
        try container.encode(description, forKey: .description)
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
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
    /// Whether this character can still act. Characters become defeated after
    /// suffering Fatal Harm.
    var isDefeated: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, name, characterClass, stress, harm, actions, treasures, modifiers, isDefeated
    }

    init(id: UUID,
         name: String,
         characterClass: String,
         stress: Int,
         harm: HarmState,
         actions: [String: Int],
         treasures: [Treasure] = [],
         modifiers: [Modifier] = [],
         isDefeated: Bool = false) {
        self.id = id
        self.name = name
        self.characterClass = characterClass
        self.stress = stress
        self.harm = harm
        self.actions = actions
        self.treasures = treasures
        self.modifiers = modifiers
        self.isDefeated = isDefeated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        characterClass = try container.decode(String.self, forKey: .characterClass)
        stress = try container.decode(Int.self, forKey: .stress)
        harm = try container.decode(HarmState.self, forKey: .harm)
        actions = try container.decode([String: Int].self, forKey: .actions)
        treasures = try container.decodeIfPresent([Treasure].self, forKey: .treasures) ?? []
        modifiers = try container.decodeIfPresent([Modifier].self, forKey: .modifiers) ?? []
        isDefeated = try container.decodeIfPresent(Bool.self, forKey: .isDefeated) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(characterClass, forKey: .characterClass)
        try container.encode(stress, forKey: .stress)
        try container.encode(harm, forKey: .harm)
        try container.encode(actions, forKey: .actions)
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
    case reduceEffect               // All actions are one effect level lower.
    case increaseStressCost(amount: Int) // Stress costs are increased.
    case actionPenalty(actionType: String) // Specific action suffers –1 die.
    case banAction(actionType: String) // An action is impossible without effort

    private enum CodingKeys: String, CodingKey {
        case type, amount, actionType
    }

    private enum Kind: String, Codable {
        case reduceEffect
        case increaseStressCost
        case actionPenalty
        case banAction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .reduceEffect:
            self = .reduceEffect
        case .increaseStressCost:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .increaseStressCost(amount: amount)
        case .actionPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionPenalty(actionType: action)
        case .banAction:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .banAction(actionType: action)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reduceEffect:
            try container.encode(Kind.reduceEffect, forKey: .type)
        case .increaseStressCost(let amount):
            try container.encode(Kind.increaseStressCost, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .actionPenalty(let action):
            try container.encode(Kind.actionPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
        case .banAction(let action):
            try container.encode(Kind.banAction, forKey: .type)
            try container.encode(action, forKey: .actionType)
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

/// Central catalog of all harm families available in the game.
/// This dictionary is populated from the JSON content loaded by `ContentLoader`.
struct HarmLibrary {
    /// Access the harm families for the currently loaded scenario.
    static var families: [String: HarmFamily] {
        return ContentLoader.shared.harmFamilyDict
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
    var isThreat: Bool = false
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions, isThreat, tags
    }

    init(id: String,
         title: String,
         description: String,
         availableActions: [ActionOption],
         isThreat: Bool = false,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
        self.isThreat = isThreat
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
        isThreat = try container.decodeIfPresent(Bool.self, forKey: .isThreat) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(availableActions, forKey: .availableActions)
        if isThreat {
            try container.encode(isThreat, forKey: .isThreat)
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
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, requiresTest, isGroupAction, requiredTag, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         isGroupAction: Bool = false,
         requiresTest: Bool = true,
         requiredTag: String? = nil,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.requiresTest = requiresTest
        self.isGroupAction = isGroupAction
        self.requiredTag = requiredTag
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
        case partyHasTreasureWithTag
        case clockProgress
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

/// Represents a selectable option in a `createChoice` consequence.
struct ChoiceOption: Codable {
    var title: String
    var consequences: [Consequence]
}

struct Consequence: Codable {
    enum ConsequenceKind: String, Codable {
        case gainStress
        case sufferHarm
        case tickClock
        case unlockConnection
        case removeInteractable
        case removeSelfInteractable
        case addInteractable
        case addInteractableHere
        case gainTreasure
        case modifyDice
        case createChoice
        case triggerEvent
        case triggerConsequences
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
    var inNodeID: UUID?
    var newInteractable: Interactable?
    var treasureId: String?
    var duration: String?
    var choiceOptions: [ChoiceOption]?
    var eventId: String?
    var triggered: [Consequence]?

    // Gating Conditions
    var conditions: [GameCondition]?

    private enum CodingKeys: String, CodingKey {
        case type, amount, level, familyId, clockName
        case fromNodeID, toNodeID, id, inNodeID
        case interactable, treasure, treasureId
        case duration, options, eventId, consequences
        case conditions
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
        inNodeID = nil
        newInteractable = nil
        treasureId = nil
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
        choiceOptions = try container.decodeIfPresent([ChoiceOption].self, forKey: .options)
        eventId = try container.decodeIfPresent(String.self, forKey: .eventId)
        triggered = try container.decodeIfPresent([Consequence].self, forKey: .consequences)

        if resolvedKind == .removeInteractable, interactableId == "self" {
            resolvedKind = .removeSelfInteractable
            interactableId = nil
        }

        if resolvedKind == .addInteractable {
            if let nodeString = try? container.decode(String.self, forKey: .inNodeID), nodeString == "current" {
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
                resolvedKind = .addInteractableHere
            } else {
                inNodeID = try container.decodeIfPresent(UUID.self, forKey: .inNodeID)
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
            }
        } else if resolvedKind == .addInteractableHere {
            newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
        }

        if resolvedKind == .gainTreasure {
            if let tid = try container.decodeIfPresent(String.self, forKey: .treasureId) {
                treasureId = tid
            } else if let treasure = try container.decodeIfPresent(Treasure.self, forKey: .treasure) {
                treasureId = treasure.id
            }
        }

        conditions = try container.decodeIfPresent([GameCondition].self, forKey: .conditions)
        kind = resolvedKind
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch kind {
        case .gainStress:
            try container.encode(ConsequenceKind.gainStress, forKey: .type)
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
        case .removeSelfInteractable:
            try container.encode(ConsequenceKind.removeInteractable, forKey: .type)
            try container.encode("self", forKey: .id)
        case .addInteractable:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encodeIfPresent(inNodeID, forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
        case .addInteractableHere:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encode("current", forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
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
        }

        try container.encodeIfPresent(conditions, forKey: .conditions)
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

    /// Add an interactable to the given node.
    static func addInteractable(_ interactable: Interactable, inNodeID: UUID) -> Consequence {
        var c = Consequence(kind: .addInteractable)
        c.newInteractable = interactable
        c.inNodeID = inNodeID
        return c
    }

    /// Add an interactable in the acting character's current location.
    static func addInteractableHere(_ interactable: Interactable) -> Consequence {
        var c = Consequence(kind: .addInteractableHere)
        c.newInteractable = interactable
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

    /// Trigger another set of consequences.
    static func triggerConsequences(_ consequences: [Consequence]) -> Consequence {
        var c = Consequence(kind: .triggerConsequences)
        c.triggered = consequences
        return c
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

