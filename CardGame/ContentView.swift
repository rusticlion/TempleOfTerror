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
            VStack(spacing: 0) {
                HeaderView(
                    title: viewModel.getNodeName(for: selectedCharacterID) ?? "Unknown Location"
                )

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

                    VStack(spacing: 4) {
                        Button {
                            withAnimation {
                                showingCharacterSheet.toggle()
                            }
                        } label: {
                            Image(systemName: showingCharacterSheet ? "chevron.down" : "chevron.up")
                                .padding(6)
                                .background(.thinMaterial, in: Circle())
                        }

                        CharacterSelectorView(characters: viewModel.gameState.party,
                                              selectedCharacterID: $selectedCharacterID,
                                              movementMode: viewModel.partyMovementMode)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    HStack {
                        Button {
                            viewModel.toggleMovementMode()
                        } label: {
                            Text(viewModel.partyMovementMode == .grouped ? "Split Up" : "Stick Together")
                        }
                        .padding()
                        .background(.thinMaterial, in: Capsule())
                        .disabled(viewModel.partyMovementMode == .solo && !viewModel.canRegroup())
                        .opacity(viewModel.partyMovementMode == .solo && !viewModel.canRegroup() ? 0.6 : 1)

                        Spacer()

                        Button {
                            showingStatusSheet.toggle()
                        } label: {
                            Image(systemName: "person.3.fill")
                            Text("Status")
                        }
                        .padding()
                        .background(.thinMaterial, in: Capsule())

                        Spacer()

                        Button {
                            showingMap.toggle()
                        } label: {
                            Image(systemName: "map")
                            Text("Map")
                        }
                        .padding()
                        .background(.thinMaterial, in: Capsule())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
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
                Color.black.opacity(0.75).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                    Text("The tomb claims another party.")
                        .foregroundColor(.white)
                    Button("Try Again") {
                        viewModel.startNewRun()
                        selectedCharacterID = viewModel.gameState.party.first?.id
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
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
