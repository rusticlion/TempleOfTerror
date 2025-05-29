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
                        ProgressView(value: Float(character.stress), total: 9)
                            .progressViewStyle(.linear)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Harm")
                            .font(.caption2)
                        HStack {
                            ProgressView(value: Float(character.harm.lesser.count), total: Float(HarmState.lesserSlots))
                                .progressViewStyle(.linear)
                                .tint(.yellow)
                            ProgressView(value: Float(character.harm.moderate.count), total: Float(HarmState.moderateSlots))
                                .progressViewStyle(.linear)
                                .tint(.orange)
                            ProgressView(value: Float(character.harm.severe.count), total: Float(HarmState.severeSlots))
                                .progressViewStyle(.linear)
                                .tint(.red)
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
