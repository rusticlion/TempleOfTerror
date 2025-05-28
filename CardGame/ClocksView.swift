import SwiftUI

struct ClocksView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Clocks")
                .font(.headline)
            ForEach(viewModel.gameState.activeClocks) { clock in
                Text("\(clock.name): \(clock.progress) / \(clock.segments)")
                    .font(.caption)
            }
        }
    }
}

struct ClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ClocksView(viewModel: GameViewModel())
    }
}
