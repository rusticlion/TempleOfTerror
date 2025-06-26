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
        penalty.longDescription
    }

    private func boonDescription(_ boon: Modifier) -> String {
        boon.longDescription
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
