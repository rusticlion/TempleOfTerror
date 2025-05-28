Task 3: Implement the Roguelite Run Loop
Finally, let's wrap our experience in a proper "run."

Action: Create a "Game Over" condition and view.
Action: Add a "New Run" button to restart the GameViewModel.
GameViewModel.swift (Additions)

Swift

// Add a new GameStatus enum
enum GameStatus { case playing, gameOver }

// Add to GameState
struct GameState: Codable {
    //...
    var status: GameStatus = .playing
}

// Modify performAction to check for game over conditions
// For example, in processConsequences for .sufferHarm:
// if character has too much harm { gameState.status = .gameOver }

// Add a function to restart the game
func startNewRun() {
    // This re-initializes the entire game state, just like init()
    self.gameState = GameState(/*... fresh party/clocks ...*/)
    generateDungeon()
}
ContentView.swift (Updates)

Swift

struct ContentView: View {
    //...
    var body: some View {
        ZStack { // Use a ZStack to overlay the Game Over view
            NavigationView {
                // ... your existing VStack with all the game views
            }
            
            if viewModel.gameState.status == .gameOver {
                Color.black.opacity(0.75).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Game Over").font(.largeTitle).bold().foregroundColor(.red)
                    Text("The tomb claims another party.").foregroundColor(.white)
                    Button("Try Again") {
                        viewModel.startNewRun()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
    }
}