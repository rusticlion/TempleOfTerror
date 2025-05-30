import SwiftUI

struct CharacterSheetView: View {
    let character: Character
    var locationName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(character.name)
                .font(.subheadline)
                .bold()

            if let locationName {
                Text("At: \(locationName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Stress indicator
            VStack(alignment: .leading, spacing: 2) {
                Text("Stress \(character.stress)/9")
                    .font(.caption2)
                HStack(spacing: 2) {
                    ForEach(1...9, id: \.self) { index in
                        Image(character.stress >= index ? "icon_stress_pip_lit" : "icon_stress_pip_unlit")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
            }

            // Harm indicator
            VStack(alignment: .leading, spacing: 2) {
                Text("Harm")
                    .font(.caption2)
                HStack {
                    ForEach(0..<HarmState.lesserSlots, id: \.self) { index in
                        Image(index < character.harm.lesser.count ? "icon_harm_lesser_full" : "icon_harm_lesser_empty")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                        Image(index < character.harm.moderate.count ? "icon_harm_moderate_full" : "icon_harm_moderate_empty")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    ForEach(0..<HarmState.severeSlots, id: \.self) { index in
                        Image(index < character.harm.severe.count ? "icon_harm_severe_full" : "icon_harm_severe_empty")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                ForEach(Array(character.harm.lesser.enumerated()), id: \.offset) { _, entry in
                    Text("Lesser - \(entry.description)")
                        .font(.caption2)
                }
                ForEach(Array(character.harm.moderate.enumerated()), id: \.offset) { _, entry in
                    Text("Moderate - \(entry.description)")
                        .font(.caption2)
                }
                ForEach(Array(character.harm.severe.enumerated()), id: \.offset) { _, entry in
                    Text("Severe - \(entry.description)")
                        .font(.caption2)
                }
            }

            // Action ratings
            VStack(alignment: .leading, spacing: 2) {
                Text("Actions")
                    .font(.caption2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 2) {
                    ForEach(character.actions.sorted(by: { $0.key < $1.key }), id: \.key) { action, rating in
                        HStack(spacing: 2) {
                            Text(action)
                            HStack(spacing: 1) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image("icon_stress_pip_lit")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .font(.caption2)
                    }
                }
            }

            // Treasures
            if !character.treasures.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Treasures")
                        .font(.caption2)
                    ForEach(character.treasures) { treasure in
                        Text(treasure.name)
                            .font(.caption2)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CharacterSheetView(character: GameViewModel().gameState.party.first!)
}
