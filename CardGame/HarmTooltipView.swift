import SwiftUI

struct HarmTooltipView: View {
    let familyId: String
    let level: HarmLevel

    private var tier: HarmTier? {
        guard let family = HarmLibrary.families[familyId] else { return nil }
        switch level {
        case .lesser: return family.lesser
        case .moderate: return family.moderate
        case .severe: return family.severe
        }
    }

    private func penaltyDescription(_ penalty: Penalty) -> String {
        switch penalty {
        case .reduceEffect:
            return "All actions suffer -1 Effect."
        case .increaseStressCost(let amount):
            return "Stress costs are increased by \(amount)."
        case .actionPenalty(let actionType):
            return "\(actionType) rolls -1 die."
        case .banAction(let actionType):
            return "Cannot perform \(actionType)."
        case .actionPositionPenalty(let actionType):
            return "\(actionType) rolls at worse Position."
        case .actionEffectPenalty(let actionType):
            return "\(actionType) suffers -1 Effect."
        }
    }

    private func boonDescription(_ boon: Modifier) -> String {
        var parts: [String] = []
        if boon.bonusDice != 0 { parts.append("+\(boon.bonusDice)d") }
        if boon.improvePosition { parts.append("Improved Position") }
        if boon.improveEffect { parts.append("+1 Effect") }
        let detail = parts.joined(separator: ", ")
        if detail.isEmpty { return boon.description }
        return "\(detail) - \(boon.description)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let tier = tier {
                Text(tier.description)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                if let penalty = tier.penalty {
                    Text(penaltyDescription(penalty))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let boon = tier.boon {
                    Text(boonDescription(boon))
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Unknown Harm")
            }
        }
        .padding()
    }
}
