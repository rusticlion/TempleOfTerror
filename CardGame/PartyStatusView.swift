import SwiftUI

struct PartyStatusView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Party Status")
                .font(.headline)

            ForEach(viewModel.gameState.party) { character in
                VStack(alignment: .leading) {
                    Text(character.name)
                        .font(.subheadline)
                        .bold()
                    Text("Stress: \(character.stress)")
                        .font(.caption)
                    Text("Harm - L: \(character.harm.lesser.count) M: \(character.harm.moderate.count) S: \(character.harm.severe.count)")
                        .font(.caption2)
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
