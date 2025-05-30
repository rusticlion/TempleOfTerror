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
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let tier = tier {
                Text(tier.description)
                    .font(.headline)
                if let penalty = tier.penalty {
                    Text(penaltyDescription(penalty))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Unknown Harm")
            }
        }
        .padding()
    }
}

#Preview {
    HarmTooltipView(familyId: "head_trauma", level: .moderate)
}
