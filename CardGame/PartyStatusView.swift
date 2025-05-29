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

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Stress \(character.stress)/9")
                            .font(.caption2)
                        HStack(spacing: 2) {
                            ForEach(1...9, id: .self) { index in
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
                            ForEach(0..<HarmState.lesserSlots, id: .self) { index in
                                Image(index < character.harm.lesser.count ? "icon_harm_lesser_full" : "icon_harm_lesser_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            ForEach(0..<HarmState.moderateSlots, id: .self) { index in
                                Image(index < character.harm.moderate.count ? "icon_harm_moderate_full" : "icon_harm_moderate_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            ForEach(0..<HarmState.severeSlots, id: .self) { index in
                                Image(index < character.harm.severe.count ? "icon_harm_severe_full" : "icon_harm_severe_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
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
