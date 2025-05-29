import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var pendingAction: ActionOption?
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
            viewModel.move(to: connection)
            withAnimation(.linear(duration: 0.3)) {
                doorProgress = 0
            }
        }
    }


    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(
                    title: viewModel.currentNode?.name ?? "Unknown Location",
                    characters: viewModel.gameState.party,
                    selectedCharacterID: $selectedCharacterID
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        if let node = viewModel.currentNode {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(node.interactables, id: \.id) { interactable in
                                    InteractableCardView(interactable: interactable) { action in
                                        if selectedCharacter != nil {
                                            pendingAction = action
                                        }
                                    }
                                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                                }

                                Divider()

                                NodeConnectionsView(currentNode: viewModel.currentNode) { connection in
                                    performTransition(to: connection)
                                }
                            }
                            .id(node.id)
                            .transition(.opacity)
                        } else {
                            Text("Loading dungeon...")
                        }
                    }
                    .padding()
                    .animation(.default, value: viewModel.currentNode?.id)
                }
            }
            .disabled(viewModel.gameState.status == .gameOver)
            .sheet(item: $pendingAction) { action in
                if let character = selectedCharacter {
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    DiceRollView(viewModel: viewModel,
                                 action: action,
                                 character: character,
                                 clockID: clockID)
                } else {
                    Text("No action selected")
                }
            }

            SlidingDoor(progress: doorProgress)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingStatusSheet.toggle()
                    } label: {
                        Image(systemName: "person.3.fill")
                        Text("Party")
                    }
                    .padding()
                    .background(.thinMaterial, in: Capsule())
                    .padding()
                }
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
                        Image("texture_stone_door")
                            .resizable(resizingMode: .tile)
                    )
                    .frame(width: geo.size.width * progress)
                Spacer(minLength: 0)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
