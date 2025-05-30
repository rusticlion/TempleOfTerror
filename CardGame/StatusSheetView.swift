import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PartyStatusView(viewModel: viewModel)
                Divider()
                ClocksView(viewModel: viewModel)
                Spacer()
            }
            .padding()
        }
    }
}

struct StatusSheetView_Previews: PreviewProvider {
    static var previews: some View {
        StatusSheetView(viewModel: GameViewModel())
    }
}
