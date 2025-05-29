import SwiftUI

struct PartyStatusView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Party Status")
                .font(.headline)

            ForEach(viewModel.gameState.party) { character in
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.subheadline)
                        .bold()
                    if viewModel.partyMovementMode == .solo && viewModel.isPartyActuallySplit() {
                        if let locName = viewModel.getNodeName(for: character.id) {
                            Text("At: \(locName)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

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

                    // Active modifiers
                    if !character.modifiers.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Modifiers")
                                .font(.caption2)
                            ForEach(Array(character.modifiers.enumerated()), id: \.offset) { index, modifier in
                                Text("\(modifier.description) (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct PartyStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PartyStatusView(viewModel: GameViewModel())
    }
}
