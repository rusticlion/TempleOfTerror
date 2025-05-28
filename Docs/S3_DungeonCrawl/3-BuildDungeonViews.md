Task 3: Build the Dungeon Views
We need a view to display the node connections for the current room and another (optional, for this sprint) to show the full map.

Action: Create a NodeConnectionsView.
Action: Update ContentView to display the interactables for the current node.
NodeConnectionsView.swift (New File)

Swift

import SwiftUI

struct NodeConnectionsView: View {
    var currentNode: MapNode?
    let onMove: (NodeConnection) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Paths from this room").font(.headline)
            if let node = currentNode {
                ForEach(node.connections, id: \.toNodeID) { connection in
                    Button {
                        onMove(connection)
                    } label: {
                        HStack {
                            Text(connection.description)
                            Spacer()
                            if !connection.isUnlocked {
                                Image(systemName: "lock.fill")
                            }
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(!connection.isUnlocked)
                }
            }
        }
    }
}
ContentView.swift (Major Updates)

Swift

struct ContentView: View {
    // ... existing @State properties

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // CharacterSelectorView, PartyStatusView, ClocksView (no changes)
                // ...

                Divider()

                // NEW: Show interactables from the CURRENT node
                if let node = viewModel.currentNode {
                    // This loop replaces the single hardcoded InteractableCardView
                    ForEach(node.interactables, id: \.title) { interactable in
                        InteractableCardView(interactable: interactable) { action in
                            // The logic for showing the dice sheet remains the same
                            pendingAction = action
                            if selectedCharacter != nil {
                                showingDiceSheet = true
                            }
                        }
                    }

                    Divider()

                    // NEW: Show the connections for the current node
                    NodeConnectionsView(currentNode: viewModel.currentNode) { connection in
                        viewModel.move(to: connection)
                    }
                } else {
                    Text("Loading dungeon...")
                }

                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.currentNode?.name ?? "Unknown Location") // Dynamic title!
            // ... sheet modifier remains the same
        }
    }
}