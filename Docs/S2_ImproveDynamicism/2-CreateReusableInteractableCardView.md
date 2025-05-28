Task 2: Create a Reusable InteractableCardView
Let's move the hardcoded interactable into a proper, reusable SwiftUI view. This makes the ContentView cleaner and prepares us for having multiple interactables in a node.

InteractableCardView.swift (New File)

Swift

import SwiftUI

struct InteractableCardView: View {
    let interactable: Interactable
    let onActionTapped: (ActionOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(interactable.title)
                .font(.title2).bold()
            Text(interactable.description)
                .font(.body)
            Divider()
            ForEach(interactable.availableActions, id: \.name) { action in
                Button(action.name) {
                    onActionTapped(action)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
ContentView.swift (Updates)

Swift

// ... inside ContentView body
Divider()
InteractableCardView(interactable: interactable) { action in
    pendingAction = action
    if let character = selectedCharacter {
        projectionText = viewModel.calculateProjection(for: action, with: character)
        showingAlert = true
    }
}
Spacer()
// ...