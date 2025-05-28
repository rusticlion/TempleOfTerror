Task 3: Add Subtle Animations & Transitions
With the layout fixed, let's add a touch of "juice" to make the game feel more alive.

Action: Animate node transitions.
Action: Animate the appearance of interactables.
ContentView.swift (Animation Updates)

Swift

// In the ScrollView's VStack
if let node = viewModel.currentNode {
    ForEach(node.interactables, id: \.id) { interactable in
        InteractableCardView(interactable: interactable) { action in
            // ...
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity)) // Card fade-in
    }
    
    // ...
}

// And apply an animation modifier to the main content area
.animation(.default, value: viewModel.currentNode?.id) // Animate when the current node ID changes