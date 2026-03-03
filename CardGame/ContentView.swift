import SwiftUI

struct PendingRoll: Identifiable {
    let id = UUID()
    let action: ActionOption
    let interactableID: String
}

struct ContentView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var pendingRoll: PendingRoll?
    @State private var selectedCharacterID: UUID? // Track selected character
    @State private var showingStatusSheet = false // Controls the party sheet
    @State private var showingMap = false // Controls the map sheet
    @State private var showingCharacterSheet = false // Controls the character drawer
    @State private var doorProgress: CGFloat = 0 // For sliding door transition
    @Environment(\.scenePhase) private var scenePhase

    init(scenario: String = "tomb") {
        // Start a new game using the provided scenario
        let vm = GameViewModel(startNewWithScenario: scenario)
        _viewModel = StateObject(wrappedValue: vm)
        _selectedCharacterID = State(initialValue: vm.gameState.party.first?.id)
    }

    init(viewModel: GameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedCharacterID = State(initialValue: viewModel.gameState.party.first?.id)
    }

    // Helper to retrieve the selected character object
    private var selectedCharacter: Character? {
        viewModel.gameState.party.first { $0.id == selectedCharacterID && !$0.isDefeated }
    }

    private var gameOverTitle: String {
        switch viewModel.gameState.runOutcome {
        case .victory:
            return "Victory"
        case .escaped:
            return "Run Ended"
        default:
            return "Game Over"
        }
    }

    private var gameOverBody: String {
        if let text = viewModel.gameState.runOutcomeText, !text.isEmpty {
            return text
        }
        return "The tomb claims another party."
    }

    private func performTransition(to connection: NodeConnection) {
        withAnimation(.linear(duration: 0.3)) {
            doorProgress = 1
        }
        AudioManager.shared.play(sound: "sfx_stone_door_slide.wav")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let id = selectedCharacterID {
                viewModel.move(characterID: id, to: connection)
            }
            withAnimation(.linear(duration: 0.3)) {
                doorProgress = 0
            }
        }
    }


    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(
                    title: viewModel.getNodeName(for: selectedCharacterID) ?? "Unknown Location"
                )
                Rectangle()
                    .fill(Theme.leatherLight)
                    .frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let node = viewModel.node(for: selectedCharacterID) {
                            VStack(alignment: .leading, spacing: 16) {
                                let threats = node.interactables.filter { $0.isThreat }
                                let items = threats.isEmpty ? node.interactables : threats

                                let vm = viewModel
                                ForEach(items, id: \.id) { interactable in
                                    InteractableCardView(viewModel: vm,
                                                        interactable: interactable,
                                                        selectedCharacter: selectedCharacter) { action in
                                        if let character = selectedCharacter {
                                            if action.requiresTest {
                                                pendingRoll = PendingRoll(action: action, interactableID: interactable.id)
                                            } else {
                                                // Directly apply the free-action consequences
                                                _ = vm.performFreeAction(for: action, with: character, interactableID: interactable.id)
                                            }
                                        }
                                    }
                                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                                }

                                if threats.isEmpty {
                                    Divider()

                                    NodeConnectionsView(currentNode: viewModel.node(for: selectedCharacterID)) { connection in
                                        performTransition(to: connection)
                                    }
                                }
                            }
                            .id(node.id)
                            .transition(.opacity)
                        } else {
                            Text("Loading dungeon...")
                                .font(Theme.bodyFont(size: 16, italic: true))
                                .foregroundColor(Theme.parchmentDark)
                        }
                    }
                    .padding()
                    .animation(.default, value: viewModel.node(for: selectedCharacterID)?.id)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 8) {
                    if showingCharacterSheet, let character = selectedCharacter {
                        CharacterSheetView(character: character)
                            .transition(.move(edge: .bottom))
                            .padding(.horizontal)
                    }

                    VStack(spacing: 6) {
                        Button {
                            withAnimation {
                                showingCharacterSheet.toggle()
                            }
                        } label: {
                            Image(systemName: showingCharacterSheet ? "chevron.down" : "chevron.up")
                                .foregroundColor(Theme.parchmentDark)
                                .padding(6)
                                .background(Theme.leatherLight.opacity(0.8), in: Circle())
                        }
                        .buttonStyle(.plain)

                        CharacterSelectorView(characters: viewModel.gameState.party,
                                              selectedCharacterID: $selectedCharacterID,
                                              movementMode: viewModel.partyMovementMode)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .background(Theme.leather)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Theme.leatherLight)
                            .frame(height: 1)
                    }

                    HStack(spacing: 12) {
                        Button {
                            viewModel.toggleMovementMode()
                        } label: {
                            Text(viewModel.partyMovementMode == .grouped ? "Split Up" : "Stick Together")
                                .font(Theme.systemFont(size: 14, weight: .semibold))
                                .foregroundColor(Theme.parchmentDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Theme.leatherLight.opacity(0.5))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.inkFaded.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.partyMovementMode == .solo && !viewModel.canRegroup())
                        .opacity(viewModel.partyMovementMode == .solo && !viewModel.canRegroup() ? 0.6 : 1)

                        Spacer()

                        Button {
                            showingStatusSheet.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.3.fill")
                                Text("Status")
                            }
                            .font(Theme.systemFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.parchmentDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.leatherLight.opacity(0.5))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.inkFaded.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            showingMap.toggle()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "map")
                                Text("Map")
                            }
                            .font(Theme.systemFont(size: 14, weight: .semibold))
                            .foregroundColor(Theme.parchmentDark)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.leatherLight.opacity(0.5))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.inkFaded.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 2)
                }
                .padding(.top, 6)
                .padding(.bottom, 8)
                .background(Theme.toolbarBackground)
                .animation(.easeInOut, value: showingCharacterSheet)
            }
            .disabled(viewModel.gameState.status == .gameOver)
            .sheet(item: $pendingRoll) { pending in
                if let character = selectedCharacter {
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    DiceRollView(viewModel: viewModel,
                                 action: pending.action,
                                 character: character,
                                 clockID: clockID,
                                 interactableID: pending.interactableID)
                } else {
                    Text("No action selected")
                }
            }

            SlidingDoor(progress: doorProgress)


            if viewModel.gameState.status == .gameOver {
                Theme.bg.opacity(0.85).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text(gameOverTitle)
                        .font(Theme.displayFont(size: 36))
                        .foregroundColor(Theme.danger)
                    Text(gameOverBody)
                        .font(Theme.bodyFont(size: 16, italic: true))
                        .foregroundColor(Theme.parchmentDark)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        viewModel.restartCurrentScenario()
                        selectedCharacterID = viewModel.gameState.party.first?.id
                    }
                    .font(Theme.displayFont(size: 18, weight: .semibold))
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Theme.gold, Theme.goldDim],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingStatusSheet) {
            StatusSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingMap) {
            MapView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                viewModel.saveGame()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundColor(Theme.parchmentDark)
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

struct SlidingDoor: View {
    var progress: CGFloat
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(
                        ImagePaint(image: Image("texture_stone_door"), scale: 1)
                    )
                    .frame(width: geo.size.width * progress)
                Spacer(minLength: 0)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
