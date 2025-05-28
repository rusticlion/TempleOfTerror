Task 1: Isolate the Header
Let's fix the overlap bugs by creating a dedicated, self-contained view for the top part of the screen.

Action: Create a new HeaderView.swift.
Action: Move the Navigation Title, CharacterSelectorView, and any other top-level status indicators into this new view.
HeaderView.swift (New File)

Swift

import SwiftUI

struct HeaderView: View {
    let title: String
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes space
            
            CharacterSelectorView(characters: characters,
                                  selectedCharacterID: $selectedCharacterID)
        }
        .padding(.horizontal)
        .padding(.bottom) // Give it some breathing room from the content below
    }
}
ContentView.swift (Updates)
We will remove the NavigationView and its .navigationTitle modifier, instead treating the HeaderView as our custom title area. This gives us more control.

Swift

struct ContentView: View {
    // ... existing properties

    var body: some View {
        ZStack {
            // Main game view
            VStack(spacing: 0) { // Use spacing: 0 for more control
                HeaderView(
                    title: viewModel.currentNode?.name ?? "Unknown Location",
                    characters: viewModel.gameState.party,
                    selectedCharacterID: $selectedCharacterID
                )

                // Use a ScrollView for the main content to prevent overflow
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // All other views go here
                        PartyStatusView(viewModel: viewModel)
                        ClocksView(viewModel: viewModel)
                        Divider()
                        // ... Interactables and NodeConnections
                    }
                    .padding()
                }
            }
            .disabled(viewModel.gameState.status == .gameOver) // Disable interaction behind overlay

            // Game Over overlay remains the same
            if viewModel.gameState.status == .gameOver {
                // ...
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // Let content go to the bottom
    }
}