Task 2: Implement the "Push Yourself" Mechanic
Let's give players a way to spend Stress for a bonus die, a core tactical choice in FitD.

Action: Add a pushYourself function to the GameViewModel.
Action: Add a "Push Yourself" button to the DiceRollView.
DiceRollView.swift (UI Updates)

Swift

// In DiceRollView

struct DiceRollView: View {
    // ... existing properties
    @State private var extraDiceFromPush = 0
    @State private var hasPushed = false // Prevent pushing multiple times

    var body: some View {
        VStack(spacing: 20) {
            // ... existing header text ...

            Spacer()

            if let result = result {
                // ... result view ...
            } else {
                // Pre-roll view
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        let totalDice = (diceValues.count + extraDiceFromPush)
                        ForEach(0..<totalDice, id: \.self) { index in
                            Image(systemName: "die.face.\(diceValues.indices.contains(index) ? diceValues[index] : 1).fill")
                                .font(.largeTitle)
                                .foregroundColor(index >= diceValues.count ? .cyan : .primary) // Highlight the pushed die
                                .rotationEffect(.degrees(isRolling ? 360 : 0))
                        }
                    }

                    // The new button!
                    Button {
                        viewModel.pushYourself(forCharacter: character)
                        extraDiceFromPush += 1
                        hasPushed = true
                    } label: {
                        Text("Push Yourself (+1d for 2 Stress)")
                    }
                    .disabled(hasPushed) // Disable after one push
                    .buttonStyle(.bordered)
                }
            }

            Spacer()
            
            // ... Roll/Done buttons ...
        }
        // ...
    }
}
GameViewModel.swift (New Function)

Swift

// In GameViewModel

func pushYourself(forCharacter character: Character) {
    if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
        let currentStress = gameState.party[charIndex].stress
        // FitD rules: Pushing costs 2 stress. If you don't have enough, you can still do it, but you take Trauma.
        if currentStress + 2 > 9 {
            // Handle Trauma case later
        }
        gameState.party[charIndex].stress += 2
        // We can add logic here for other types of pushing later.
    }
}