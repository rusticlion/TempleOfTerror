import Foundation

struct ScenarioValidationIssue: Hashable {
    enum Severity: String, Hashable {
        case warning
        case error
    }

    let severity: Severity
    let file: String
    let path: String?
    let message: String

    var formattedDescription: String {
        let location = path.map { "\(file) :: \($0)" } ?? file
        return "[\(severity.rawValue.uppercased())] \(location): \(message)"
    }
}

struct ScenarioValidationReport {
    let scenarioID: String
    let scenarioURL: URL
    fileprivate(set) var issues: [ScenarioValidationIssue] = []

    var errors: [ScenarioValidationIssue] {
        issues.filter { $0.severity == .error }
    }

    var warnings: [ScenarioValidationIssue] {
        issues.filter { $0.severity == .warning }
    }

    var formattedDescription: String {
        let lines = issues.map(\.formattedDescription)
        if lines.isEmpty {
            return "\(scenarioID): no issues"
        }
        return ([scenarioID] + lines).joined(separator: "\n")
    }

    mutating func add(
        severity: ScenarioValidationIssue.Severity,
        file: String,
        path: String? = nil,
        message: String
    ) {
        issues.append(
            ScenarioValidationIssue(
                severity: severity,
                file: file,
                path: path,
                message: message
            )
        )
    }
}

