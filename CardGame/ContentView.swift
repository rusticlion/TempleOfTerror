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
#if DEBUG
    @State private var showingDebugTools = false
#endif
    @Environment(\.scenePhase) private var scenePhase

    init(scenario: String = "tomb", partyPlan: PartyBuildPlan? = nil) {
        // Start a new game using the provided scenario
        let vm = GameViewModel(startNewWithScenario: scenario, partyPlan: partyPlan)
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

    private var characterLocationNames: [UUID: String] {
        Dictionary(
            uniqueKeysWithValues: viewModel.gameState.party.compactMap { character in
                guard let locationName = viewModel.getNodeName(for: character.id) else { return nil }
                return (character.id, locationName)
            }
        )
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

    private var movementButtonTitle: String {
        viewModel.partyMovementMode == .grouped ? "Split Up" : "Regroup"
    }

    private var showingPendingResolution: Binding<Bool> {
        Binding(
            get: { pendingRoll == nil && viewModel.gameState.pendingResolution != nil },
            set: { isPresented in
                if !isPresented,
                   pendingRoll == nil,
                   viewModel.gameState.pendingResolution?.isComplete == true {
                    viewModel.clearPendingResolution()
                }
            }
        )
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
                                let items = viewModel.visibleInteractables(for: selectedCharacterID)
                                let isEngaged = viewModel.isCharacterEngaged(selectedCharacterID)

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

                                if isEngaged {
                                    Text("Threat in play. You can't leave this node until the danger here is dealt with.")
                                        .font(Theme.systemFont(size: 12, weight: .medium))
                                        .foregroundColor(Theme.danger)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Theme.danger.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Theme.danger.opacity(0.25), lineWidth: 1)
                                        )
                                } else {
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
                        CharacterSheetView(
                            character: character,
                            locationName: viewModel.getNodeName(for: character.id),
                            harmFamilies: viewModel.harmFamilies
                        )
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

                        PartyMovementStatusView(
                            viewModel: viewModel,
                            selectedCharacterID: selectedCharacterID,
                            characterLocationNames: characterLocationNames
                        )

                        CharacterSelectorView(characters: viewModel.gameState.party,
                                              selectedCharacterID: $selectedCharacterID,
                                              movementMode: viewModel.partyMovementMode,
                                              locationNames: characterLocationNames)
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

                    HStack(spacing: 10) {
                        Button {
                            viewModel.toggleMovementMode()
                        } label: {
                            BottomToolbarButtonLabel(
                                title: movementButtonTitle,
                                systemImage: "arrow.triangle.branch"
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .disabled(viewModel.partyMovementMode == .solo && !viewModel.canRegroup())
                        .opacity(viewModel.partyMovementMode == .solo && !viewModel.canRegroup() ? 0.6 : 1)
                        .accessibilityIdentifier("movementModeButton")

                        Button {
                            showingStatusSheet.toggle()
                        } label: {
                            BottomToolbarButtonLabel(
                                title: "Status",
                                systemImage: "person.3.fill"
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("statusButton")

                        Button {
                            showingMap.toggle()
                        } label: {
                            BottomToolbarButtonLabel(
                                title: "Map",
                                systemImage: "map"
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("mapButton")
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
            .sheet(isPresented: showingPendingResolution) {
                PendingResolutionView(viewModel: viewModel)
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
#if DEBUG
        .sheet(isPresented: $showingDebugTools) {
            DebugToolsView(
                viewModel: viewModel,
                selectedCharacterID: $selectedCharacterID
            )
            .presentationDetents([.large])
        }
#endif
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                viewModel.saveGame()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .automatic) {
#if DEBUG
                Button {
                    showingDebugTools = true
                } label: {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundColor(Theme.parchmentDark)
                }
#else
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundColor(Theme.parchmentDark)
                }
#endif
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private struct BottomToolbarButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .font(Theme.systemFont(size: 14, weight: .semibold))
        .foregroundColor(Theme.parchmentDark)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Theme.leatherLight.opacity(0.5))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Theme.inkFaded.opacity(0.3), lineWidth: 1))
    }
}

struct PendingResolutionView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    private var canDismiss: Bool {
        viewModel.gameState.pendingResolution?.isAwaitingDecision != true
    }

    var body: some View {
        ZStack {
            Theme.dramaticBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                if let rollPresentation = viewModel.gameState.pendingResolution?.rollPresentation {
                    Text(rollPresentation.actionName)
                        .font(Theme.displayFont(size: 24))
                        .foregroundColor(Theme.parchment)

                    Text(rollPresentation.outcome.uppercased())
                        .font(Theme.displayFont(size: 34))
                        .foregroundColor(Theme.gold)

                    Text("Rolled a \(rollPresentation.highestRoll)")
                        .font(Theme.systemFont(size: 12))
                        .foregroundColor(Theme.inkFaded)
                } else {
                    Text("Decision")
                        .font(Theme.displayFont(size: 30))
                        .foregroundColor(Theme.parchment)
                }

                if let character = viewModel.pendingResolutionCharacter() {
                    Text(character.name)
                        .font(Theme.systemFont(size: 12, weight: .semibold))
                        .foregroundColor(Theme.inkFaded)
                }

                ResolutionNarrativeView(text: viewModel.pendingResolutionText())

                if viewModel.gameState.pendingResolution?.isAwaitingDecision == true {
                    ResolutionDecisionCard(viewModel: viewModel)
                }

                Button("Done") {
                    viewModel.clearPendingResolution()
                    dismiss()
                }
                .font(Theme.displayFont(size: 16, weight: .semibold))
                .foregroundColor(Theme.parchment)
                .padding(.horizontal, 36)
                .padding(.vertical, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)
                )
                .disabled(!canDismiss)
                .opacity(canDismiss ? 1 : 0.45)
            }
            .padding(30)
        }
        .interactiveDismissDisabled(!canDismiss)
    }
}

struct PartyMovementStatusView: View {
    @ObservedObject var viewModel: GameViewModel
    let selectedCharacterID: UUID?
    let characterLocationNames: [UUID: String]

    private struct LocationGroup: Identifiable {
        let id: String
        let name: String
        let characters: [Character]
    }

    private var activeCharacters: [Character] {
        viewModel.gameState.party.filter { !$0.isDefeated }
    }

    private var locationGroups: [LocationGroup] {
        let grouped = Dictionary(grouping: activeCharacters) { character in
            characterLocationNames[character.id] ?? "Unknown Location"
        }

        return grouped
            .map { key, value in
                LocationGroup(
                    id: key,
                    name: key,
                    characters: value.sorted { $0.name < $1.name }
                )
            }
            .sorted { lhs, rhs in lhs.name < rhs.name }
    }

    private var title: String {
        switch viewModel.partyMovementMode {
        case .grouped:
            return "Moving Together"
        case .solo where viewModel.isPartyActuallySplit():
            return "Split Up"
        case .solo:
            return "Independent Movement"
        }
    }

    private var subtitle: String {
        switch viewModel.partyMovementMode {
        case .grouped:
            return "All active explorers travel as one party."
        case .solo where viewModel.isPartyActuallySplit():
            return "The party is spread across \(locationGroups.count) rooms."
        case .solo:
            return "Pick one explorer to move without dragging the rest along."
        }
    }

    private var selectedCharacterName: String? {
        guard let selectedCharacterID else { return nil }
        return activeCharacters.first(where: { $0.id == selectedCharacterID })?.name
    }

    private var statusIcon: String {
        switch viewModel.partyMovementMode {
        case .grouped:
            return "person.3.fill"
        case .solo where viewModel.isPartyActuallySplit():
            return "arrow.triangle.branch"
        case .solo:
            return "figure.walk.motion"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: statusIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(viewModel.partyMovementMode == .grouped ? Theme.success : Theme.gold)
                    .frame(width: 28, height: 28)
                    .background(Theme.bg.opacity(0.45), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Theme.systemFont(size: 12, weight: .semibold))
                        .foregroundColor(Theme.parchment)
                        .textCase(.uppercase)
                        .tracking(0.7)

                    Text(subtitle)
                        .font(Theme.bodyFont(size: 13))
                        .foregroundColor(Theme.parchmentDark)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                if let selectedCharacterName, viewModel.partyMovementMode == .solo {
                    Text(selectedCharacterName)
                        .font(Theme.systemFont(size: 11, weight: .semibold))
                        .foregroundColor(Theme.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.gold.opacity(0.85), in: Capsule())
                }
            }

            if viewModel.partyMovementMode == .solo {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(locationGroups) { group in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(group.name)
                                    .font(Theme.systemFont(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.parchment)
                                    .lineLimit(1)

                                Text(group.characters.map(\.name).joined(separator: ", "))
                                    .font(Theme.systemFont(size: 10, weight: .medium))
                                    .foregroundColor(Theme.inkFaded)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Theme.bg.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.parchmentDeep.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.leatherLight.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.parchmentDeep.opacity(0.18), lineWidth: 1)
        )
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

#if DEBUG
struct DebugToolsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selectedCharacterID: UUID?
    @Environment(\.dismiss) private var dismiss

    @State private var fixedDiceInput: String = ""
    @State private var selectedNodeID: UUID? = nil
    @State private var moveWholeParty = true
    @State private var selectedGrantCharacterID: UUID? = nil
    @State private var selectedTreasureID: String? = nil
    @State private var flagKey: String = ""
    @State private var counterKey: String = ""
    @State private var counterValue: String = "0"
    @State private var modifierDescription: String = "Debug +1d"
    @State private var modifierBonusDice: String = "1"
    @State private var modifierUses: String = "1"
    @State private var modifierImprovesPosition = false
    @State private var modifierImprovesEffect = false
    @State private var statusMessage: String = ""

    private var nodes: [MapNode] {
        guard let map = viewModel.gameState.dungeon else { return [] }
        return map.nodes.values.sorted { $0.name < $1.name }
    }

    private var activeCharacters: [Character] {
        viewModel.gameState.party.filter { !$0.isDefeated }
    }

    private var availableTreasures: [Treasure] {
        viewModel.availableTreasureTemplates.sorted { $0.name < $1.name }
    }

    private var effectiveTargetCharacterID: UUID? {
        selectedGrantCharacterID ?? selectedCharacterID ?? activeCharacters.first?.id
    }

    private func parseInteger(_ text: String, fallback: Int = 0) -> Int {
        Int(text.trimmingCharacters(in: .whitespacesAndNewlines)) ?? fallback
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dice Override") {
                    Toggle("Enable Fixed Dice Pattern", isOn: $viewModel.debugFixedDiceEnabled)
                    TextField("e.g. 6,5,3", text: $fixedDiceInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Apply Pattern") {
                        if viewModel.setDebugFixedDice(from: fixedDiceInput) {
                            statusMessage = "Fixed dice set to [\(viewModel.debugFixedDiceSummary)]."
                        } else {
                            statusMessage = "Dice pattern must be one or more values between 1 and 6."
                        }
                    }
                    Text("Current: [\(viewModel.debugFixedDiceSummary)]")
                        .font(Theme.systemFont(size: 11))
                        .foregroundColor(Theme.inkFaded)
                }

                Section("Node Jump") {
                    if nodes.isEmpty {
                        Text("No fixed-map nodes are loaded in this run.")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        Picker("Target Node", selection: $selectedNodeID) {
                            ForEach(nodes, id: \.id) { node in
                                Text(node.name).tag(Optional(node.id))
                            }
                        }

                        Toggle("Move Entire Party", isOn: $moveWholeParty)

                        Button("Jump") {
                            guard let targetNodeID = selectedNodeID else { return }
                            if moveWholeParty {
                                if viewModel.debugJumpParty(to: targetNodeID) {
                                    statusMessage = "Moved entire party to target node."
                                } else {
                                    statusMessage = "Failed to move party."
                                }
                            } else if let characterID = selectedCharacterID ?? activeCharacters.first?.id {
                                if viewModel.debugJump(characterID: characterID, to: targetNodeID) {
                                    statusMessage = "Moved selected character to target node."
                                } else {
                                    statusMessage = "Failed to move selected character."
                                }
                            } else {
                                statusMessage = "No active character selected."
                            }
                        }
                    }
                }

                Section("Scenario State") {
                    ForEach(activeCharacters, id: \.id) { character in
                        let nodeName = viewModel.getNodeName(for: character.id) ?? "Unknown"
                        Text("\(character.name): \(nodeName)")
                            .font(Theme.systemFont(size: 12))
                    }

                    if viewModel.gameState.activeClocks.isEmpty {
                        Text("No active clocks.")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        ForEach(viewModel.gameState.activeClocks, id: \.id) { clock in
                            Text("\(clock.name): \(clock.progress)/\(clock.segments)")
                                .font(Theme.systemFont(size: 12))
                        }
                    }
                }

                Section("Flags and Counters") {
                    TextField("Flag ID", text: $flagKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    HStack {
                        Button("Set Flag") {
                            viewModel.debugSetFlag(flagKey, isSet: true)
                            statusMessage = "Flag set."
                        }
                        Button("Clear Flag") {
                            viewModel.debugSetFlag(flagKey, isSet: false)
                            statusMessage = "Flag cleared."
                        }
                    }

                    TextField("Counter ID", text: $counterKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Counter Value", text: $counterValue)
                        .keyboardType(.numberPad)
                    HStack {
                        Button("Set Counter") {
                            viewModel.debugSetCounter(counterKey, value: parseInteger(counterValue))
                            statusMessage = "Counter set."
                        }
                        Button("+1") {
                            viewModel.debugAdjustCounter(counterKey, by: 1)
                            statusMessage = "Counter incremented."
                        }
                        Button("-1") {
                            viewModel.debugAdjustCounter(counterKey, by: -1)
                            statusMessage = "Counter decremented."
                        }
                    }

                    if viewModel.gameState.scenarioFlags.isEmpty {
                        Text("Flags: none")
                            .font(Theme.systemFont(size: 11))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        let sortedFlags = viewModel.gameState.scenarioFlags.keys.sorted()
                        ForEach(sortedFlags, id: \.self) { key in
                            Text("Flag \(key) = \(viewModel.gameState.scenarioFlags[key] == true ? "true" : "false")")
                                .font(Theme.systemFont(size: 11))
                        }
                    }

                    if viewModel.gameState.scenarioCounters.isEmpty {
                        Text("Counters: none")
                            .font(Theme.systemFont(size: 11))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        let sortedCounters = viewModel.gameState.scenarioCounters.keys.sorted()
                        ForEach(sortedCounters, id: \.self) { key in
                            Text("Counter \(key) = \(viewModel.gameState.scenarioCounters[key] ?? 0)")
                                .font(Theme.systemFont(size: 11))
                        }
                    }
                }

                Section("Treasure and Modifier Grants") {
                    if activeCharacters.isEmpty {
                        Text("No active party members available.")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        Picker("Character", selection: $selectedGrantCharacterID) {
                            ForEach(activeCharacters, id: \.id) { character in
                                Text(character.name).tag(Optional(character.id))
                            }
                        }
                    }

                    if availableTreasures.isEmpty {
                        Text("No treasure templates are available for this scenario.")
                            .font(Theme.systemFont(size: 12))
                            .foregroundColor(Theme.inkFaded)
                    } else {
                        Picker("Treasure", selection: $selectedTreasureID) {
                            ForEach(availableTreasures, id: \.id) { treasure in
                                Text(treasure.name).tag(Optional(treasure.id))
                            }
                        }
                        Button("Grant Treasure") {
                            guard let characterID = effectiveTargetCharacterID,
                                  let treasureID = selectedTreasureID else {
                                statusMessage = "Choose a character and treasure first."
                                return
                            }
                            if viewModel.debugGrantTreasure(treasureID, to: characterID) {
                                statusMessage = "Treasure granted."
                            } else {
                                statusMessage = "Treasure grant failed (already owned or missing template)."
                            }
                        }
                    }

                    HStack {
                        Button("+1d") {
                            guard let characterID = effectiveTargetCharacterID else { return }
                            _ = viewModel.debugGrantModifier(
                                to: characterID,
                                bonusDice: 1,
                                uses: 1,
                                description: "Debug +1d"
                            )
                            statusMessage = "Granted +1d modifier."
                        }
                        Button("Pos+") {
                            guard let characterID = effectiveTargetCharacterID else { return }
                            _ = viewModel.debugGrantModifier(
                                to: characterID,
                                improvePosition: true,
                                uses: 1,
                                description: "Debug Position Boost"
                            )
                            statusMessage = "Granted position-boost modifier."
                        }
                        Button("Eff+") {
                            guard let characterID = effectiveTargetCharacterID else { return }
                            _ = viewModel.debugGrantModifier(
                                to: characterID,
                                improveEffect: true,
                                uses: 1,
                                description: "Debug Effect Boost"
                            )
                            statusMessage = "Granted effect-boost modifier."
                        }
                    }

                    TextField("Modifier Description", text: $modifierDescription)
                    TextField("Bonus Dice", text: $modifierBonusDice)
                        .keyboardType(.numberPad)
                    TextField("Uses (0 = unlimited)", text: $modifierUses)
                        .keyboardType(.numberPad)
                    Toggle("Improve Position", isOn: $modifierImprovesPosition)
                    Toggle("Improve Effect", isOn: $modifierImprovesEffect)
                    Button("Grant Custom Modifier") {
                        guard let characterID = effectiveTargetCharacterID else {
                            statusMessage = "Choose a character first."
                            return
                        }
                        let success = viewModel.debugGrantModifier(
                            to: characterID,
                            bonusDice: parseInteger(modifierBonusDice),
                            improvePosition: modifierImprovesPosition,
                            improveEffect: modifierImprovesEffect,
                            uses: parseInteger(modifierUses, fallback: 1),
                            description: modifierDescription
                        )
                        statusMessage = success ? "Custom modifier granted." : "Custom modifier grant failed."
                    }
                }

                if !statusMessage.isEmpty {
                    Section("Last Action") {
                        Text(statusMessage)
                            .font(Theme.systemFont(size: 12))
                    }
                }
            }
            .navigationTitle("Author Tools")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                fixedDiceInput = viewModel.debugFixedDiceSummary
                selectedGrantCharacterID = selectedCharacterID ?? activeCharacters.first?.id
                selectedTreasureID = availableTreasures.first?.id
                if let characterID = selectedCharacterID ?? activeCharacters.first?.id {
                    selectedNodeID = viewModel.gameState.characterLocations[characterID.uuidString]
                } else {
                    selectedNodeID = nodes.first?.id
                }
            }
        }
    }
}
#endif
