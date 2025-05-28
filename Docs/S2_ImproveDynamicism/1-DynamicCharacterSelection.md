Task 1: Implement Dynamic Character Selection
The current implementation in ContentView.swift always uses the first character in the party (viewModel.gameState.party.first). We need to let the player choose which character to use for an action.

Action: Modify ContentView to manage a selected character.
Action: Create a CharacterSelectorView.
CharacterSelectorView.swift (New File)

Swift

import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Character")
                .font(.headline)
            Picker("Select Character", selection: $selectedCharacterID) {
                ForEach(characters) { character in
                    Text(character.name).tag(character.id as UUID?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
ContentView.swift (Updates)

Swift

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    // ... (other @State properties)
    @State private var selectedCharacterID: UUID? // New state to track selection

    // Helper to get the full character object
    private var selectedCharacter: Character? {
        viewModel.gameState.party.first { $0.id == selectedCharacterID }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // We'll initialize the selected character ID on appear
                .onAppear {
                    if selectedCharacterID == nil {
                        selectedCharacterID = viewModel.gameState.party.first?.id
                    }
                }

                CharacterSelectorView(characters: viewModel.gameState.party,
                                      selectedCharacterID: $selectedCharacterID) // Add the new view

                PartyStatusView(viewModel: viewModel)
                // ...
                // Update the Button's action closure
                Button(action.name) {
                    pendingAction = action
                    // Use the new selectedCharacter property
                    if let character = selectedCharacter {
                        projectionText = viewModel.calculateProjection(for: action, with: character)
                        showingAlert = true
                    }
                }
                // ...
            }
            // ...
            // Update the Alert's Roll button action
            Button("Roll") {
                if let action = pendingAction,
                   let character = selectedCharacter { // Use the selected character
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    viewModel.performAction(for: action, with: character, onClock: clockID)
                }
            }
            // ...
        }
    }
}