struct ScenarioValidator {
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private static let supportedActionTypes: Set<String> = [
        "Study", "Survey", "Hunt", "Tinker",
        "Prowl", "Finesse", "Wreck", "Skirmish",
        "Attune", "Command", "Consort", "Sway"
    ]

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }

    func validateAllScenarios(at rootURL: URL) -> [ScenarioValidationReport] {
        guard let contents = try? fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return contents
            .filter(\.hasDirectoryPath)
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map(validateScenario(at:))
    }

    func validateScenario(at scenarioURL: URL) -> ScenarioValidationReport {
        let folderName = scenarioURL.lastPathComponent
        let contentRootURL = scenarioURL.deletingLastPathComponent().deletingLastPathComponent()
        var state = ValidationState(
            report: ScenarioValidationReport(
                scenarioID: folderName,
                scenarioURL: scenarioURL
            )
        )

        guard let manifest: ScenarioManifest = loadRequiredCollectionlessFile(
            named: "scenario.json",
            at: scenarioURL,
            into: &state
        ) else {
            return state.report
        }

        state.report = ScenarioValidationReport(scenarioID: manifest.id, scenarioURL: scenarioURL)

        if manifest.id != folderName {
            state.report.add(
                severity: .warning,
                file: "scenario.json",
                message: "Manifest id '\(manifest.id)' does not match scenario folder '\(folderName)'."
            )
        }

        let interactablesFileExists = fileExists(named: "interactables.json", at: scenarioURL)
        let clocksFileExists = fileExists(named: "clocks.json", at: scenarioURL)
        let treasuresFileExists = fileExists(named: "treasures.json", at: scenarioURL)
        let globalHarmFamiliesFileExists = fileExists(named: "harm_families.json", at: contentRootURL)
        let scenarioHarmFamiliesFileExists = fileExists(named: "harm_families.json", at: scenarioURL)
        let eventsFileExists = fileExists(named: "events.json", at: scenarioURL)
        let archetypesFileExists = fileExists(named: "archetypes.json", at: scenarioURL)

        let interactables: [Interactable] = interactablesFileExists
            ? loadCollection(named: "interactables.json", at: scenarioURL, into: &state)
            : []
        let clocks: [GameClock] = clocksFileExists
            ? loadCollection(named: "clocks.json", at: scenarioURL, into: &state)
            : []
        let treasures: [Treasure] = treasuresFileExists
            ? loadCollection(named: "treasures.json", at: scenarioURL, into: &state)
            : []
        let globalHarmFamilies: [HarmFamily] = globalHarmFamiliesFileExists
            ? loadCollection(named: "harm_families.json", at: contentRootURL, into: &state)
            : []
        let scenarioHarmFamilies: [HarmFamily] = scenarioHarmFamiliesFileExists
            ? loadCollection(named: "harm_families.json", at: scenarioURL, into: &state)
            : []
        let harmFamilies = mergeByID(globalHarmFamilies, with: scenarioHarmFamilies)
        let events: [ScenarioEvent] = eventsFileExists
            ? loadCollection(named: "events.json", at: scenarioURL, into: &state)
            : []
        let archetypes: [ArchetypeDefinition] = archetypesFileExists
            ? loadCollection(named: "archetypes.json", at: scenarioURL, into: &state)
            : []

        let map: DungeonMap?
        if let mapFile = manifest.mapFile {
            map = loadRequiredCollectionlessFile(named: mapFile, at: scenarioURL, into: &state)
        } else {
            map = nil
        }

        if manifest.mapFile == nil && !interactablesFileExists {
            state.report.add(
                severity: .error,
                file: "scenario.json",
                message: "Scenario has no mapFile and no interactables.json. Procgen scenarios need interactable templates."
            )
        }

        if !globalHarmFamiliesFileExists {
            state.report.add(
                severity: .error,
                file: "harm_families.json",
                message: "Global harm family catalog is missing from Content/harm_families.json."
            )
        }

        if !archetypesFileExists {
            state.report.add(
                severity: .error,
                file: "archetypes.json",
                message: "Scenario-local archetype catalog is missing."
            )
        }

        validateUniqueStrings(
            interactables.map(\.id),
            label: "interactable id",
            file: "interactables.json",
            state: &state
        )
        validateUniqueStrings(
            globalHarmFamilies.map(\.id),
            label: "harm family id",
            file: "harm_families.json",
            state: &state
        )
        validateUniqueStrings(
            scenarioHarmFamilies.map(\.id),
            label: "harm family id",
            file: "harm_families.json",
            state: &state
        )
        validateUniqueStrings(
            treasures.map(\.id),
            label: "treasure id",
            file: "treasures.json",
            state: &state
        )
        validateUniqueStrings(
            clocks.map(\.name),
            label: "clock name",
            file: "clocks.json",
            state: &state
        )
        validateUniqueStrings(
            events.map(\.id),
            label: "event id",
            file: "events.json",
            state: &state
        )
        validateUniqueStrings(
            archetypes.map(\.id),
            label: "archetype id",
            file: "archetypes.json",
            state: &state
        )

        let catalog = ValidationCatalog(
            hasFixedMap: map != nil,
            nodeIDs: Set(map?.nodes.values.map(\.id) ?? []),
            interactableTemplateIDs: Set(interactables.map(\.id)),
            interactableTemplatesByID: Dictionary(uniqueKeysWithValues: interactables.map { ($0.id, $0) }),
            clockNames: Set(clocks.map(\.name)),
            treasureIDs: Set(treasures.map(\.id)),
            eventIDs: Set(events.map(\.id)),
            harmFamilyIDs: Set(harmFamilies.map(\.id)),
            archetypeIDs: Set(archetypes.map(\.id)),
            supportedActionTypes: Self.supportedActionTypes
        )

        let resolvedEntryNodeID: UUID?
        if let entryNode = manifest.entryNode {
            if let map {
                if let resolved = resolveEntryNodeID(entryNode, in: map) {
                    resolvedEntryNodeID = resolved
                } else {
                    state.report.add(
                        severity: .error,
                        file: manifest.mapFile ?? "map.json",
                        path: "entryNode",
                        message: "Scenario entryNode '\(entryNode)' does not match any fixed-map node id or unique node name."
                    )
                    resolvedEntryNodeID = map.startingNodeID
                }
            } else {
                resolvedEntryNodeID = nil
                state.report.add(
                    severity: .warning,
                    file: "scenario.json",
                    path: "entryNode",
                    message: "entryNode is only consumed by fixed-map scenarios."
                )
            }
        } else if let map {
            resolvedEntryNodeID = map.startingNodeID
        } else {
            resolvedEntryNodeID = nil
        }

        let stressOverflowHarmFamilyID = manifest.stressOverflowHarmFamilyID ?? "mental_fraying"
        if manifest.stressOverflowHarmFamilyID == nil {
            state.report.add(
                severity: .warning,
                file: "scenario.json",
                path: "stressOverflowHarmFamilyID",
                message: "Stress overflow harm family is not configured; runtime will default to '\(stressOverflowHarmFamilyID)'."
            )
        }
        if !catalog.harmFamilyIDs.contains(stressOverflowHarmFamilyID) {
            state.report.add(
                severity: .error,
                file: "scenario.json",
                path: "stressOverflowHarmFamilyID",
                message: "Stress overflow harm family '\(stressOverflowHarmFamilyID)' is not defined in this scenario's harm catalog."
            )
        }

        if let partySize = manifest.partySize, partySize <= 0 {
            state.report.add(
                severity: .error,
                file: "scenario.json",
                path: "partySize",
                message: "partySize must be greater than zero."
            )
        }
        if let nativeArchetypeIDs = manifest.nativeArchetypeIDs {
            validateUniqueStrings(
                nativeArchetypeIDs,
                label: "native archetype id",
                file: "scenario.json",
                state: &state
            )
            for archetypeID in nativeArchetypeIDs where !catalog.archetypeIDs.contains(archetypeID) {
                state.report.add(
                    severity: .error,
                    file: "scenario.json",
                    path: "nativeArchetypeIDs",
                    message: "Scenario references unknown native archetype '\(archetypeID)'."
                )
            }
            if let partySize = manifest.partySize,
               nativeArchetypeIDs.count < partySize {
                state.report.add(
                    severity: .warning,
                    file: "scenario.json",
                    path: "nativeArchetypeIDs",
                    message: "Scenario declares fewer native archetypes (\(nativeArchetypeIDs.count)) than partySize (\(partySize))."
                )
            }
        }

        if let map {
            validateMap(
                map,
                mapFile: manifest.mapFile ?? "map.json",
                entryNodeID: resolvedEntryNodeID ?? map.startingNodeID,
                catalog: catalog,
                state: &state
            )
        }

        for interactable in interactables {
            validateInteractable(
                interactable,
                file: "interactables.json",
                path: "interactable[\(interactable.id)]",
                catalog: catalog,
                state: &state
            )
        }

        for archetype in archetypes {
            validateArchetype(
                archetype,
                state: &state
            )
        }

        for treasure in treasures {
            validateTreasure(
                treasure,
                catalog: catalog,
                state: &state
            )
        }

        for harmFamily in harmFamilies {
            validateHarmFamily(
                harmFamily,
                catalog: catalog,
                state: &state
            )
        }

        for clock in clocks {
            validateClock(clock, catalog: catalog, state: &state)
        }

        for event in events {
            validateEvent(event, catalog: catalog, state: &state)
        }

        let unreadableFlags = state.readFlagIDs.subtracting(state.writtenFlagIDs)
        for flagID in unreadableFlags.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "scenarioFlagSet[\(flagID)]",
                message: "Flag is read by content but never set or cleared anywhere in this scenario."
            )
        }

        let unreadableCounters = state.readCounterIDs.subtracting(state.writtenCounterIDs)
        for counterID in unreadableCounters.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "scenarioCounter[\(counterID)]",
                message: "Counter is read by content but never written anywhere in this scenario."
            )
        }

        let writeOnlyFlags = state.writtenFlagIDs.subtracting(state.readFlagIDs)
        for flagID in writeOnlyFlags.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "scenarioFlagSet[\(flagID)]",
                message: "Flag is written by content but never read by any authored conditions."
            )
        }

        let writeOnlyCounters = state.writtenCounterIDs.subtracting(state.readCounterIDs)
        for counterID in writeOnlyCounters.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "scenarioCounter[\(counterID)]",
                message: "Counter is written by content but never read by any authored conditions."
            )
        }

        let sinkClocks = state.writtenClockNames
            .subtracting(state.readClockNames)
            .subtracting(state.intrinsicallyReferencedClockNames)
        for clockName in sinkClocks.sorted() {
            state.report.add(
                severity: .warning,
                file: "clocks.json",
                path: "clock[\(clockName)]",
                message: "Clock is ticked by content but has no intrinsic behavior and is never read by authored conditions."
            )
        }

        let unreferencedEvents = catalog.eventIDs.subtracting(state.referencedEventIDs)
        for eventID in unreferencedEvents.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "event[\(eventID)]",
                message: "Event is defined but never triggered by any content."
            )
        }

        let unreferencedTreasures = catalog.treasureIDs.subtracting(state.referencedTreasureIDs)
        for treasureID in unreferencedTreasures.sorted() {
            state.report.add(
                severity: .warning,
                file: "treasures.json",
                path: "treasure[\(treasureID)]",
                message: "Treasure is defined but never referenced by gainTreasure or characterHasTreasureId."
            )
        }

        let unreferencedClocks = catalog.clockNames
            .subtracting(state.referencedClockNames)
            .subtracting(state.intrinsicallyReferencedClockNames)
        for clockName in unreferencedClocks.sorted() {
            state.report.add(
                severity: .warning,
                file: "clocks.json",
                path: "clock[\(clockName)]",
                message: "Clock is defined but never referenced by tickClock/clockProgress and has no intrinsic behavior."
            )
        }

        return state.report
    }

    private func validateMap(
        _ map: DungeonMap,
        mapFile: String,
        entryNodeID: UUID,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        if !catalog.nodeIDs.contains(map.startingNodeID) {
            state.report.add(
                severity: .error,
                file: mapFile,
                path: "startingNodeID",
                message: "startingNodeID does not exist in the map node table."
            )
        }

        if !catalog.nodeIDs.contains(entryNodeID) {
            state.report.add(
                severity: .error,
                file: mapFile,
                path: "entryNode",
                message: "Resolved entry node \(entryNodeID.uuidString) does not exist in the map node table."
            )
            return
        }

        let reachableNodeIDs = computeReachableNodeIDs(from: entryNodeID, in: map)

        for (key, node) in map.nodes {
            if key != node.id.uuidString {
                state.report.add(
                    severity: .error,
                    file: mapFile,
                    path: "node[\(key)]",
                    message: "Dictionary key does not match node.id (\(node.id.uuidString))."
                )
            }

            for (index, connection) in node.connections.enumerated() {
                if !catalog.nodeIDs.contains(connection.toNodeID) {
                    state.report.add(
                        severity: .error,
                        file: mapFile,
                        path: "node[\(node.id.uuidString)].connections[\(index)]",
                        message: "Connection points to missing node \(connection.toNodeID.uuidString)."
                    )
                }
            }

            if !reachableNodeIDs.contains(node.id) {
                state.report.add(
                    severity: .warning,
                    file: mapFile,
                    path: "node[\(node.id.uuidString)]",
                    message: "Node is unreachable from the scenario entry node."
                )
            } else if isLikelySoftLockNode(node, catalog: catalog) {
                state.report.add(
                    severity: .warning,
                    file: mapFile,
                    path: "node[\(node.id.uuidString)]",
                    message: "Node has no unlocked exits and no obvious consequence path to unlock/finish the run (possible soft-lock)."
                )
            }

            for interactable in node.interactables {
                validateInteractable(
                    interactable,
                    file: mapFile,
                    path: "node[\(node.name)] > interactable[\(interactable.id)]",
                    catalog: catalog,
                    state: &state
                )
            }
        }
    }

    private func validateClock(
        _ clock: GameClock,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        if clock.progress > 0 || clock.onTickConsequences != nil || clock.onCompleteConsequences != nil {
            state.intrinsicallyReferencedClockNames.insert(clock.name)
        }

        if clock.segments <= 0 {
            state.report.add(
                severity: .error,
                file: "clocks.json",
                path: "clock[\(clock.name)]",
                message: "Clock must have at least one segment."
            )
        }

        if clock.progress < 0 || clock.progress > clock.segments {
            state.report.add(
                severity: .error,
                file: "clocks.json",
                path: "clock[\(clock.name)]",
                message: "Clock progress \(clock.progress) is outside 0...\(clock.segments)."
            )
        }

        if let onTick = clock.onTickConsequences {
            validateConsequences(
                onTick,
                file: "clocks.json",
                path: "clock[\(clock.name)].onTickConsequences",
                catalog: catalog,
                state: &state
            )
        }

        if let onComplete = clock.onCompleteConsequences {
            validateConsequences(
                onComplete,
                file: "clocks.json",
                path: "clock[\(clock.name)].onCompleteConsequences",
                catalog: catalog,
                state: &state
            )
        }
    }

    private func validateEvent(
        _ event: ScenarioEvent,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        validateConditions(
            event.conditions,
            file: "events.json",
            path: "event[\(event.id)].conditions",
            catalog: catalog,
            state: &state
        )
        validateConsequences(
            event.consequences,
            file: "events.json",
            path: "event[\(event.id)].consequences",
            catalog: catalog,
            state: &state
        )
    }

    private func validateInteractable(
        _ interactable: Interactable,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        validateConditions(
            interactable.conditions,
            file: file,
            path: "\(path).conditions",
            catalog: catalog,
            state: &state
        )

        if interactable.availableActions.isEmpty && !interactable.isDisplayOnly {
            state.report.add(
                severity: .warning,
                file: file,
                path: path,
                message: "Interactable has no available actions."
            )
        }

        for action in interactable.availableActions {
            validateAction(
                action,
                file: file,
                path: "\(path) > action[\(action.name)]",
                catalog: catalog,
                state: &state
            )
        }
    }

    private func resolveEntryNodeID(_ entryNode: String, in map: DungeonMap) -> UUID? {
        if let uuid = UUID(uuidString: entryNode),
           map.nodes[uuid.uuidString] != nil {
            return uuid
        }

        let matches = map.nodes.values.filter {
            $0.name.compare(entryNode, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard matches.count == 1 else { return nil }
        return matches[0].id
    }

    private func computeReachableNodeIDs(from startNodeID: UUID, in map: DungeonMap) -> Set<UUID> {
        guard map.nodes[startNodeID.uuidString] != nil else { return [] }

        var visited: Set<UUID> = [startNodeID]
        var queue: [UUID] = [startNodeID]
        var head = 0

        while head < queue.count {
            let currentNodeID = queue[head]
            head += 1

            guard let node = map.nodes[currentNodeID.uuidString] else { continue }
            for connection in node.connections {
                guard map.nodes[connection.toNodeID.uuidString] != nil else { continue }
                if visited.insert(connection.toNodeID).inserted {
                    queue.append(connection.toNodeID)
                }
            }
        }

        return visited
    }

    private func isLikelySoftLockNode(_ node: MapNode, catalog: ValidationCatalog) -> Bool {
        if node.connections.contains(where: { $0.isUnlocked }) {
            return false
        }

        for interactable in node.interactables {
            for action in interactable.availableActions {
                if actionHasProgressionPath(action, catalog: catalog) {
                    return false
                }
            }
        }

        return true
    }

    private func actionHasProgressionPath(_ action: ActionOption, catalog: ValidationCatalog) -> Bool {
        action.outcomes.values.contains { consequencesContainProgressionPath($0, catalog: catalog) }
    }

    private func consequencesContainProgressionPath(
        _ consequences: [Consequence],
        catalog: ValidationCatalog
    ) -> Bool {
        for consequence in consequences {
            switch consequence.kind {
            case .unlockConnection, .triggerEvent, .endRun:
                return true

            case .createChoice:
                if let options = consequence.choiceOptions,
                   options.contains(where: { consequencesContainProgressionPath($0.consequences, catalog: catalog) }) {
                    return true
                }

            case .triggerConsequences:
                if let nested = consequence.triggered,
                   consequencesContainProgressionPath(nested, catalog: catalog) {
                    return true
                }

            case .addAction:
                if let action = consequence.newAction,
                   actionHasProgressionPath(action, catalog: catalog) {
                    return true
                }

            case .addInteractable, .addInteractableHere:
                if let interactable = consequence.newInteractable ??
                    consequence.interactableTemplateID.flatMap({ catalog.interactableTemplatesByID[$0] }),
                   interactable.availableActions.contains(where: { actionHasProgressionPath($0, catalog: catalog) }) {
                    return true
                }

            default:
                continue
            }
        }

        return false
    }

    private func validateAction(
        _ action: ActionOption,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        validateConditions(
            action.conditions,
            file: file,
            path: "\(path).conditions",
            catalog: catalog,
            state: &state
        )

        if !catalog.supportedActionTypes.contains(action.actionType) {
            let supported = catalog.supportedActionTypes.sorted().joined(separator: ", ")
            state.report.add(
                severity: .error,
                file: file,
                path: path,
                message: "Unsupported actionType '\(action.actionType)'. Supported values: \(supported)."
            )
        }

        let orderedOutcomes: [RollOutcome] = [.success, .partial, .failure]
        for outcome in orderedOutcomes {
            guard let consequences = action.outcomes[outcome] else { continue }
            validateConsequences(
                consequences,
                file: file,
                path: "\(path).\(outcome.rawValue)",
                catalog: catalog,
                state: &state
            )
        }
    }

    private func validateTreasure(
        _ treasure: Treasure,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        validateModifier(
            treasure.grantedModifier,
            file: "treasures.json",
            path: "treasure[\(treasure.id)].grantedModifier",
            catalog: catalog,
            state: &state
        )
    }

    private func validateArchetype(
        _ archetype: ArchetypeDefinition,
        state: inout ValidationState
    ) {
        let tags = archetype.personalityTagPool.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if tags.contains(where: \.isEmpty) {
            state.report.add(
                severity: .error,
                file: "archetypes.json",
                path: "archetype[\(archetype.id)].personalityTagPool",
                message: "personalityTagPool cannot contain blank tags."
            )
        }

        var seen: Set<String> = []
        for tag in tags where !tag.isEmpty {
            if !seen.insert(tag).inserted {
                state.report.add(
                    severity: .warning,
                    file: "archetypes.json",
                    path: "archetype[\(archetype.id)].personalityTagPool",
                    message: "Duplicate personality tag '\(tag)' will be ignored at runtime."
                )
            }
        }
    }

    private func validateHarmFamily(
        _ family: HarmFamily,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        validateHarmTier(family.lesser, tierName: "lesser", familyID: family.id, catalog: catalog, state: &state)
        validateHarmTier(family.moderate, tierName: "moderate", familyID: family.id, catalog: catalog, state: &state)
        validateHarmTier(family.severe, tierName: "severe", familyID: family.id, catalog: catalog, state: &state)
        validateHarmTier(family.fatal, tierName: "fatal", familyID: family.id, catalog: catalog, state: &state)
    }

    private func validateHarmTier(
        _ tier: HarmTier,
        tierName: String,
        familyID: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        let basePath = "harmFamily[\(familyID)].\(tierName)"
        if let penalty = tier.penalty {
            validatePenalty(
                penalty,
                file: "harm_families.json",
                path: "\(basePath).penalty",
                catalog: catalog,
                state: &state
            )
        }
        if let boon = tier.boon {
            validateModifier(
                boon,
                file: "harm_families.json",
                path: "\(basePath).boon",
                catalog: catalog,
                state: &state
            )
        }
    }

    private func validatePenalty(
        _ penalty: Penalty,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        let actionName: String?
        switch penalty {
        case .actionPenalty(let actionType, _),
             .banAction(let actionType, _),
             .actionPositionPenalty(let actionType, _),
             .actionEffectPenalty(let actionType, _):
            actionName = actionType
        default:
            actionName = nil
        }

        if let actionName,
           !catalog.supportedActionTypes.contains(actionName) {
            let supported = catalog.supportedActionTypes.sorted().joined(separator: ", ")
            state.report.add(
                severity: .error,
                file: file,
                path: path,
                message: "Unsupported actionType '\(actionName)' in penalty scope. Supported values: \(supported)."
            )
        }
    }

    private func validateModifier(
        _ modifier: Modifier,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        if modifier.usedLegacyActionTypeAlias {
            state.report.add(
                severity: .warning,
                file: file,
                path: path,
                message: "Modifier uses legacy 'actionType'; prefer 'applicableToAction' or 'applicableActions'."
            )
        }

        let scopedActions = modifier.applicableActions ?? modifier.applicableToAction.map { [$0] } ?? []
        for actionName in scopedActions where !catalog.supportedActionTypes.contains(actionName) {
            let supported = catalog.supportedActionTypes.sorted().joined(separator: ", ")
            state.report.add(
                severity: .error,
                file: file,
                path: path,
                message: "Unsupported action scope '\(actionName)' in modifier. Supported values: \(supported)."
            )
        }
    }

    private func validateConsequences(
        _ consequences: [Consequence],
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        for (index, consequence) in consequences.enumerated() {
            let consequencePath = "\(path)[\(index)]"
            validateConditions(
                consequence.conditions,
                file: file,
                path: "\(consequencePath).conditions",
                catalog: catalog,
                state: &state
            )

            switch consequence.kind {
            case .gainStress:
                require(
                    consequence.amount != nil,
                    file: file,
                    path: consequencePath,
                    message: "gainStress requires amount.",
                    state: &state
                )
                if let amount = consequence.amount, amount < 0 {
                    state.report.add(
                        severity: .warning,
                        file: file,
                        path: consequencePath,
                        message: "Negative gainStress is legacy content; use adjustStress for stress recovery."
                    )
                }

            case .adjustStress:
                require(
                    consequence.amount != nil,
                    file: file,
                    path: consequencePath,
                    message: "adjustStress requires amount.",
                    state: &state
                )

            case .sufferHarm:
                require(
                    consequence.level != nil,
                    file: file,
                    path: consequencePath,
                    message: "sufferHarm requires level.",
                    state: &state
                )
                if let familyID = consequence.familyId {
                    if !catalog.harmFamilyIDs.contains(familyID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "Unknown harm family '\(familyID)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "sufferHarm requires familyId."
                    )
                }

            case .tickClock:
                require(
                    consequence.amount != nil,
                    file: file,
                    path: consequencePath,
                    message: "tickClock requires amount.",
                    state: &state
                )
                if let clockName = consequence.clockName {
                    state.referencedClockNames.insert(clockName)
                    state.writtenClockNames.insert(clockName)
                    if !catalog.clockNames.contains(clockName) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "Unknown clock '\(clockName)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "tickClock requires clockName."
                    )
                }

            case .unlockConnection:
                if catalog.hasFixedMap {
                    require(
                        consequence.fromNodeID != nil,
                        file: file,
                        path: consequencePath,
                        message: "unlockConnection requires fromNodeID.",
                        state: &state
                    )
                    require(
                        consequence.toNodeID != nil,
                        file: file,
                        path: consequencePath,
                        message: "unlockConnection requires toNodeID.",
                        state: &state
                    )

                    if let fromNodeID = consequence.fromNodeID,
                       !catalog.nodeIDs.contains(fromNodeID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "unlockConnection references missing fromNodeID \(fromNodeID.uuidString)."
                        )
                    }
                    if let toNodeID = consequence.toNodeID,
                       !catalog.nodeIDs.contains(toNodeID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "unlockConnection references missing toNodeID \(toNodeID.uuidString)."
                        )
                    }
                }

            case .removeInteractable:
                require(
                    consequence.interactableId != nil,
                    file: file,
                    path: consequencePath,
                    message: "removeInteractable requires id.",
                    state: &state
                )

            case .removeSelfInteractable:
                break

            case .removeAction:
                require(
                    consequence.actionName != nil,
                    file: file,
                    path: consequencePath,
                    message: "removeAction requires actionName.",
                    state: &state
                )

            case .addAction:
                if let action = consequence.newAction {
                    validateAction(
                        action,
                        file: file,
                        path: "\(consequencePath).action[\(action.name)]",
                        catalog: catalog,
                        state: &state
                    )
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "addAction requires an action payload."
                    )
                }

            case .addInteractable:
                if let nodeID = consequence.inNodeID {
                    if catalog.hasFixedMap && !catalog.nodeIDs.contains(nodeID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "addInteractable references missing node \(nodeID.uuidString)."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "addInteractable requires inNodeID."
                    )
                }

                validateSpawnInteractable(
                    consequence,
                    kindLabel: "addInteractable",
                    file: file,
                    path: consequencePath,
                    catalog: catalog,
                    state: &state
                )

            case .addInteractableHere:
                validateSpawnInteractable(
                    consequence,
                    kindLabel: "addInteractableHere",
                    file: file,
                    path: consequencePath,
                    catalog: catalog,
                    state: &state
                )

            case .gainTreasure:
                if let treasureID = consequence.treasureId {
                    state.referencedTreasureIDs.insert(treasureID)
                    if !catalog.treasureIDs.contains(treasureID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "Unknown treasure '\(treasureID)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "gainTreasure requires treasureId."
                    )
                }

            case .modifyDice:
                require(
                    consequence.amount != nil,
                    file: file,
                    path: consequencePath,
                    message: "modifyDice requires amount.",
                    state: &state
                )

            case .createChoice:
                if let options = consequence.choiceOptions, !options.isEmpty {
                    for (optionIndex, option) in options.enumerated() {
                        validateConsequences(
                            option.consequences,
                            file: file,
                            path: "\(consequencePath).options[\(optionIndex):\(option.title)]",
                            catalog: catalog,
                            state: &state
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "createChoice requires one or more options."
                    )
                }

            case .triggerEvent:
                if let eventID = consequence.eventId {
                    state.referencedEventIDs.insert(eventID)
                    if !catalog.eventIDs.contains(eventID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: consequencePath,
                            message: "Unknown event '\(eventID)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "triggerEvent requires eventId."
                    )
                }

            case .triggerConsequences:
                if let triggered = consequence.triggered, !triggered.isEmpty {
                    validateConsequences(
                        triggered,
                        file: file,
                        path: "\(consequencePath).consequences",
                        catalog: catalog,
                        state: &state
                    )
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "triggerConsequences requires one or more nested consequences."
                    )
                }

            case .healHarm:
                break

            case .setScenarioFlag:
                if let flagID = consequence.flagId, !flagID.isEmpty {
                    state.writtenFlagIDs.insert(flagID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "setScenarioFlag requires flagId."
                    )
                }

            case .clearScenarioFlag:
                if let flagID = consequence.flagId, !flagID.isEmpty {
                    state.writtenFlagIDs.insert(flagID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "clearScenarioFlag requires flagId."
                    )
                }

            case .incrementScenarioCounter:
                if let counterID = consequence.counterId, !counterID.isEmpty {
                    state.writtenCounterIDs.insert(counterID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "incrementScenarioCounter requires counterId."
                    )
                }

            case .setScenarioCounter:
                if let counterID = consequence.counterId, !counterID.isEmpty {
                    state.writtenCounterIDs.insert(counterID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "setScenarioCounter requires counterId."
                    )
                }

            case .addCharacterTag, .removeCharacterTag:
                if let tag = consequence.tag, !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    break
                }
                state.report.add(
                    severity: .error,
                    file: file,
                    path: consequencePath,
                    message: "\(consequence.kind.rawValue) requires tag."
                )

            case .endRun:
                if consequence.endingOutcome == nil {
                    state.report.add(
                        severity: .warning,
                        file: file,
                        path: consequencePath,
                        message: "endRun has no runOutcome. The run will end without a classified outcome."
                    )
                }
            }
            
            if let resistance = consequence.resistance,
               let amount = resistance.amount,
               amount < 0 {
                state.report.add(
                    severity: .error,
                    file: file,
                    path: "\(consequencePath).resistance.amount",
                    message: "resistance.amount must be zero or greater."
                )
            }
        }
    }

    private func validateSpawnInteractable(
        _ consequence: Consequence,
        kindLabel: String,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        let hasInlineInteractable = consequence.newInteractable != nil
        let hasTemplateID = consequence.interactableTemplateID != nil

        if hasInlineInteractable == hasTemplateID {
            state.report.add(
                severity: .error,
                file: file,
                path: path,
                message: "\(kindLabel) requires exactly one spawn form: either interactable or interactableTemplateID."
            )
            return
        }

        if let interactable = consequence.newInteractable {
            validateInteractable(
                interactable,
                file: file,
                path: "\(path).interactable[\(interactable.id)]",
                catalog: catalog,
                state: &state
            )
            return
        }

        if let templateID = consequence.interactableTemplateID,
           !catalog.interactableTemplateIDs.contains(templateID) {
            state.report.add(
                severity: .error,
                file: file,
                path: path,
                message: "\(kindLabel) references unknown interactable template '\(templateID)'."
            )
        }
    }

    private func validateConditions(
        _ conditions: [GameCondition]?,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
        guard let conditions else { return }

        for (index, condition) in conditions.enumerated() {
            let conditionPath = "\(path)[\(index)]"
            switch condition.type {
            case .requiresMinEffectLevel, .requiresExactEffectLevel:
                require(
                    condition.effectParam != nil,
                    file: file,
                    path: conditionPath,
                    message: "\(condition.type.rawValue) requires effectParam.",
                    state: &state
                )

            case .requiresMinPositionLevel, .requiresExactPositionLevel:
                require(
                    condition.positionParam != nil,
                    file: file,
                    path: conditionPath,
                    message: "\(condition.type.rawValue) requires positionParam.",
                    state: &state
                )

            case .characterHasTreasureId:
                if let treasureID = condition.stringParam {
                    state.referencedTreasureIDs.insert(treasureID)
                    if !catalog.treasureIDs.contains(treasureID) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: conditionPath,
                            message: "Condition references unknown treasure '\(treasureID)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: conditionPath,
                        message: "characterHasTreasureId requires stringParam."
                    )
                }

            case .characterHasTag, .characterLacksTag, .partyHasMemberWithTag:
                require(
                    !(condition.stringParam?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true),
                    file: file,
                    path: conditionPath,
                    message: "\(condition.type.rawValue) requires stringParam tag.",
                    state: &state
                )

            case .partyHasTreasureWithTag:
                require(
                    condition.stringParam != nil,
                    file: file,
                    path: conditionPath,
                    message: "partyHasTreasureWithTag requires stringParam.",
                    state: &state
                )

            case .clockProgress:
                require(
                    condition.intParam != nil,
                    file: file,
                    path: conditionPath,
                    message: "clockProgress requires intParam minimum progress.",
                    state: &state
                )

                if let clockName = condition.stringParam {
                    state.referencedClockNames.insert(clockName)
                    state.readClockNames.insert(clockName)
                    if !catalog.clockNames.contains(clockName) {
                        state.report.add(
                            severity: .error,
                            file: file,
                            path: conditionPath,
                            message: "Condition references unknown clock '\(clockName)'."
                        )
                    }
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: conditionPath,
                        message: "clockProgress requires stringParam clock name."
                    )
                }

            case .scenarioFlagSet:
                if let flagID = condition.stringParam, !flagID.isEmpty {
                    state.readFlagIDs.insert(flagID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: conditionPath,
                        message: "scenarioFlagSet requires stringParam flag id."
                    )
                }

            case .scenarioCounter:
                if let counterID = condition.stringParam, !counterID.isEmpty {
                    state.readCounterIDs.insert(counterID)
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: conditionPath,
                        message: "scenarioCounter requires stringParam counter id."
                    )
                }
            }
        }
    }

    private func require(
        _ condition: Bool,
        file: String,
        path: String,
        message: String,
        state: inout ValidationState
    ) {
        guard !condition else { return }
        state.report.add(severity: .error, file: file, path: path, message: message)
    }

    private func validateUniqueStrings(
        _ values: [String],
        label: String,
        file: String,
        state: inout ValidationState
    ) {
        var seen: Set<String> = []
        for value in values {
            if !seen.insert(value).inserted {
                state.report.add(
                    severity: .error,
                    file: file,
                    message: "Duplicate \(label) '\(value)'."
                )
            }
        }
    }

    private func fileExists(named filename: String, at scenarioURL: URL) -> Bool {
        fileManager.fileExists(atPath: scenarioURL.appendingPathComponent(filename).path)
    }

    private func loadRequiredCollectionlessFile<T: Decodable>(
        named filename: String,
        at scenarioURL: URL,
        into state: inout ValidationState
    ) -> T? {
        let url = scenarioURL.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: url.path) else {
            state.report.add(
                severity: .error,
                file: filename,
                message: "Required file is missing."
            )
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            state.report.add(
                severity: .error,
                file: filename,
                message: "Failed to decode file: \(error)"
            )
            return nil
        }
    }

    private func loadCollection<T: Decodable>(
        named filename: String,
        at scenarioURL: URL,
        into state: inout ValidationState
    ) -> [T] {
        let url = scenarioURL.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: url)
            if let array = try? decoder.decode([T].self, from: data) {
                return array
            }
            if let dict = try? decoder.decode([String: [T]].self, from: data) {
                return dict.flatMap(\.value)
            }

            state.report.add(
                severity: .error,
                file: filename,
                message: "Unexpected collection format. Expected an array or dictionary of arrays."
            )
            return []
        } catch {
            state.report.add(
                severity: .error,
                file: filename,
                message: "Failed to decode file: \(error)"
            )
            return []
        }
    }

    private func mergeByID<T: Identifiable>(_ base: [T], with overrides: [T]) -> [T] where T.ID == String {
        var merged: [String: T] = [:]
        var order: [String] = []

        for value in base + overrides {
            if merged[value.id] == nil {
                order.append(value.id)
            }
            merged[value.id] = value
        }

        return order.compactMap { merged[$0] }
    }

    private struct ValidationCatalog {
        let hasFixedMap: Bool
        let nodeIDs: Set<UUID>
        let interactableTemplateIDs: Set<String>
        let interactableTemplatesByID: [String: Interactable]
        let clockNames: Set<String>
        let treasureIDs: Set<String>
        let eventIDs: Set<String>
        let harmFamilyIDs: Set<String>
        let archetypeIDs: Set<String>
        let supportedActionTypes: Set<String>
    }

    private struct ValidationState {
        var report: ScenarioValidationReport
        var referencedEventIDs: Set<String> = []
        var referencedTreasureIDs: Set<String> = []
        var referencedClockNames: Set<String> = []
        var writtenClockNames: Set<String> = []
        var readClockNames: Set<String> = []
        var intrinsicallyReferencedClockNames: Set<String> = []
        var writtenFlagIDs: Set<String> = []
        var readFlagIDs: Set<String> = []
        var writtenCounterIDs: Set<String> = []
        var readCounterIDs: Set<String> = []
    }
}
