import Foundation

struct PresentedNodeConnection: Identifiable {
    let connection: NodeConnection
    let isTraversable: Bool

    var id: String {
        "\(connection.toNodeID.uuidString)|\(connection.description)"
    }

    var isStructurallyUnlocked: Bool {
        connection.isUnlocked
    }
}

extension GameViewModel {
    func groupActionParticipants(
        for action: ActionOption,
        interactableID: String?,
        leaderID: UUID
    ) -> [Character] {
        guard let nodeID = runtime.currentNodeID(for: leaderID, in: gameState) else {
            return []
        }

        let interactableTags = currentInteractable(id: interactableID ?? "", for: leaderID)?.tags ?? []
        return gameState.party.filter { character in
            guard !character.isDefeated else { return false }
            guard gameState.characterLocations[character.id.uuidString] == nodeID else { return false }

            let projection = calculateProjection(
                for: action,
                with: character,
                interactableTags: interactableTags
            )
            return !projection.isActionBanned
        }
    }

    func node(for characterID: UUID?) -> MapNode? {
        runtime.node(for: characterID, in: gameState)
    }

    func presentedConnections(for characterID: UUID?) -> [PresentedNodeConnection] {
        guard let characterID,
              let node = runtime.node(for: characterID, in: gameState) else {
            return []
        }

        return node.connections.map { connection in
            PresentedNodeConnection(
                connection: connection,
                isTraversable: runtime.canTraverse(
                    characterID: characterID,
                    via: connection,
                    in: gameState
                )
            )
        }
    }

    func partyHasTreasureTag(_ tag: String) -> Bool {
        for member in gameState.party where !member.isDefeated {
            for treasure in member.treasures where treasure.tags.contains(tag) {
                return true
            }
        }
        return false
    }

    func getNodeName(for characterID: UUID?) -> String? {
        runtime.nodeName(for: characterID, in: gameState)
    }

    func visibleInteractables(for characterID: UUID?) -> [Interactable] {
        guard let characterID,
              let character = currentCharacter(for: characterID) else {
            return []
        }

        return runtime.visibleInteractables(for: characterID, in: gameState).compactMap { interactable in
            filteredInteractable(interactable, for: character)
        }
    }

    func activeThreats(for characterID: UUID?) -> [Interactable] {
        runtime.threats(for: characterID, in: gameState)
    }

    func isCharacterEngaged(_ characterID: UUID?) -> Bool {
        runtime.isCharacterEngaged(characterID, in: gameState)
    }

    func isPartyActuallySplit() -> Bool {
        runtime.isPartyActuallySplit(in: gameState)
    }

    func canRegroup() -> Bool {
        runtime.canRegroup(in: gameState)
    }

    func toggleMovementMode() {
        if partyMovementMode == .grouped {
            partyMovementMode = .solo
        } else if canRegroup() {
            partyMovementMode = .grouped
        }
    }

    func currentCharacter(for characterID: UUID) -> Character? {
        gameState.party.first(where: { $0.id == characterID })
    }

    func currentInteractable(id interactableID: String, for characterID: UUID) -> Interactable? {
        guard let nodeID = gameState.characterLocations[characterID.uuidString] else { return nil }
        return gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.first(where: { $0.id == interactableID })
    }

    func unavailableActionMessage(
        for action: ActionOption,
        interactableID: String?,
        characterID: UUID
    ) -> String? {
        guard let character = currentCharacter(for: characterID) else {
            return "Character not found."
        }

        if let interactableID {
            guard let interactable = currentInteractable(id: interactableID, for: characterID),
                  let filteredInteractable = filteredInteractable(interactable, for: character),
                  filteredInteractable.availableActions.contains(where: { $0.name == action.name }) else {
                return "That action is no longer available."
            }
            return nil
        }

        guard isActionAvailable(action, on: nil, for: character) else {
            return "That action is no longer available."
        }
        return nil
    }

    func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
    ) -> Bool {
        pendingResolutionDriver.areConditionsMet(
            conditions: conditions,
            forCharacter: character,
            finalEffect: finalEffect,
            finalPosition: finalPosition,
            in: gameState
        )
    }

    private func isInteractableVisible(
        _ interactable: Interactable,
        for character: Character
    ) -> Bool {
        areConditionsMet(
            conditions: interactable.conditions,
            forCharacter: character,
            finalEffect: .standard,
            finalPosition: .risky
        )
    }

    private func isActionAvailable(
        _ action: ActionOption,
        on interactable: Interactable?,
        for character: Character
    ) -> Bool {
        let tags = interactable?.tags ?? []
        let projection = calculateProjection(for: action, with: character, interactableTags: tags)
        return areConditionsMet(
            conditions: action.conditions,
            forCharacter: character,
            finalEffect: projection.finalEffect,
            finalPosition: projection.finalPosition
        )
    }

    private func filteredInteractable(
        _ interactable: Interactable,
        for character: Character
    ) -> Interactable? {
        guard isInteractableVisible(interactable, for: character) else { return nil }
        var filtered = interactable
        filtered.availableActions = interactable.availableActions.filter { action in
            isActionAvailable(action, on: interactable, for: character)
        }
        return filtered
    }
}
