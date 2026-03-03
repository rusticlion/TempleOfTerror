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
                    .font(Theme.displayFont(size: 16))
                    .foregroundColor(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if let penalty = tier.penalty {
                    Text(penaltyDescription(penalty))
                        .font(Theme.bodyFont(size: 14))
                        .foregroundColor(Theme.danger)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let boon = tier.boon {
                    Text(boonDescription(boon))
                        .font(Theme.bodyFont(size: 14))
                        .foregroundColor(Theme.success)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Unknown Harm")
                    .font(Theme.displayFont(size: 16))
                    .foregroundColor(Theme.ink)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.parchmentDeep.opacity(0.45), lineWidth: 1)
        )
    }
}
