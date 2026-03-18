import Foundation

extension GameViewModel {
    var debugFixedDiceSummary: String {
        debugFixedDiceValues.map(String.init).joined(separator: ",")
    }

    @discardableResult
    func setDebugFixedDice(from rawValue: String) -> Bool {
        guard let parsed = Self.parseDebugDiceValues(from: rawValue) else {
            return false
        }
        debugFixedDiceValues = parsed
        return true
    }

    func debugActionDiceOverride(rawPool: Int) -> [Int]? {
        guard debugFixedDiceEnabled else { return nil }
        let diceCount = rawPool <= 0 ? 2 : rawPool
        return expandedDebugDiceValues(forCount: max(diceCount, 1))
    }

    func debugResistanceDiceOverride() -> [Int]? {
        guard debugFixedDiceEnabled else { return nil }
        let pool = pendingResistanceDicePool() ?? 0
        let diceCount = pool > 0 ? pool : 2
        return expandedDebugDiceValues(forCount: max(diceCount, 1))
    }

    @discardableResult
    func debugJumpParty(to nodeID: UUID) -> Bool {
        do {
            return try runSessionController.jumpParty(
                to: nodeID,
                in: &gameState
            )
        } catch {
            print("Failed to debug jump party: \(error)")
            return false
        }
    }

    @discardableResult
    func debugJump(characterID: UUID, to nodeID: UUID) -> Bool {
        do {
            return try runSessionController.jump(
                characterID: characterID,
                to: nodeID,
                in: &gameState
            )
        } catch {
            print("Failed to debug jump character: \(error)")
            return false
        }
    }

    func debugSetFlag(_ flagID: String, isSet: Bool) {
        let trimmed = flagID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if isSet {
            gameState.scenarioFlags[trimmed] = true
        } else {
            gameState.scenarioFlags.removeValue(forKey: trimmed)
        }
        saveGame()
    }

    func debugSetCounter(_ counterID: String, value: Int) {
        let trimmed = counterID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        gameState.scenarioCounters[trimmed] = value
        saveGame()
    }

    func debugAdjustCounter(_ counterID: String, by amount: Int) {
        let trimmed = counterID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        gameState.scenarioCounters[trimmed, default: 0] += amount
        saveGame()
    }

    @discardableResult
    func debugGrantTreasure(_ treasureID: String, to characterID: UUID) -> Bool {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == characterID }),
              let treasure = activeContent.treasureTemplates.first(where: { $0.id == treasureID }) else {
            return false
        }

        if gameState.party[characterIndex].treasures.contains(where: { $0.id == treasureID }) {
            return false
        }

        gameState.party[characterIndex].treasures.append(treasure)
        if !gameState.party[characterIndex].modifiers.contains(where: { $0.id == treasure.grantedModifier.id }) {
            gameState.party[characterIndex].modifiers.append(treasure.grantedModifier)
        }
        saveGame()
        return true
    }

    var availableTreasureTemplates: [Treasure] {
        activeContent.treasureTemplates
    }

    @discardableResult
    func debugGrantModifier(
        to characterID: UUID,
        bonusDice: Int = 0,
        improvePosition: Bool = false,
        improveEffect: Bool = false,
        uses: Int = 1,
        description: String
    ) -> Bool {
        guard let characterIndex = gameState.party.firstIndex(where: { $0.id == characterID }) else {
            return false
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDescription.isEmpty else {
            return false
        }

        let modifier = Modifier(
            bonusDice: bonusDice,
            improvePosition: improvePosition,
            improveEffect: improveEffect,
            uses: max(uses, 0),
            isOptionalToApply: true,
            description: trimmedDescription
        )
        gameState.party[characterIndex].modifiers.append(modifier)
        saveGame()
        return true
    }

    private static func parseDebugDiceValues(from rawValue: String) -> [Int]? {
        let parts = rawValue
            .split(whereSeparator: { $0 == "," || $0 == " " || $0 == "\n" || $0 == "\t" })
            .map(String.init)

        let values = parts.compactMap(Int.init)
        guard !values.isEmpty else { return nil }
        guard values.allSatisfy({ (1...6).contains($0) }) else { return nil }
        return values
    }

    private func expandedDebugDiceValues(forCount count: Int) -> [Int] {
        let sanitizedValues = debugFixedDiceValues.filter { (1...6).contains($0) }
        let baseValues = sanitizedValues.isEmpty ? [6] : sanitizedValues
        if baseValues.count >= count {
            return Array(baseValues.prefix(count))
        }

        var expanded = baseValues
        while expanded.count < count {
            expanded.append(baseValues[(expanded.count - baseValues.count) % baseValues.count])
        }
        return expanded
    }
}
