import SwiftUI

struct InteractableCardView: View {
    let interactable: Interactable
    let selectedCharacter: Character?
    let onActionTapped: (ActionOption) -> Void

    private func hasPenalty(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        return false
    }

    private func hasBonus(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        for mod in character.modifiers {
            if mod.uses == 0 { continue }
            if let specific = mod.applicableToAction, specific != action.actionType { continue }
            if mod.bonusDice != 0 || mod.improvePosition || mod.improveEffect { return true }
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(interactable.title)
                .font(.title2).bold()
            Text(interactable.description)
                .font(.body)
            Divider()
            ForEach(interactable.availableActions, id: \.name) { action in
                Button(action.name) {
                    onActionTapped(action)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topTrailing) {
                    if hasPenalty(for: action) {
                        Image("icon_penalty_action")
                            .resizable()
                            .frame(width: 16, height: 16)
                    } else if hasBonus(for: action) {
                        Image("icon_bonus_action")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
