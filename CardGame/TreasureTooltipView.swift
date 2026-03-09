import SwiftUI

struct TreasureTooltipView: View {
    let treasure: Treasure

    private var useLabel: String {
        if treasure.grantedModifier.uses > 0 {
            let uses = treasure.grantedModifier.uses
            return "\(uses) use" + (uses == 1 ? "" : "s") + " remaining"
        }
        return "Reusable"
    }

    private var appliesToText: String? {
        var details: [String] = []

        if let actions = treasure.grantedModifier.applicableActions, !actions.isEmpty {
            details.append("Use on: \(actions.joined(separator: ", "))")
        }

        if let tag = treasure.grantedModifier.requiredTag {
            details.append("Needs tag: \(tag)")
        }

        return details.isEmpty ? nil : details.joined(separator: "  •  ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Treasure")
                        .font(Theme.systemFont(size: 10, weight: .semibold))
                        .foregroundColor(Theme.goldDim)
                        .textCase(.uppercase)
                        .tracking(0.7)

                    Text(treasure.name)
                        .font(Theme.displayFont(size: 20))
                        .foregroundColor(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                Text(useLabel)
                    .font(Theme.systemFont(size: 10, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Theme.gold.opacity(0.22), in: Capsule())
            }

            Text(treasure.description)
                .font(Theme.bodyFont(size: 15, italic: true))
                .foregroundColor(Theme.inkLight)
                .fixedSize(horizontal: false, vertical: true)

            Theme.InkDivider()

            VStack(alignment: .leading, spacing: 5) {
                Text("Benefit")
                    .font(Theme.systemFont(size: 10, weight: .semibold))
                    .foregroundColor(Theme.inkFaded)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Text(treasure.grantedModifier.longDescription)
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.inkLight)
                    .fixedSize(horizontal: false, vertical: true)

                if let appliesToText {
                    Text(appliesToText)
                        .font(Theme.systemFont(size: 11, weight: .medium))
                        .foregroundColor(Theme.goldDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !treasure.tags.isEmpty {
                Theme.InkDivider()

                HStack(spacing: 6) {
                    ForEach(treasure.tags, id: \.self) { tag in
                        Text(tag)
                            .font(Theme.systemFont(size: 10, weight: .medium))
                            .foregroundColor(Theme.inkLight)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Theme.parchment.opacity(0.5), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Theme.parchmentDeep.opacity(0.45), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: 300, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Theme.parchment, Theme.gold.opacity(0.16), Theme.parchmentDark.opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.goldDim.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Theme.gold.opacity(0.2), radius: 10, y: 4)
    }
}
