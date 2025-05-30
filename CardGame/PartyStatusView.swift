import SwiftUI

struct PartyStatusView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Party Status")
                .font(.headline)

            ForEach(viewModel.gameState.party) { character in
                let loc: String? = {
                    if viewModel.partyMovementMode == .solo && viewModel.isPartyActuallySplit() {
                        return viewModel.getNodeName(for: character.id)
                    }
                    return nil
                }()
                CharacterSheetView(character: character, locationName: loc)
            }
        }
    }
}

struct PartyStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PartyStatusView(viewModel: GameViewModel())
    }
}
