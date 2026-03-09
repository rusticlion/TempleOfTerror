import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    private var visibleClocks: [GameClock] {
        viewModel.gameState.activeClocks.filter { $0.progress > 0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !visibleClocks.isEmpty {
                    ClocksView(clocks: visibleClocks)
                    Theme.InkDivider()
                }

                PartyStatusView(viewModel: viewModel)
                Spacer()
            }
            .padding()
        }
        .background(Theme.bgWarm)
        .presentationBackground(Theme.bgWarm)
    }
}

struct StatusSheetView_Previews: PreviewProvider {
    static var previews: some View {
        StatusSheetView(viewModel: GameViewModel())
    }
}
