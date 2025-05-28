import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    @State private var showingDiceSheet = false
    @State private var pendingAction: ActionOption?
    @State private var selectedCharacterID: UUID? // Track selected character

    // Helper to retrieve the selected character object
    private var selectedCharacter: Character? {
        viewModel.gameState.party.first { $0.id == selectedCharacterID }
    }


    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                CharacterSelectorView(characters: viewModel.gameState.party,
                                      selectedCharacterID: $selectedCharacterID)
                PartyStatusView(viewModel: viewModel)
                ClocksView(viewModel: viewModel)
                Divider()

                if let node = viewModel.currentNode {
                    ForEach(node.interactables, id: \.id) { interactable in
                        InteractableCardView(interactable: interactable) { action in
                            pendingAction = action
                            if selectedCharacter != nil {
                                showingDiceSheet = true
                            }
                        }
                    }

                    Divider()

                    NodeConnectionsView(currentNode: viewModel.currentNode) { connection in
                        viewModel.move(to: connection)
                    }
                } else {
                    Text("Loading dungeon...")
                }

                Spacer()
            }
            .onAppear {
                if selectedCharacterID == nil {
                    selectedCharacterID = viewModel.gameState.party.first?.id
                }
            }
            .padding()
            .navigationTitle(viewModel.currentNode?.name ?? "Unknown Location")
            .sheet(isPresented: $showingDiceSheet) {
                if let action = pendingAction,
                   let character = selectedCharacter {
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    DiceRollView(viewModel: viewModel,
                                 action: action,
                                 character: character,
                                 clockID: clockID)
                } else {
                    Text("No action selected")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
