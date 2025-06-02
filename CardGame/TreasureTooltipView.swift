import SwiftUI

struct TreasureTooltipView: View {
    let treasure: Treasure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(treasure.name)
                .font(.headline)
            Text(treasure.description)
                .font(.body)
            Text(treasure.grantedModifier.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !treasure.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(treasure.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(2)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
    }
}
