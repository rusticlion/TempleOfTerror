import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    @State private var projectionText: String = ""
    @State private var showingAlert = false
    @State private var pendingAction: ActionOption?

    private let interactable = Interactable(
        title: "Trapped Pedestal",
        description: "An ancient pedestal covered in suspicious glyphs.",
        availableActions: [
            ActionOption(name: "Tinker with it", actionType: "Tinker", position: .risky, effect: .standard),
            ActionOption(name: "Study the Glyphs", actionType: "Study", position: .controlled, effect: .limited)
        ]
    )

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                PartyStatusView(viewModel: viewModel)
                ClocksView(viewModel: viewModel)
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text(interactable.title)
                        .font(.headline)
                    ForEach(interactable.availableActions, id: \.name) { action in
                        Button(action.name) {
                            pendingAction = action
                            if let character = viewModel.gameState.party.first {
                                projectionText = viewModel.calculateProjection(for: action, with: character)
                                showingAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Temple of Terror")
            .alert("Projection", isPresented: $showingAlert) {
                Button("Roll") {
                    if let action = pendingAction,
                       let character = viewModel.gameState.party.first {
                        let clockID = viewModel.gameState.activeClocks.first?.id
                        viewModel.performAction(for: action, with: character, onClock: clockID)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(projectionText)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
