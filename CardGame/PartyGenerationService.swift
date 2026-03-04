import Foundation

class PartyBuilderService {
    private let archetypeDict: [String: ArchetypeDefinition]

    init(content: ContentLoader = .shared) {
        self.archetypeDict = content.archetypeDict
    }

    private let namePool: [String] = [
        "Alex", "Jordan", "Morgan", "Riley", "Casey", "Jamie", "Skyler", "Quinn", "Taylor", "Drew",
        "Blake", "Cameron", "Dakota", "Emerson", "Finley", "Hayden", "Jesse", "Kai", "Logan", "Micah",
        "Noel", "Parker", "Rowan", "Sage", "Teagan", "Val", "Winter", "Zion", "Ashton", "Avery"
    ]

    func defaultPlan(for manifest: ScenarioManifest?) -> PartyBuildPlan {
        PartyBuildPlan(
            partySize: manifest?.partySize ?? 3,
            nativeArchetypeIDs: manifest?.nativeArchetypeIDs ?? [],
            selectedArchetypeIDs: [],
            mode: .randomNative
        )
    }

    func availableArchetypes(nativeArchetypeIDs: [String] = [], includeFullRoster: Bool = false) -> [ArchetypeDefinition] {
        let allArchetypes = archetypeDict.values.sorted { $0.id < $1.id }
        guard !includeFullRoster, !nativeArchetypeIDs.isEmpty else {
            return allArchetypes
        }

        let nativeArchetypes = nativeArchetypeIDs.compactMap { archetypeDict[$0] }
        return nativeArchetypes.isEmpty ? allArchetypes : nativeArchetypes
    }

    func buildParty(using plan: PartyBuildPlan) -> [Character] {
        var party: [Character] = []
        var availableNames = namePool
        let requestedCount = max(plan.partySize, 1)

        let allArchetypes = availableArchetypes(includeFullRoster: true)
        let nativeArchetypes = availableArchetypes(nativeArchetypeIDs: plan.nativeArchetypeIDs)

        let selectedArchetypes = deduplicatedArchetypes(for: plan.selectedArchetypeIDs)

        var resolvedPool: [ArchetypeDefinition]
        switch plan.mode {
        case .randomNative:
            resolvedPool = nativeArchetypes.count >= requestedCount ? nativeArchetypes : allArchetypes
        case .randomFullRoster:
            resolvedPool = allArchetypes
        case .manualSelection:
            var filledSelection = selectedArchetypes
            let fallbackPool = nativeArchetypes.count >= requestedCount ? nativeArchetypes : allArchetypes
            for archetype in fallbackPool where filledSelection.count < requestedCount {
                guard !filledSelection.contains(where: { $0.id == archetype.id }) else { continue }
                filledSelection.append(archetype)
            }
            resolvedPool = filledSelection
        }

        guard !resolvedPool.isEmpty else {
            print("Error: No archetypes are available for party generation.")
            return []
        }

        let finalCount = min(requestedCount, resolvedPool.count)
        guard finalCount <= namePool.count else {
            print("Error: Requested party size is larger than the available unique names.")
            return []
        }

        var availableArchetypes = resolvedPool
        for _ in 0..<finalCount {
            guard !availableArchetypes.isEmpty, !availableNames.isEmpty else { break }

            let selectedArchetype: ArchetypeDefinition
            if plan.mode == .manualSelection {
                selectedArchetype = availableArchetypes.removeFirst()
            } else {
                let archetypeIndex = Int.random(in: 0..<availableArchetypes.count)
                selectedArchetype = availableArchetypes.remove(at: archetypeIndex)
            }
            let nameIndex = Int.random(in: 0..<availableNames.count)
            let selectedName = availableNames.remove(at: nameIndex)

            let newCharacter = Character(
                id: UUID(),
                name: selectedName,
                archetypeID: selectedArchetype.id,
                characterClass: selectedArchetype.name,
                stress: 0,
                harm: HarmState(),
                actions: selectedArchetype.defaultActions
            )
            party.append(newCharacter)
        }
        return party
    }

    private func deduplicatedArchetypes(for archetypeIDs: [String]) -> [ArchetypeDefinition] {
        var seen: Set<String> = []
        var resolved: [ArchetypeDefinition] = []

        for archetypeID in archetypeIDs {
            guard seen.insert(archetypeID).inserted,
                  let archetype = archetypeDict[archetypeID] else { continue }
            resolved.append(archetype)
        }

        return resolved
    }
}
