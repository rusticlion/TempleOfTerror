import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var pendingAction: ActionOption?
    @State private var pendingInteractableID: String?
    @State private var selectedCharacterID: UUID? // Track selected character
    @State private var showingStatusSheet = false // Controls the party sheet
    @State private var doorProgress: CGFloat = 0 // For sliding door transition

    init() {
        let vm = GameViewModel()
        _viewModel = StateObject(wrappedValue: vm)
        _selectedCharacterID = State(initialValue: vm.gameState.party.first?.id)
    }

    // Helper to retrieve the selected character object
    private var selectedCharacter: Character? {
        viewModel.gameState.party.first { $0.id == selectedCharacterID }
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
                    title: viewModel.getNodeName(for: selectedCharacterID) ?? "Unknown Location",
                    characters: viewModel.gameState.party,
                    selectedCharacterID: $selectedCharacterID
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        if let character = selectedCharacter {
                            CharacterSheetView(character: character)
                            Divider()
                        }

                        if let node = viewModel.node(for: selectedCharacterID) {
                            VStack(alignment: .leading, spacing: 16) {
                                let threats = node.interactables.filter { $0.isThreat }
                                let items = threats.isEmpty ? node.interactables : threats

                                ForEach(items, id: \.id) { interactable in
                                    InteractableCardView(interactable: interactable, selectedCharacter: selectedCharacter) { action in
                                        if selectedCharacter != nil {
                                            pendingAction = action
                                            pendingInteractableID = interactable.id
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
            }
            .disabled(viewModel.gameState.status == .gameOver)
            .sheet(item: $pendingAction) { action in
                if let character = selectedCharacter {
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    DiceRollView(viewModel: viewModel,
                                 action: action,
                                 character: character,
                                 clockID: clockID,
                                 interactableID: pendingInteractableID)
                } else {
                    Text("No action selected")
                }
            }

            SlidingDoor(progress: doorProgress)

            VStack {
                Spacer()
                HStack {
                    Button {
                        viewModel.toggleMovementMode()
                    } label: {
                        Text("Movement: \(viewModel.partyMovementMode == .grouped ? "Grouped" : "Solo")")
                    }
                    .padding()
                    .background(.thinMaterial, in: Capsule())

                    Spacer()

                    Button {
                        showingStatusSheet.toggle()
                    } label: {
                        Image(systemName: "person.3.fill")
                        Text("Party")
                    }
                    .padding()
                    .background(.thinMaterial, in: Capsule())
                }
                .padding()
            }


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
        .ignoresSafeArea(.all, edges: .bottom)
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
