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
                .font(Theme.displayFont(size: 22))
                .foregroundColor(Theme.ink)
            Text(interactable.description)
                .font(Theme.bodyFont(size: 15, italic: true))
                .foregroundColor(Theme.inkLight)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            if !interactable.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(interactable.tags, id: \.self) { tag in
                        Text(tag)
                            .font(Theme.systemFont(size: 10, weight: .medium))
                            .tracking(0.5)
                            .textCase(.uppercase)
                            .foregroundColor(Theme.inkLight)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Theme.parchmentDeep.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            }
            if !interactable.availableActions.isEmpty {
                Theme.InkDivider()
                ForEach(interactable.availableActions, id: \.name) { action in
                    let displayName = action.name
                    let emoji = ActionEmoji.emoji(for: action.actionType)
                    Button {
                        onActionTapped(action)
                    } label: {
                        HStack(spacing: 10) {
                            Text(emoji)
                                .font(.system(size: 18))
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 6) {
                                    Text(displayName)
                                        .font(Theme.bodyFontMedium(size: 14))
                                        .foregroundColor(Theme.ink)
                                    if !action.requiresTest {
                                        Text("AUTO")
                                            .font(Theme.systemFont(size: 10, weight: .semibold))
                                            .foregroundColor(Theme.inkFaded)
                                    }
                                }
                                Text(action.actionType)
                                    .font(Theme.systemFont(size: 11))
                                    .foregroundColor(Theme.inkLight)
                            }

                            Spacer()

                            Circle()
                                .fill(Theme.positionColor(action.position))
                                .frame(width: 7, height: 7)
                                .opacity(0.7)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Theme.parchmentDark.opacity(0.001))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.parchmentDeep.opacity(0.35), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .disabled(actionDisabled(action))
                    .opacity(actionDisabled(action) ? 0.4 : 1)
                    .overlay(alignment: .topTrailing) {
                        if hasPenalty(for: action) {
                            Circle()
                                .fill(Theme.danger)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("!")
                                        .font(Theme.systemFont(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 4, y: -4)
                        } else if hasBonus(for: action) {
                            Circle()
                                .fill(Theme.success)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("+")
                                        .font(Theme.systemFont(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            } else if interactable.isDisplayOnly {
                Theme.InkDivider()
                Text("Reference")
                    .font(Theme.systemFont(size: 11, weight: .semibold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundColor(Theme.inkFaded)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    interactable.isThreat ? Theme.danger.opacity(0.5) : Theme.parchmentDeep.opacity(0.55),
                    lineWidth: interactable.isThreat ? 2 : 1
                )
        )
        .overlay(alignment: .topTrailing) {
            if interactable.isThreat {
                HStack(spacing: 4) {
                    Text("⚠")
                        .font(.system(size: 12))
                    Text("THREAT")
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .tracking(0.5)
                }
                .foregroundColor(Theme.danger)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
    }
}
