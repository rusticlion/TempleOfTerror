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
            clockNames: Set(clocks.map(\.name)),
            treasureIDs: Set(treasures.map(\.id)),
            eventIDs: Set(events.map(\.id)),
            harmFamilyIDs: Set(harmFamilies.map(\.id)),
            archetypeIDs: Set(archetypes.map(\.id))
        )

        if let entryNode = manifest.entryNode {
            if let map {
                if resolveEntryNodeID(entryNode, in: map) == nil {
                    state.report.add(
                        severity: .error,
                        file: manifest.mapFile ?? "map.json",
                        path: "entryNode",
                        message: "Scenario entryNode '\(entryNode)' does not match any fixed-map node id or unique node name."
                    )
                }
            } else {
                state.report.add(
                    severity: .warning,
                    file: "scenario.json",
                    path: "entryNode",
                    message: "entryNode is only consumed by fixed-map scenarios."
                )
            }
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
            validateMap(map, mapFile: manifest.mapFile ?? "map.json", catalog: catalog, state: &state)
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

        let unreferencedEvents = catalog.eventIDs.subtracting(state.referencedEventIDs)
        for eventID in unreferencedEvents.sorted() {
            state.report.add(
                severity: .warning,
                file: "events.json",
                path: "event[\(eventID)]",
                message: "Event is defined but never triggered by any content."
            )
        }

        return state.report
    }

    private func validateMap(
        _ map: DungeonMap,
        mapFile: String,
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

    private func validateAction(
        _ action: ActionOption,
        file: String,
        path: String,
        catalog: ValidationCatalog,
        state: inout ValidationState
    ) {
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

                if let interactable = consequence.newInteractable {
                    validateInteractable(
                        interactable,
                        file: file,
                        path: "\(consequencePath).interactable[\(interactable.id)]",
                        catalog: catalog,
                        state: &state
                    )
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "addInteractable requires an interactable payload."
                    )
                }

            case .addInteractableHere:
                if let interactable = consequence.newInteractable {
                    validateInteractable(
                        interactable,
                        file: file,
                        path: "\(consequencePath).interactable[\(interactable.id)]",
                        catalog: catalog,
                        state: &state
                    )
                } else {
                    state.report.add(
                        severity: .error,
                        file: file,
                        path: consequencePath,
                        message: "addInteractableHere requires an interactable payload."
                    )
                }

            case .gainTreasure:
                if let treasureID = consequence.treasureId {
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
        let clockNames: Set<String>
        let treasureIDs: Set<String>
        let eventIDs: Set<String>
        let harmFamilyIDs: Set<String>
        let archetypeIDs: Set<String>
    }

    private struct ValidationState {
        var report: ScenarioValidationReport
        var referencedEventIDs: Set<String> = []
        var writtenFlagIDs: Set<String> = []
        var readFlagIDs: Set<String> = []
        var writtenCounterIDs: Set<String> = []
        var readCounterIDs: Set<String> = []
    }
}
