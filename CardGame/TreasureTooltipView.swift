import SwiftUI

struct TreasureTooltipView: View {
    let treasure: Treasure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(treasure.name)
                .font(Theme.displayFont(size: 16))
                .foregroundColor(Theme.ink)

            Text(treasure.description)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.inkLight)
                .fixedSize(horizontal: false, vertical: true)

            Text(treasure.grantedModifier.description ?? "[Fill in Modifier description]")
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.inkLight)
                .fixedSize(horizontal: false, vertical: true)

            if treasure.grantedModifier.uses > 0 {
                Text("Uses Remaining: \(treasure.grantedModifier.uses)")
                    .font(Theme.systemFont(size: 11))
                    .foregroundColor(Theme.inkFaded)
            }

            if !treasure.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(treasure.tags, id: \.self) { tag in
                        Text(tag)
                            .font(Theme.systemFont(size: 10, weight: .medium))
                            .foregroundColor(Theme.inkLight)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Theme.parchmentDeep.opacity(0.45), lineWidth: 1)
                            )
                    }
                }
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
