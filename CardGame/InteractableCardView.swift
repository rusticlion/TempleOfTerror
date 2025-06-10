import SwiftUI

struct InteractableCardView: View {
    @ObservedObject var viewModel: GameViewModel
    let interactable: Interactable
    let selectedCharacter: Character?
    let onActionTapped: (ActionOption) -> Void

    private func hasPenalty(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        let tags = interactable.tags
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                switch penalty {
                case .actionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .banAction(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionPositionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionEffectPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                default:
                    break
                }
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                switch penalty {
                case .actionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .banAction(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionPositionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionEffectPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                default:
                    break
                }
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                switch penalty {
                case .actionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .banAction(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionPositionPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                case .actionEffectPenalty(let t, let tag) where t == action.actionType && (tag == nil || tags.contains(tag!)):
                    return true
                default:
                    break
                }
            }
        }
        return false
    }

    private func hasBonus(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        let tags = interactable.tags
        for mod in character.modifiers {
            if mod.uses == 0 { continue }
            if let actions = mod.applicableActions {
                if !actions.contains(action.actionType) { continue }
            } else if let specific = mod.applicableToAction, specific != action.actionType {
                continue
            }
            if let req = mod.requiredTag, !tags.contains(req) { continue }
            if mod.bonusDice != 0 || mod.improvePosition || mod.improveEffect { return true }
        }
        return false
    }

    private func actionDisabled(_ action: ActionOption) -> Bool {
        if let tag = action.requiredTag {
            return !viewModel.partyHasTreasureTag(tag)
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(interactable.title)
                .font(.title2).bold()
            Text(interactable.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            if !interactable.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(interactable.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(2)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(4)
                    }
                }
            }
            Divider()
            ForEach(interactable.availableActions, id: \.name) { action in
                let displayName = action.requiresTest ? action.name : "\(action.name) (Auto)"
                let emoji = ActionEmoji.emoji(for: action.actionType)
                Button("\(emoji) \(displayName)") {
                    onActionTapped(action)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .disabled(actionDisabled(action))
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(interactable.isThreat ? Color.red : Color.clear, lineWidth: 3)
        )
        .overlay(alignment: .topLeading) {
            if interactable.isThreat {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .padding(4)
            }
        }
        .shadow(radius: 4)
    }
}
