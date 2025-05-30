# Project, Content, and Documentation Structure

## Directory Tree for CardGame
```
CardGame
|____PartyStatusView.swift
|____DiceRollView.swift
|____NodeConnectionsView.swift
|____.DS_Store
|____MainMenuView.swift
|____Persistence.swift
|____StatusSheetView.swift
|____CardGameApp.swift
|____MapView.swift
|____CharacterSelectorView.swift
|____Assets.xcassets
| |____icon_harm_lesser_empty.imageset
| |____|____Contents.json
| |____|____icon_harm_lesser_empty.png
| |____icon_harm_lesser_full.imageset
| |____|____icon_harm_lesser_full.png
| |____|____Contents.json
| |____icon_harm_moderate_full.imageset
| |____|____Contents.json
| |____|____icon_harm_moderate_full.png
| |____vfx_damage_vignette.imageset
| |____|____vfx_damage_vignette.png
| |____|____Contents.json
| |____texture_stone_door.imageset
| |____|____texture_stone_door.png
| |____|____Contents.json
| |____icon_bonus_action.imageset
| |____|____icon_bonus_action.png
| |____|____Contents.json
| |____icon_penalty_action.imageset
| |____|____icon_penalty_action.png
| |____|____Contents.json
| |____icon_harm_moderate_empty.imageset
| |____|____Contents.json
| |____|____icon_harm_moderate_empty.png
| |____AppIcon.appiconset
| |____|____Contents.json
| |____AccentColor.colorset
| |____|____Contents.json
| |____icon_stress_pip_unlit.imageset
| |____|____icon_stress_pip_unlit.png
| |____|____Contents.json
| |____Contents.json
| |____icon_harm_severe_empty.imageset
| |____|____Contents.json
| |____|____icon_harm_severe_empty.png
| |____icon_harm_severe_full.imageset
| |____|____icon_harm_severe_full.png
| |____|____Contents.json
| |____icon_stress_pip_lit.imageset
| |____|____Contents.json
| |____|____icon_stress_pip_lit.png
|____AudioManager.swift
|____DungeonGenerator.swift
|____ClocksView.swift
|____Preview Content
| |____Preview Assets.xcassets
| |____|____Contents.json
|____CardGame.xcdatamodeld
| |____.xccurrentversion
| |____CardGame.xcdatamodel
| |____|____contents
|____ContentLoader.swift
|____HeaderView.swift
|____Models.swift
|____InteractableCardView.swift
|____AssetPlaceholders
| |____icon_harm_severe_full.png
| |____vfx_damage_vignette.png
| |____icon_harm_severe_empty.md
| |____icon_harm_lesser_full.png
| |____icon_harm_lesser_empty.md
| |____icon_stress_pip_unlit.png
| |____icon_bonus_action.md
| |____sfx_ui_pop.md
| |____sfx_dice_shake.md
| |____texture_stone_door.md
| |____icon_harm_moderate_full.md
| |____icon_penalty_action.md
| |____texture_stone_door.png
| |____sfx_dice_land.md
| |____sfx_modifier_consume.md
| |____icon_harm_moderate_full.png
| |____icon_harm_severe_empty.png
| |____icon_harm_moderate_empty.md
| |____vfx_damage_vignette.md
| |____icon_harm_moderate_empty.png
| |____icon_stress_pip_unlit.md
| |____icon_harm_severe_full.md
| |____icon_stress_pip_lit.png
| |____icon_stress_pip_lit.md
| |____icon_harm_lesser_empty.png
| |____icon_harm_lesser_full.md
|____CharacterSheetView.swift
|____GameViewModel.swift
|____ContentView.swift
|____Info.plist
```

## Directory Tree for Content
```
Content
|____treasures.json
|____interactables.json
|____harm_families.json
|____Scenarios
| |____tomb
| |____|____treasures.json
| |____|____interactables.json
| |____|____harm_families.json
| |____|____scenario.json
| |____test_lab
| |____|____treasures.json
| |____|____interactables.json
| |____|____harm_families.json
| |____|____scenario.json
```

## Directory Tree for Docs
```
Docs
|____S6_MechanicalDepth
| |____1-HarmSystemOverhaul.md
| |____3-Treasures.md
| |____2-GeneralPurposeModifiers.md
|____S12_ThreatAndScenarioInfrastructure
| |____4-MainMenuAndScenarioSelect.md
| |____1-ImplementThreatInteractables.md
| |____2-AddDungeonMap.md
| |____5-SaveAndLoadSystem.md
| |____3-ModularizeScenarioLoading.md
|____S11_UIClarity
| |____2-IntegrateModiferAndPenaltyInfoInDiceRollView.md
| |____1-EnhanceCharacterStatDisplay.md
| |____3-FeedbackForModifierConsumption.md
|____PRD.md
|____S10_ContentPipelineAndGenerationPolish
| |____2-EnhanceDungeonGenerator.md
| |____1-ExpandPlaceholderContentJsons.md
| |____Side-ModelAndLoaderTweaks.md
|____S9_GameJuice
| |____1-AmbientWorld.md
| |____3-ThematicStatusVisualization.md
| |____2-HighStakesDiceRolls.md
|____S13_ExpressiveActionsAndTags
| |____1-ImplementFreeActions.md
| |____2-AddTagSystem.md
| |____3-DocumentationAndExamples.md
|____S4_FullGameLoop
| |____1-DynamicActionConsequences.md
| |____3-ImplementRoguelikeRuns.md
| |____2-ImproveUIFeedback.md
|____S1_CoreSlice
| |____3-BasicUI.md
| |____1-ProjectSetupAndCoreDataModels.md
| |____2-ViewModelGameLogicEngine.md
|____S7_AdvancedFitDMechanics
| |____2-ImplementPushYourselfMechanic.md
| |____3-HarmEscalation.md
| |____1-HarmFamiliesAndSlots.md
|____S5_VisualPolishAndRefactor
| |____2-ReorganizeStatusViewsIntoPartySheet.md
| |____3-SubtleAnimationsAndTransitions.md
| |____1-IsolatedHeader.md
|____S2_ImproveDynamicism
| |____1-DynamicCharacterSelection.md
| |____3-DesignDedicatedDiceRollView.md
| |____2-CreateReusableInteractableCardView.md
|____S8_ContentAndGenerationArchitecture
| |____2-ArchitectDungeonGenerator.md
| |____1-ExternalizeContentToJson.md
|____S3_DungeonCrawl
| |____1-DungeonModel.md
| |____2-GenerateAndManageDungeonState.md
| |____3-BuildDungeonViews.md
```

## File Contents

### `CardGame/PartyStatusView.swift`

```

import SwiftUI

struct PartyStatusView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Party Status")
                .font(.headline)

            ForEach(viewModel.gameState.party) { character in
                let loc: String? = {
                    if viewModel.partyMovementMode == .solo && viewModel.isPartyActuallySplit() {
                        return viewModel.getNodeName(for: character.id)
                    }
                    return nil
                }()
                CharacterSheetView(character: character, locationName: loc)
            }
        }
    }
}

struct PartyStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PartyStatusView(viewModel: GameViewModel())
    }
}

```

### `CardGame/DiceRollView.swift`

```

import SwiftUI

struct DiceRollResult {
    let highestRoll: Int
    let outcome: String
    let consequences: String
}

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?
    let interactableID: String?

    @State private var diceValues: [Int] = []
    @State private var diceOffsets: [CGSize] = []
    @State private var diceRotations: [Double] = []
    @State private var result: DiceRollResult? = nil
    @State private var projection: RollProjectionDetails? = nil
    @State private var isRolling = false
    @State private var extraDiceFromPush = 0
    @State private var hasPushed = false
    @State private var highlightIndex: Int? = nil
    @State private var popScale: CGFloat = 1.0
    @State private var fadeOthers = false
    @State private var showOutcome = false
    @State private var showVignette = false

    @State private var shakeTimer: Timer? = nil

    @Environment(\.dismiss) var dismiss

    private func startShaking() {
        showVignette = true
        AudioManager.shared.play(sound: "sfx_dice_shake.wav")
        shakeTimer?.invalidate()
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in 0..<diceOffsets.count {
                diceOffsets[i] = CGSize(width: Double.random(in: -6...6), height: Double.random(in: -6...6))
                diceRotations[i] = Double.random(in: -20...20)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            stopShaking()
        }
    }

    private func stopShaking() {
        shakeTimer?.invalidate()
        shakeTimer = nil
        for i in 0..<diceOffsets.count {
            diceOffsets[i] = .zero
            diceRotations[i] = 0
        }
        showVignette = false
        isRolling = false
        AudioManager.shared.play(sound: "sfx_dice_land.wav")
        let rollResult = viewModel.performAction(for: action, with: character, interactableID: interactableID)
        self.result = rollResult
        let totalDice = diceValues.count
        highlightIndex = Int.random(in: 0..<totalDice)
        diceValues = (0..<totalDice).map { idx in
            if idx == highlightIndex { return rollResult.highestRoll }
            return Int.random(in: 1...max(1, min(rollResult.highestRoll, 5)))
        }
        fadeOthers = true
        popDie()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            showOutcome = true
        }
    }

    private func popDie() {
        AudioManager.shared.play(sound: "sfx_ui_pop.wav")
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            popScale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                popScale = 1.0
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(character.name).font(.title)
            Text("is attempting to...").font(.subheadline).foregroundColor(.secondary)
            Text(action.name).font(.title2).bold()
            Text("\(action.actionType): \(character.actions[action.actionType] ?? 0)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            if let result = result, showOutcome {
                VStack {
                    Text(result.outcome)
                        .font(.largeTitle)
                        .bold()
                        .transition(.scale.combined(with: .opacity))
                    Text("Rolled a \(result.highestRoll)").font(.title3)
                    Text(result.consequences).padding()
                }
            } else if let proj = projection {
                VStack(spacing: 4) {
                    Text("Dice: \(proj.finalDiceCount)d6")
                        .font(.headline)
                    Text("Position: \(proj.finalPosition.rawValue.capitalized), Effect: \(proj.finalEffect.rawValue.capitalized)")
                        .font(.subheadline)
                    ForEach(proj.notes, id: \.self) { note in
                        Text(note)
                            .font(.caption)
                            .foregroundColor(note.contains("-") || note.contains("Cannot") ? .red : .blue)
                    }
                }
            }

            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    let totalDice = diceValues.count
                    ForEach(0..<totalDice, id: \.self) { index in
                        Image(systemName: "die.face.\(diceValues[index]).fill")
                            .font(.largeTitle)
                            .foregroundColor(index >= (totalDice - extraDiceFromPush) ? .cyan : .primary)
                            .rotationEffect(.degrees(diceRotations.indices.contains(index) ? diceRotations[index] : 0))
                            .offset(diceOffsets.indices.contains(index) ? diceOffsets[index] : .zero)
                            .opacity(fadeOthers && index != highlightIndex ? 0.5 : 1.0)
                            .scaleEffect(index == highlightIndex ? popScale : 1.0)
                            .shadow(color: index == highlightIndex ? .cyan : .clear, radius: index == highlightIndex ? 10 : 0)
                    }
                }

                if result == nil {
                    Button {
                        viewModel.pushYourself(forCharacter: character)
                        extraDiceFromPush += 1
                        diceValues.append(1)
                        diceOffsets.append(.zero)
                        diceRotations.append(0)
                        hasPushed = true
                    } label: {
                        Text("Push Yourself (+1d for 2 Stress)")
                    }
                    .disabled(hasPushed)
                    .buttonStyle(.bordered)
                }
            }

            Spacer()

            if result == nil {
                Button("Roll the Dice!") {
                    isRolling = true
                    startShaking()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(30)
        .onAppear {
            let proj = viewModel.calculateProjection(for: action, with: character)
            self.projection = proj
            let diceCount = max(proj.finalDiceCount, 1)
            self.diceValues = Array(repeating: 1, count: diceCount)
            self.diceOffsets = Array(repeating: .zero, count: diceCount)
            self.diceRotations = Array(repeating: 0, count: diceCount)
        }
        .overlay(
            Group {
                if showVignette {
                    Image("vfx_damage_vignette")
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                        .ignoresSafeArea()
                }
            }
        )
    }
}


```

### `CardGame/NodeConnectionsView.swift`

```

import SwiftUI

struct NodeConnectionsView: View {
    var currentNode: MapNode?
    let onMove: (NodeConnection) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Paths from this room")
                .font(.headline)
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

```

### `CardGame/MainMenuView.swift`

```

import SwiftUI

struct MainMenuView: View {
    @State private var showingScenarioSelect = false
    @State private var availableScenarios: [ScenarioManifest] = ContentLoader.availableScenarios()
    @State private var path = NavigationPath()
    @State private var continueVM: GameViewModel?
    @State private var continueActive = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                Text("Temple of Terror")
                    .font(.largeTitle)
                    .bold()

                Button("Start New Game") {
                    if let scenario = availableScenarios.first(where: { $0.id == "tomb" }) ?? availableScenarios.first {
                        path.append(scenario)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Continue") {
                    let vm = GameViewModel()
                    if vm.loadGame() {
                        continueVM = vm
                        continueActive = true
                    }
                }
                .disabled(!GameViewModel.saveExists)

                Button("Scenario Select") {
                    showingScenarioSelect = true
                }
                .buttonStyle(.bordered)

                Button("Settings") { }
                    .disabled(true)
            }
            .padding()
            .navigationDestination(for: ScenarioManifest.self) { manifest in
                ContentView(scenario: manifest.id)
            }
            NavigationLink("", isActive: $continueActive) {
                if let vm = continueVM {
                    ContentView(viewModel: vm)
                }
            }
            .hidden()
            .sheet(isPresented: $showingScenarioSelect) {
                ScenarioSelectView(available: availableScenarios) { manifest in
                    path.append(manifest)
                    showingScenarioSelect = false
                }
            }
        }
    }
}

private struct ScenarioSelectView: View {
    var available: [ScenarioManifest]
    var onSelect: (ScenarioManifest) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(available, id: \.id) { scenario in
                VStack(alignment: .leading) {
                    Text(scenario.title).font(.headline)
                    Text(scenario.description).font(.subheadline)
                }
                .onTapGesture {
                    onSelect(scenario)
                    dismiss()
                }
            }
            .navigationTitle("Scenarios")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

```

### `CardGame/Persistence.swift`

```

//
//  Persistence.swift
//  CardGame
//
//  Created by Russell Leon Bates IV on 5/28/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CardGame")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

```

### `CardGame/StatusSheetView.swift`

```

import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            PartyStatusView(viewModel: viewModel)
            Divider()
            ClocksView(viewModel: viewModel)
            Spacer()
        }
        .padding()
    }
}

struct StatusSheetView_Previews: PreviewProvider {
    static var previews: some View {
        StatusSheetView(viewModel: GameViewModel())
    }
}

```

### `CardGame/CardGameApp.swift`

```

import SwiftUI

@main
struct CardSwipeDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

```

### `CardGame/MapView.swift`

```

import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: GameViewModel

    private func orderedNodes(from map: DungeonMap) -> [MapNode] {
        var result: [MapNode] = []
        var queue: [UUID] = [map.startingNodeID]
        var visited: Set<UUID> = []
        while let id = queue.first {
            queue.removeFirst()
            guard visited.insert(id).inserted else { continue }
            if let node = map.nodes[id.uuidString] {
                result.append(node)
                queue.append(contentsOf: node.connections.map { $0.toNodeID })
            }
        }
        return result
    }

    private func isCurrentLocation(nodeID: UUID) -> Bool {
        viewModel.gameState.characterLocations.values.contains(nodeID)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if let map = viewModel.gameState.dungeon {
                    let nodes = orderedNodes(from: map)
                    let spacing = geo.size.width / CGFloat(max(nodes.count, 1) + 1)
                    ZStack {
                        ForEach(Array(nodes.enumerated()), id: \.1.id) { index, node in
                            let pos = CGPoint(x: spacing * CGFloat(index + 1), y: geo.size.height / 2)
                            ForEach(node.connections, id: \.toNodeID) { conn in
                                if let targetIdx = nodes.firstIndex(where: { $0.id == conn.toNodeID }) {
                                    let target = CGPoint(x: spacing * CGFloat(targetIdx + 1), y: geo.size.height / 2)
                                    Path { path in
                                        path.move(to: pos)
                                        path.addLine(to: target)
                                    }
                                    .stroke(Color.gray, lineWidth: 2)
                                    .zIndex(0) // ensure connectors are beneath nodes
                                }
                            }
                        }
                        ForEach(Array(nodes.enumerated()), id: \.1.id) { index, node in
                            let pos = CGPoint(x: spacing * CGFloat(index + 1), y: geo.size.height / 2)
                            Circle()
                                .fill(node.isDiscovered ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .position(pos)
                                .overlay(
                                    Circle()
                                        .stroke(Color.green, lineWidth: 3)
                                        .opacity(isCurrentLocation(nodeID: node.id) ? 1 : 0)
                                        .frame(width: 36, height: 36)
                                        .position(pos)
                                )
                                .zIndex(1) // draw nodes above connectors
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No Map")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .navigationTitle("Dungeon Map")
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: GameViewModel())
    }
}

```

### `CardGame/CharacterSelectorView.swift`

```

import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Character")
                .font(.headline)
            Picker("Select Character", selection: $selectedCharacterID) {
                ForEach(characters) { character in
                    Text(character.name).tag(character.id as UUID?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct CharacterSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSelectorView(characters: [
            Character(id: UUID(), name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3]),
            Character(id: UUID(), name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Wreck": 2])
        ], selectedCharacterID: .constant(nil))
    }
}

```

### `CardGame/AudioManager.swift`

```

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?

    func play(sound: String, loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: nil) else {
            print("Missing sound: \(sound)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            if loop {
                player?.numberOfLoops = -1
            }
            player?.play()
        } catch {
            print("Failed to play \(sound): \(error)")
        }
    }

    func stop() {
        player?.stop()
    }
}

```

### `CardGame/DungeonGenerator.swift`

```

import Foundation

class DungeonGenerator {
    private let content: ContentLoader
    private let clockTemplates: [GameClock] = [
        GameClock(name: "Shifting Walls", segments: 4, progress: 0),
        GameClock(name: "Ancient Machinery Grinds", segments: 6, progress: 0),
        GameClock(name: "Torchlight Fading", segments: 4, progress: 0),
        GameClock(name: "Unearthly Wailing", segments: 6, progress: 0)
    ]

    init(content: ContentLoader = .shared) {
        self.content = content
    }

    func generate(level: Int) -> (DungeonMap, [GameClock]) {
        var nodes: [String: MapNode] = [:]
        let nodeCount = 5 + level // Simple scaling

        var previousNode: MapNode? = nil
        var nodeIDs: [UUID] = []
        var lockedConnection: (from: UUID, to: UUID)? = nil

        let themes = ["antechamber", "corridor", "trap_chamber", "shrine"]

        let soundProfiles = ["cave_drips", "chasm_wind", "silent_tomb"]

        for i in 0..<nodeCount {
            var connections: [NodeConnection] = []
            if let prev = previousNode {
                connections.append(NodeConnection(toNodeID: prev.id, description: "Go back"))
            }

            let theme = themes.randomElement()

            var newNode = MapNode(
                id: UUID(),
                name: "Forgotten Antechamber \(i + 1)",
                soundProfile: soundProfiles.randomElement() ?? "silent_tomb",
                interactables: [],
                connections: connections,
                theme: theme
            )
            nodes[newNode.id.uuidString] = newNode
            nodeIDs.append(newNode.id)

            if let prev = previousNode {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                let connection = NodeConnection(toNodeID: newNode.id, description: desc)
                nodes[prev.id.uuidString]?.connections.append(connection)
            }
            previousNode = newNode
        }

        // Choose a single connection along the main path to lock
        if nodeIDs.count > 2 {
            let lockIndex = Int.random(in: 1..<(nodeIDs.count - 1))
            let fromID = nodeIDs[lockIndex]
            let toID = nodeIDs[lockIndex + 1]
            if let idx = nodes[fromID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toID }) {
                nodes[fromID.uuidString]?.connections[idx].isUnlocked = false
                lockedConnection = (from: fromID, to: toID)
            }
        }

        for id in nodeIDs {
            if var node = nodes[id.uuidString] {
                let number = Int.random(in: 1...2)
                for _ in 0..<number {
                    if let template = content.interactableTemplates.randomElement() {
                        node.interactables.append(template)
                    }
                }
                nodes[id.uuidString] = node
            }
        }

        if let lock = lockedConnection {
            let lever = Interactable(
                id: "lever_room_\(lock.from.uuidString)",
                title: "Rusty Lever",
                description: "It looks like it controls a nearby mechanism.",
                availableActions: [
                    ActionOption(
                        name: "Pull the Lever",
                        actionType: "Tinker",
                        position: .risky,
                        effect: .standard,
                        outcomes: [
                            .success: [
                                .unlockConnection(fromNodeID: lock.from, toNodeID: lock.to),
                                .removeSelfInteractable
                            ]
                        ]
                    )
                ]
            )
            nodes[lock.from.uuidString]?.interactables.append(lever)
        }

        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID.uuidString]?.isDiscovered = true

        let clockCount = Int.random(in: 1...2)
        let clocks = Array(clockTemplates.shuffled().prefix(clockCount))

        return (DungeonMap(nodes: nodes, startingNodeID: startingNodeID), clocks)
    }
}

```

### `CardGame/ClocksView.swift`

```

import SwiftUI

struct ClocksView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Clocks")
                .font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.gameState.activeClocks) { clock in
                        GraphicalClockView(clock: clock)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

struct GraphicalClockView: View {
    let clock: GameClock

    var body: some View {
        VStack {
            Text(clock.name)
                .font(.caption)
            ZStack {
                Circle().stroke(lineWidth: 10).opacity(0.3)
                Circle()
                    .trim(from: 0.0,
                          to: min(CGFloat(clock.progress) / CGFloat(clock.segments), 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: 270.0))
                Text("\(clock.progress)/\(clock.segments)")
            }
            .frame(width: 60, height: 60)
        }
    }
}

struct ClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ClocksView(viewModel: GameViewModel())
    }
}

```

### `CardGame/Preview Content/Preview Assets.xcassets/Contents.json`

```

{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

```

### `CardGame/CardGame.xcdatamodeld/.xccurrentversion`

```

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>_XCCurrentVersionName</key>
	<string>CardGame.xcdatamodel</string>
</dict>
</plist>

```

### `CardGame/CardGame.xcdatamodeld/CardGame.xcdatamodel/contents`

```

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="1" systemVersion="11A491" minimumToolsVersion="Automatic" sourceLanguage="Swift" usedWithCloudKit="true" userDefinedModelVersionIdentifier="">
    <entity name="Item" representedClassName="Item" syncable="YES" codeGenerationType="class">
        <attribute name="timestamp" optional="YES" attributeType="Date" usesScalarValueType="NO"/>
    </entity>
    <elements>
        <element name="Item" positionX="-63" positionY="-18" width="128" height="44"/>
    </elements>
</model>
```

### `CardGame/ContentLoader.swift`

```

import Foundation

/// Basic information about a scenario.
struct ScenarioManifest: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var entryNode: String?
}

class ContentLoader {
    /// Shared loader using the default scenario ("tomb"). This can be
    /// reassigned when the player selects a different scenario from the
    /// main menu.
    static var shared = ContentLoader()

    let scenarioName: String
    let scenarioManifest: ScenarioManifest?
    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let harmFamilyDict: [String: HarmFamily]
    let treasureTemplates: [Treasure]

    /// Initialize a loader for a specific scenario directory.
    init(scenario: String = "tomb") {
        self.scenarioName = scenario
        self.scenarioManifest = Self.loadManifest(for: scenario)
        self.interactableTemplates = Self.load("interactables.json", for: scenario)
        self.harmFamilies = Self.load("harm_families.json", for: scenario)
        self.harmFamilyDict = Dictionary(uniqueKeysWithValues: harmFamilies.map { ($0.id, $0) })
        self.treasureTemplates = Self.load("treasures.json", for: scenario)
    }

    private static func url(for filename: String, scenario: String) -> URL? {
        if let url = Bundle.main.url(forResource: filename,
                                     withExtension: nil,
                                     subdirectory: "Content/Scenarios/\(scenario)") {
            return url
        }
        return Bundle.main.url(forResource: filename,
                               withExtension: nil,
                               subdirectory: "Content")
    }

    private static func loadManifest(for scenario: String) -> ScenarioManifest? {
        guard let url = url(for: "scenario.json", scenario: scenario) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ScenarioManifest.self, from: data)
        } catch {
            print("Failed to decode scenario.json for \(scenario): \(error)")
            return nil
        }
    }

    /// Retrieve all scenario manifests packaged with the app.
    static func availableScenarios() -> [ScenarioManifest] {
        guard let baseURL = Bundle.main.resourceURL?.appendingPathComponent("Content/Scenarios") else {
            return []
        }
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return []
        }
        var manifests: [ScenarioManifest] = []
        for dir in contents where dir.hasDirectoryPath {
            let name = dir.lastPathComponent
            if let url = Bundle.main.url(forResource: "scenario.json", withExtension: nil, subdirectory: "Content/Scenarios/\(name)"),
               let data = try? Data(contentsOf: url),
               let manifest = try? JSONDecoder().decode(ScenarioManifest.self, from: data) {
                manifests.append(manifest)
            }
        }
        return manifests.sorted { $0.title < $1.title }
    }

    private static func load<T: Decodable>(_ filename: String, for scenario: String) -> [T] {
        guard let url = url(for: filename, scenario: scenario) else {
            print("Failed to locate \(filename) for scenario \(scenario)")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            if let array = try? decoder.decode([T].self, from: data) {
                return array
            } else if let dict = try? decoder.decode([String: [T]].self, from: data) {
                return dict.flatMap { $0.value }
            } else {
                print("Failed to decode \(filename): unexpected format")
                return []
            }
        } catch {
            print("Failed to decode \(filename): \(error)")
            return []
        }
    }
}

```

### `CardGame/HeaderView.swift`

```

import SwiftUI

struct HeaderView: View {
    let title: String
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            CharacterSelectorView(characters: characters,
                                  selectedCharacterID: $selectedCharacterID)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            title: "Preview Location",
            characters: GameViewModel().gameState.party,
            selectedCharacterID: .constant(nil)
        )
    }
}

```

### `CardGame/Models.swift`

```

import Foundation

enum GameStatus: String, Codable {
    case playing
    case gameOver
}

struct GameState: Codable {
    /// Identifier for the scenario that generated this run. Used when loading
    /// to reinitialize the `ContentLoader` with the correct data bundle.
    var scenarioName: String = "tomb"

    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location (legacy)
    // Use String keys for JSON compatibility
    var characterLocations: [String: UUID] = [:] // Individual character locations
    var status: GameStatus = .playing
    // ... other global state can be added later
}

/// A general-purpose modifier that can adjust action rolls.
struct Modifier: Codable {
    var bonusDice: Int = 0
    var improvePosition: Bool = false
    var improveEffect: Bool = false
    var applicableToAction: String? = nil
    var uses: Int = 1
    var description: String

    enum CodingKeys: String, CodingKey {
        case bonusDice, improvePosition, improveEffect, applicableToAction, uses, description
    }

    init(bonusDice: Int = 0,
         improvePosition: Bool = false,
         improveEffect: Bool = false,
         applicableToAction: String? = nil,
         uses: Int = 1,
         description: String) {
        self.bonusDice = bonusDice
        self.improvePosition = improvePosition
        self.improveEffect = improveEffect
        self.applicableToAction = applicableToAction
        self.uses = uses
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bonusDice = try container.decodeIfPresent(Int.self, forKey: .bonusDice) ?? 0
        improvePosition = try container.decodeIfPresent(Bool.self, forKey: .improvePosition) ?? false
        improveEffect = try container.decodeIfPresent(Bool.self, forKey: .improveEffect) ?? false
        applicableToAction = try container.decodeIfPresent(String.self, forKey: .applicableToAction)
        uses = try container.decodeIfPresent(Int.self, forKey: .uses) ?? 1
        description = try container.decode(String.self, forKey: .description)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bonusDice, forKey: .bonusDice)
        try container.encode(improvePosition, forKey: .improvePosition)
        try container.encode(improveEffect, forKey: .improveEffect)
        try container.encodeIfPresent(applicableToAction, forKey: .applicableToAction)
        try container.encode(uses, forKey: .uses)
        try container.encode(description, forKey: .description)
    }
}

/// A collectible treasure that grants a modifier when acquired.
struct Treasure: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var grantedModifier: Modifier
}

struct Character: Identifiable, Codable {
    let id: UUID
    var name: String
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
}

/// Defines a single tier of a harm family.
struct HarmTier: Codable {
    var description: String
    var penalty: Penalty? // Penalty is optional for the "Fatal" tier
}

/// Defines a full "family" of related harms, from minor to fatal.
struct HarmFamily: Codable, Identifiable {
    let id: String // e.g., "head_trauma", "leg_injury"
    var lesser: HarmTier
    var moderate: HarmTier
    var severe: HarmTier
    var fatal: HarmTier // The "game over" description
}

/// The mechanical penalty imposed by a HarmTier.
enum Penalty: Codable {
    case reduceEffect               // All actions are one effect level lower.
    case increaseStressCost(amount: Int) // Stress costs are increased.
    case actionPenalty(actionType: String) // Specific action suffers –1 die.
    case banAction(actionType: String) // An action is impossible without effort

    private enum CodingKeys: String, CodingKey {
        case type, amount, actionType
    }

    private enum Kind: String, Codable {
        case reduceEffect
        case increaseStressCost
        case actionPenalty
        case banAction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .reduceEffect:
            self = .reduceEffect
        case .increaseStressCost:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .increaseStressCost(amount: amount)
        case .actionPenalty:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .actionPenalty(actionType: action)
        case .banAction:
            let action = try container.decode(String.self, forKey: .actionType)
            self = .banAction(actionType: action)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reduceEffect:
            try container.encode(Kind.reduceEffect, forKey: .type)
        case .increaseStressCost(let amount):
            try container.encode(Kind.increaseStressCost, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .actionPenalty(let action):
            try container.encode(Kind.actionPenalty, forKey: .type)
            try container.encode(action, forKey: .actionType)
        case .banAction(let action):
            try container.encode(Kind.banAction, forKey: .type)
            try container.encode(action, forKey: .actionType)
        }
    }
}

/// HarmState now tracks detailed conditions rather than simple strings.
struct HarmState: Codable {
    // We store the family ID along with the specific description.
    var lesser: [(familyId: String, description: String)] = []
    var moderate: [(familyId: String, description: String)] = []
    var severe: [(familyId: String, description: String)] = []

    static let lesserSlots = 2
    static let moderateSlots = 2
    static let severeSlots = 1

    private struct Entry: Codable {
        var familyId: String
        var description: String
    }

    private enum CodingKeys: String, CodingKey {
        case lesser, moderate, severe
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lesserEntries = try container.decodeIfPresent([Entry].self, forKey: .lesser) ?? []
        let moderateEntries = try container.decodeIfPresent([Entry].self, forKey: .moderate) ?? []
        let severeEntries = try container.decodeIfPresent([Entry].self, forKey: .severe) ?? []
        self.lesser = lesserEntries.map { ($0.familyId, $0.description) }
        self.moderate = moderateEntries.map { ($0.familyId, $0.description) }
        self.severe = severeEntries.map { ($0.familyId, $0.description) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lesser.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .lesser)
        try container.encode(moderate.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .moderate)
        try container.encode(severe.map { Entry(familyId: $0.familyId, description: $0.description) }, forKey: .severe)
    }
}

/// Central catalog of all harm families available in the game.
/// This dictionary is populated from the JSON content loaded by `ContentLoader`.
struct HarmLibrary {
    /// Access the harm families for the currently loaded scenario.
    static var families: [String: HarmFamily] {
        return ContentLoader.shared.harmFamilyDict
    }
}

struct GameClock: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
}

// Models for the interactable itself
struct Interactable: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var availableActions: [ActionOption]
    var isThreat: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions, isThreat
    }

    init(id: String,
         title: String,
         description: String,
         availableActions: [ActionOption],
         isThreat: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
        self.isThreat = isThreat
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
        isThreat = try container.decodeIfPresent(Bool.self, forKey: .isThreat) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(availableActions, forKey: .availableActions)
        if isThreat {
            try container.encode(isThreat, forKey: .isThreat)
        }
    }
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    var isGroupAction: Bool = false
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, isGroupAction, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         isGroupAction: Bool = false,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.isGroupAction = isGroupAction
        self.outcomes = outcomes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actionType = try container.decode(String.self, forKey: .actionType)
        position = try container.decode(RollPosition.self, forKey: .position)
        effect = try container.decode(RollEffect.self, forKey: .effect)
        isGroupAction = try container.decodeIfPresent(Bool.self, forKey: .isGroupAction) ?? false
        let rawOutcomes = try container.decodeIfPresent([String: [Consequence]].self, forKey: .outcomes) ?? [:]
        var mapped: [RollOutcome: [Consequence]] = [:]
        for (key, value) in rawOutcomes {
            if let outcome = RollOutcome(rawValue: key) {
                mapped[outcome] = value
            }
        }
        outcomes = mapped
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(actionType, forKey: .actionType)
        try container.encode(position, forKey: .position)
        try container.encode(effect, forKey: .effect)
        if isGroupAction {
            try container.encode(isGroupAction, forKey: .isGroupAction)
        }
        var raw: [String: [Consequence]] = [:]
        for (key, value) in outcomes { raw[key.rawValue] = value }
        try container.encode(raw, forKey: .outcomes)
    }
}

extension ActionOption: Identifiable {
    var id: String { name }
}

enum RollOutcome: String, Codable {
    case success
    case partial
    case failure
}

enum Consequence: Codable {
    case gainStress(amount: Int)
    case sufferHarm(level: HarmLevel, familyId: String)
    case tickClock(clockName: String, amount: Int)
    case unlockConnection(fromNodeID: UUID, toNodeID: UUID)
    case removeInteractable(id: String)
    case removeSelfInteractable
    case addInteractable(inNodeID: UUID, interactable: Interactable)
    case addInteractableHere(interactable: Interactable)
    case gainTreasure(treasureId: String)

    private enum CodingKeys: String, CodingKey {
        case type, amount, level, familyId, clockName
        case fromNodeID, toNodeID, id, inNodeID
        case interactable, treasure, treasureId
    }

    private enum Kind: String, Codable {
        case gainStress
        case sufferHarm
        case tickClock
        case unlockConnection
        case removeInteractable
        case removeSelfInteractable
        case addInteractable
        case addInteractableHere
        case gainTreasure
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .gainStress:
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .gainStress(amount: amount)
        case .sufferHarm:
            let level = try container.decode(HarmLevel.self, forKey: .level)
            let family = try container.decode(String.self, forKey: .familyId)
            self = .sufferHarm(level: level, familyId: family)
        case .tickClock:
            let name = try container.decode(String.self, forKey: .clockName)
            let amount = try container.decode(Int.self, forKey: .amount)
            self = .tickClock(clockName: name, amount: amount)
        case .unlockConnection:
            let from = try container.decode(UUID.self, forKey: .fromNodeID)
            let to = try container.decode(UUID.self, forKey: .toNodeID)
            self = .unlockConnection(fromNodeID: from, toNodeID: to)
        case .removeInteractable:
            let idString = try container.decode(String.self, forKey: .id)
            if idString == "self" {
                self = .removeSelfInteractable
            } else {
                self = .removeInteractable(id: idString)
            }
        case .removeSelfInteractable:
            self = .removeSelfInteractable
        case .addInteractable:
            if let nodeString = try? container.decode(String.self, forKey: .inNodeID), nodeString == "current" {
                let interactable = try container.decode(Interactable.self, forKey: .interactable)
                self = .addInteractableHere(interactable: interactable)
            } else {
                let node = try container.decode(UUID.self, forKey: .inNodeID)
                let interactable = try container.decode(Interactable.self, forKey: .interactable)
                self = .addInteractable(inNodeID: node, interactable: interactable)
            }
        case .addInteractableHere:
            let interactable = try container.decode(Interactable.self, forKey: .interactable)
            self = .addInteractableHere(interactable: interactable)
        case .gainTreasure:
            if let treasureId = try? container.decode(String.self, forKey: .treasureId) {
                self = .gainTreasure(treasureId: treasureId)
            } else if let treasure = try? container.decode(Treasure.self, forKey: .treasure) {
                // Fallback to embedded treasure object
                self = .gainTreasure(treasureId: treasure.id)
            } else {
                self = .gainTreasure(treasureId: "")
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gainStress(let amount):
            try container.encode(Kind.gainStress, forKey: .type)
            try container.encode(amount, forKey: .amount)
        case .sufferHarm(let level, let family):
            try container.encode(Kind.sufferHarm, forKey: .type)
            try container.encode(level, forKey: .level)
            try container.encode(family, forKey: .familyId)
        case .tickClock(let name, let amount):
            try container.encode(Kind.tickClock, forKey: .type)
            try container.encode(name, forKey: .clockName)
            try container.encode(amount, forKey: .amount)
        case .unlockConnection(let from, let to):
            try container.encode(Kind.unlockConnection, forKey: .type)
            try container.encode(from, forKey: .fromNodeID)
            try container.encode(to, forKey: .toNodeID)
        case .removeInteractable(let id):
            try container.encode(Kind.removeInteractable, forKey: .type)
            try container.encode(id, forKey: .id)
        case .removeSelfInteractable:
            try container.encode(Kind.removeSelfInteractable, forKey: .type)
        case .addInteractable(let node, let interactable):
            try container.encode(Kind.addInteractable, forKey: .type)
            try container.encode(node, forKey: .inNodeID)
            try container.encode(interactable, forKey: .interactable)
        case .addInteractableHere(let interactable):
            try container.encode(Kind.addInteractable, forKey: .type)
            try container.encode("current", forKey: .inNodeID)
            try container.encode(interactable, forKey: .interactable)
        case .gainTreasure(let treasureId):
            try container.encode(Kind.gainTreasure, forKey: .type)
            try container.encode(treasureId, forKey: .treasureId)
        }
    }
}

enum HarmLevel: String, Codable {
    case lesser
    case moderate
    case severe
}

enum RollPosition: String, Codable {
    case controlled
    case risky
    case desperate

    /// Returns a one-step improved position, clamping at `.controlled`.
    func improved() -> RollPosition {
        switch self {
        case .desperate: return .risky
        case .risky: return .controlled
        case .controlled: return .controlled
        }
    }
}

enum RollEffect: String, Codable {
    case limited
    case standard
    case great

    /// Returns a reduced effect level, clamping at `.limited`.
    func decreased() -> RollEffect {
        switch self {
        case .great: return .standard
        case .standard: return .limited
        case .limited: return .limited
        }
    }

    /// Returns an increased effect level, clamping at `.great`.
    func increased() -> RollEffect {
        switch self {
        case .limited: return .standard
        case .standard: return .great
        case .great: return .great
        }
    }
}


// Represents the entire dungeon layout
struct DungeonMap: Codable {
    // Store node IDs as strings so JSONEncoder produces a valid object
    var nodes: [String: MapNode] // Use a dictionary for quick node lookup by ID
    var startingNodeID: UUID
}

// Represents a single room or location on the map
struct MapNode: Identifiable, Codable {
    let id: UUID
    var name: String
    var soundProfile: String
    var interactables: [Interactable]
    var connections: [NodeConnection]
    var theme: String? = nil
    var isDiscovered: Bool = false // To support fog of war
}

// Represents a path from one node to another
struct NodeConnection: Codable {
    var toNodeID: UUID
    var isUnlocked: Bool = true // A path could be locked initially
    var description: String // e.g., "A dark tunnel", "A rickety bridge"
}

// MARK: - Persistence Helpers

extension GameState {
    /// Encode the game state and write it to the specified URL.
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }

    /// Load a `GameState` from the given file URL.
    static func load(from url: URL) throws -> GameState {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(GameState.self, from: data)
    }
}


```

### `CardGame/InteractableCardView.swift`

```

import SwiftUI

struct InteractableCardView: View {
    let interactable: Interactable
    let selectedCharacter: Character?
    let onActionTapped: (ActionOption) -> Void

    private func hasPenalty(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                if case .actionPenalty(let t) = penalty, t == action.actionType { return true }
                if case .banAction(let t) = penalty, t == action.actionType { return true }
            }
        }
        return false
    }

    private func hasBonus(for action: ActionOption) -> Bool {
        guard let character = selectedCharacter else { return false }
        for mod in character.modifiers {
            if mod.uses == 0 { continue }
            if let specific = mod.applicableToAction, specific != action.actionType { continue }
            if mod.bonusDice != 0 || mod.improvePosition || mod.improveEffect { return true }
        }
        return false
    }

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
                .overlay(alignment: .topTrailing) {
                    if hasPenalty(for: action) {
                        Image("icon_penalty_action")
                            .resizable()
                            .frame(width: 16, height: 16)
                    } else if hasBonus(for: action) {
                        Image("icon_bonus_action")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(interactable.isThreat ? Color.red : Color.clear, lineWidth: 3)
        )
        .overlay(alignment: .topLeading) {
            if interactable.isThreat {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .padding(4)
            }
        }
        .shadow(radius: 4)
    }
}

```

### `CardGame/CharacterSheetView.swift`

```

import SwiftUI

struct CharacterSheetView: View {
    let character: Character
    var locationName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Identity
            HStack(alignment: .firstTextBaseline) {
                Text(character.name)
                    .font(.headline)
                    .bold()
                Spacer()
                Text(character.characterClass)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let locationName {
                Text("At: \(locationName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Vital stats block
            VStack(alignment: .center, spacing: 6) {
                // Stress
                VStack(alignment: .center, spacing: 2) {
                    Text("Stress \(character.stress)/9")
                        .font(.caption2)
                    HStack(spacing: 2) {
                        ForEach(1...9, id: \.self) { index in
                            Image(character.stress >= index ? "icon_stress_pip_lit" : "icon_stress_pip_unlit")
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                    }
                }

                // Harm
                VStack(alignment: .center, spacing: 4) {
                    Text("Harm")
                        .font(.caption2)

                    // Lesser Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.lesserSlots, id: \.self) { index in
                            Text(index < character.harm.lesser.count ? character.harm.lesser[index].description : "None")
                                .font(.caption2)
                                .foregroundColor(index < character.harm.lesser.count ? .primary : .gray)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
                    }

                    // Moderate Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                            Text(index < character.harm.moderate.count ? character.harm.moderate[index].description : "None")
                                .font(.caption2)
                                .foregroundColor(index < character.harm.moderate.count ? .primary : .gray)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
                    }

                    // Severe Harm
                    Text(character.harm.severe.first?.description ?? "None")
                        .font(.caption2)
                        .foregroundColor(character.harm.severe.isEmpty ? .gray : .primary)
                        .padding(4)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(4)
                }
                .padding(.top, 8)
            }
            .padding(6)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(8)

            // Actions
            VStack(alignment: .leading, spacing: 4) {
                Text("Actions")
                    .font(.caption2)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 4) {
                    ForEach(character.actions.sorted(by: { $0.key < $1.key }), id: \.key) { action, rating in
                        HStack(spacing: 4) {
                            Text(action)
                            HStack(spacing: 1) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image("icon_stress_pip_lit")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                }
                            }
                            Spacer()
                        }
                        .font(.caption2)
                    }
                }
            }

            // Treasures
            if !character.treasures.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Treasures")
                        .font(.caption2)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(character.treasures) { treasure in
                                Text(treasure.name)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color(UIColor.systemBackground).opacity(0.5))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

```

### `CardGame/GameViewModel.swift`

```

import SwiftUI

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String]
}

@MainActor
enum PartyMovementMode {
    case grouped
    case solo
}

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var partyMovementMode: PartyMovementMode = .grouped

    /// Location of the save file within the app's Documents directory.
    private static var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savegame.json")
    }

    /// Whether a saved game exists on disk.
    static var saveExists: Bool {
        FileManager.default.fileExists(atPath: saveURL.path)
    }


    // Retrieve the node a specific character is currently in
    func node(for characterID: UUID?) -> MapNode? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id.uuidString],
              let map = gameState.dungeon else { return nil }
        return map.nodes[nodeID.uuidString]
    }


    /// Initialize a blank view model intended for loading a game.
    init() {
        self.gameState = GameState()
    }

    /// Initialize and immediately start a new game with the given scenario.
    init(startNewWithScenario scenario: String) {
        self.gameState = GameState()
        startNewRun(scenario: scenario)
    }

    /// Persist the current game state to disk.
    func saveGame() {
        do {
            print("Attempting to save game to: \(Self.saveURL.path)")
            try gameState.save(to: Self.saveURL)
        } catch {
            print("Failed to save game: \(error)")
        }
    }

    /// Attempt to load a saved game from disk. Returns `true` on success.
    func loadGame() -> Bool {
        guard Self.saveExists else { return false }
        do {
            let loaded = try GameState.load(from: Self.saveURL)
            self.gameState = loaded
            ContentLoader.shared = ContentLoader(scenario: loaded.scenarioName)
            if let anyID = loaded.characterLocations.first?.value,
               let node = loaded.dungeon?.nodes[anyID.uuidString] {
                AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
            }
            return true
        } catch {
            print("Failed to load game: \(error)")
            return false
        }
    }

    // --- Core Logic Functions for the Sprint ---

    /// Calculates the projection before the roll.
    func calculateProjection(for action: ActionOption, with character: Character) -> RollProjectionDetails {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
        let baseDice = diceCount
        let basePosition = position
        let baseEffect = effect
        var notes: [String] = []

        // Apply penalties from all active harm conditions
        for harm in character.harm.lesser {
            if let penalty = HarmLibrary.families[harm.familyId]?.lesser.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.moderate {
            if let penalty = HarmLibrary.families[harm.familyId]?.moderate.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        for harm in character.harm.severe {
            if let penalty = HarmLibrary.families[harm.familyId]?.severe.penalty {
                apply(penalty: penalty, description: harm.description, to: action.actionType, diceCount: &diceCount, effect: &effect, notes: &notes)
            }
        }
        // Apply bonuses from modifiers
        for modifier in character.modifiers {
            if modifier.uses == 0 { continue }
            if let specific = modifier.applicableToAction, specific != action.actionType { continue }

            if modifier.bonusDice != 0 {
                diceCount += modifier.bonusDice
                var note = "(+\(modifier.bonusDice)d \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }

            if modifier.improvePosition {
                position = position.improved()
                var note = "(Improved Position from \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }

            if modifier.improveEffect {
                effect = effect.increased()
                var note = "(+1 Effect from \(modifier.description)"
                if modifier.uses > 0 {
                    note += " (\(modifier.uses) use\(modifier.uses == 1 ? "" : "s") left)"
                }
                if modifier.uses == 1 { note += " - will be consumed" }
                note += ")"
                notes.append(note)
            }
        }

        if action.isGroupAction {
            notes.append("Group Action: party rolls together; best result counts. Leader takes 1 Stress per failed ally.")
        }

        diceCount = max(diceCount, 0) // Can't roll negative dice

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: diceCount,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes
        )
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character, interactableID: String?) -> DiceRollResult {
        if action.isGroupAction {
            return performGroupAction(for: action, leader: character, interactableID: interactableID)
        }
        guard gameState.party.contains(where: { $0.id == character.id }) else {
            return DiceRollResult(highestRoll: 0, outcome: "Error", consequences: "Character not found.")
        }

        let dicePool = max(character.actions[action.actionType] ?? 0, 1)
        var highestRoll = 0
        for _ in 0..<dicePool {
            highestRoll = max(highestRoll, Int.random(in: 1...6))
        }

        var consequencesToApply: [Consequence] = []
        var outcomeString = ""

        switch highestRoll {
        case 6:
            outcomeString = "Full Success!"
            consequencesToApply = action.outcomes[.success] ?? []
        case 4...5:
            outcomeString = "Partial Success..."
            consequencesToApply = action.outcomes[.partial] ?? []
        default:
            outcomeString = "Failure."
            consequencesToApply = action.outcomes[.failure] ?? []
        }

        var consequencesDescription = processConsequences(consequencesToApply, forCharacter: character, interactableID: interactableID)

        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            var updatedModifiers: [Modifier] = []
            var consumedMessages: [String] = []
            for var modifier in gameState.party[charIndex].modifiers {
                if modifier.uses == 0 { continue }
                if let specific = modifier.applicableToAction, specific != action.actionType {
                    updatedModifiers.append(modifier)
                    continue
                }
                if modifier.uses > 0 {
                    modifier.uses -= 1
                    if modifier.uses == 0 {
                        let name = modifier.description.replacingOccurrences(of: "from ", with: "")
                        consumedMessages.append("Used up \(name).")
                        continue
                    }
                }
                updatedModifiers.append(modifier)
            }
            gameState.party[charIndex].modifiers = updatedModifiers
            if !consumedMessages.isEmpty {
                AudioManager.shared.play(sound: "sfx_modifier_consume.wav")
                if consequencesDescription.isEmpty {
                    consequencesDescription = consumedMessages.joined(separator: "\n")
                } else {
                    consequencesDescription += "\n" + consumedMessages.joined(separator: "\n")
                }
            }
        }
        saveGame()

        return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
    }

    private func performGroupAction(for action: ActionOption, leader: Character, interactableID: String?) -> DiceRollResult {
        guard partyMovementMode == .grouped, !isPartyActuallySplit() else {
            return DiceRollResult(highestRoll: 0, outcome: "Cannot", consequences: "Party must be together for a group action.")
        }

        var bestRoll = 0
        var failures = 0

        for member in gameState.party {
            let dicePool = max(member.actions[action.actionType] ?? 0, 1)
            var highest = 0
            for _ in 0..<dicePool { highest = max(highest, Int.random(in: 1...6)) }
            bestRoll = max(bestRoll, highest)
            if highest <= 3 { failures += 1 }
        }

        var consequences: [Consequence] = []
        var outcomeString = ""

        switch bestRoll {
        case 6:
            outcomeString = "Full Success!"
            consequences = action.outcomes[.success] ?? []
        case 4...5:
            outcomeString = "Partial Success..."
            consequences = action.outcomes[.partial] ?? []
        default:
            outcomeString = "Failure."
            consequences = action.outcomes[.failure] ?? []
        }

        var description = processConsequences(consequences, forCharacter: leader, interactableID: interactableID)

        if let leaderIndex = gameState.party.firstIndex(where: { $0.id == leader.id }) {
            gameState.party[leaderIndex].stress += failures
            if failures > 0 {
                if !description.isEmpty { description += "\n" }
                description += "Leader takes \(failures) Stress from allies' slips."
            }
        }

        saveGame()
        return DiceRollResult(highestRoll: bestRoll, outcome: outcomeString, consequences: description)
    }

    private func processConsequences(_ consequences: [Consequence], forCharacter character: Character, interactableID: String?) -> String {
        var descriptions: [String] = []
        let partyMemberId = character.id
        for consequence in consequences {
            switch consequence {
            case .gainStress(let amount):
                if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].stress += amount
                    descriptions.append("Gained \(amount) Stress.")
                }
            case .sufferHarm(let level, let familyId):
                let description = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
                descriptions.append(description)
            case .tickClock(let clockName, let amount):
                if let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                    updateClock(id: gameState.activeClocks[clockIndex].id, ticks: amount)
                    descriptions.append("The '\(clockName)' clock progresses by \(amount).")
                }
            case .unlockConnection(let fromNodeID, let toNodeID):
                if let connIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connIndex].isUnlocked = true
                    descriptions.append("A path has opened!")
                }
            case .removeInteractable(let id):
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == id })
                    descriptions.append("The way is clear.")
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString], let interactableStrID = interactableID {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == interactableStrID })
                    descriptions.append("The way is clear.")
                }
            case .addInteractable(let inNodeID, let interactable):
                gameState.dungeon?.nodes[inNodeID.uuidString]?.interactables.append(interactable)
                descriptions.append("Something new appears.")
            case .addInteractableHere(let interactable):
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
                    descriptions.append("Something new appears.")
                }
            case .gainTreasure(let treasureId):
                if let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureId }),
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].treasures.append(treasure)
                    gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                    descriptions.append("Gained Treasure: \(treasure.name)!")
                }
            }
        }
        return descriptions.joined(separator: "\n")
    }

    private func apply(penalty: Penalty, description: String, to actionType: String, diceCount: inout Int, effect: inout RollEffect, notes: inout [String]) {
        switch penalty {
        case .reduceEffect:
            effect = effect.decreased()
            notes.append("(-1 Effect from \(description))")
        case .actionPenalty(let action) where action == actionType:
            diceCount -= 1
            notes.append("(-1d from \(description))")
        case .banAction(let action) where action == actionType:
            diceCount = 0
            notes.append("(Cannot perform due to \(description))")
        default:
            break
        }
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments,
                                                         gameState.activeClocks[index].progress + ticks)
        }
    }

    func pushYourself(forCharacter character: Character) {
        if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
            let currentStress = gameState.party[charIndex].stress
            if currentStress + 2 > 9 {
                // Handle Trauma case later
            }
            gameState.party[charIndex].stress += 2
        }
    }

    private func applyHarm(familyId: String, level: HarmLevel, toCharacter characterId: UUID) -> String {
        guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterId }) else { return "" }
        guard let harmFamily = HarmLibrary.families[familyId] else { return "" }

        var currentLevel = level

        while true {
            switch currentLevel {
            case .lesser:
                if gameState.party[charIndex].harm.lesser.count < HarmState.lesserSlots {
                    let harm = harmFamily.lesser
                    gameState.party[charIndex].harm.lesser.append((familyId, harm.description))
                    return "Suffered Lesser Harm: \(harm.description)."
                } else {
                    currentLevel = .moderate
                }
            case .moderate:
                if gameState.party[charIndex].harm.moderate.count < HarmState.moderateSlots {
                    let harm = harmFamily.moderate
                    gameState.party[charIndex].harm.moderate.append((familyId, harm.description))
                    return "Suffered Moderate Harm: \(harm.description)."
                } else {
                    currentLevel = .severe
                }
            case .severe:
                if gameState.party[charIndex].harm.severe.count < HarmState.severeSlots {
                    let harm = harmFamily.severe
                    gameState.party[charIndex].harm.severe.append((familyId, harm.description))
                    return "Suffered SEVERE Harm: \(harm.description)."
                } else {
                    gameState.status = .gameOver
                    let fatalDescription = harmFamily.fatal.description
                    saveGame()
                    return "Suffered FATAL Harm: \(fatalDescription)."
                }
            }
        }
    }

    /// Starts a brand new run, resetting the game state. The scenario id
    /// corresponds to a folder within `Content/Scenarios`.
    func startNewRun(scenario: String = "tomb") {
        // Recreate the shared content loader so subsequent lookups use the
        // selected scenario.
        ContentLoader.shared = ContentLoader(scenario: scenario)
        let generator = DungeonGenerator(content: ContentLoader.shared)
        let (newDungeon, generatedClocks) = generator.generate(level: 1)

        self.gameState = GameState(
            scenarioName: scenario,
            party: [
                Character(id: UUID(), name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(id: UUID(), name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(id: UUID(), name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ] + generatedClocks,
            dungeon: newDungeon,
            characterLocations: [:],
            status: .playing
        )

        for id in gameState.party.map({ $0.id }) {
            gameState.characterLocations[id.uuidString] = newDungeon.startingNodeID
        }

        if let startingNode = newDungeon.nodes[newDungeon.startingNodeID.uuidString] {
            AudioManager.shared.play(sound: "ambient_\(startingNode.soundProfile).wav", loop: true)
        }

        saveGame()
    }


    /// Move one or all party members depending on the current movement mode.
    func move(characterID: UUID, to connection: NodeConnection) {
        guard connection.isUnlocked else { return }

        if partyMovementMode == .solo {
            gameState.characterLocations[characterID.uuidString] = connection.toNodeID
        } else {
            for id in gameState.party.map({ $0.id }) {
                gameState.characterLocations[id.uuidString] = connection.toNodeID
            }
        }

        if let node = gameState.dungeon?.nodes[connection.toNodeID.uuidString] {
            gameState.dungeon?.nodes[connection.toNodeID.uuidString]?.isDiscovered = true
            AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
        }

        saveGame()
    }

    func getNodeName(for characterID: UUID?) -> String? {
        guard let id = characterID,
              let nodeID = gameState.characterLocations[id.uuidString],
              let node = gameState.dungeon?.nodes[nodeID.uuidString] else { return nil }
        return node.name
    }

    func isPartyActuallySplit() -> Bool {
        let unique = Set(gameState.characterLocations.values)
        return unique.count > 1
    }

    func toggleMovementMode() {
        partyMovementMode = (partyMovementMode == .grouped) ? .solo : .grouped
    }
}


```

### `CardGame/ContentView.swift`

```

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var pendingAction: ActionOption?
    @State private var pendingInteractableID: String?
    @State private var selectedCharacterID: UUID? // Track selected character
    @State private var showingStatusSheet = false // Controls the party sheet
    @State private var showingMap = false // Controls the map sheet
    @State private var doorProgress: CGFloat = 0 // For sliding door transition
    @Environment(\.scenePhase) private var scenePhase

    init(scenario: String = "tomb") {
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

                    Button {
                        showingMap.toggle()
                    } label: {
                        Image(systemName: "map")
                        Text("Map")
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
        .sheet(isPresented: $showingMap) {
            MapView(viewModel: viewModel)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                viewModel.saveGame()
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

```

### `CardGame/Info.plist`

```

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>UIBackgroundModes</key>
	<array>
		<string>remote-notification</string>
	</array>
</dict>
</plist>

```

### `Content/treasures.json`

```

[
  {
    "id": "treasure_purified_idol_shard",
    "name": "Purified Idol Shard",
    "description": "A fragment of the idol, cleansed of its curse.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "Blessing of the Idol"
    }
  },
  {
    "id": "treasure_ancient_coin",
    "name": "Ancient Coin",
    "description": "A coin from a forgotten empire.",
    "grantedModifier": {
      "improveEffect": true,
      "description": "Lucky Find"
    }
  },
  {
    "id": "treasure_steadying_herbs",
    "name": "Steadying Herbs",
    "description": "Chewing these calms the nerves, for a time.",
    "grantedModifier": {
      "improvePosition": true,
      "uses": 1,
      "description": "from Steadying Herbs"
    }
  },
  {
    "id": "treasure_precise_tools",
    "name": "Set of Precise Tools",
    "description": "Ideal instruments for delicate work.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Tinker",
      "uses": 2,
      "description": "from Precise Tools"
    }
  },
  {
    "id": "treasure_charmed_talisman",
    "name": "Charmed Talisman",
    "description": "Offers fleeting protection from dark thoughts.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Attune",
      "uses": 1,
      "description": "from Charmed Talisman"
    }
  },
  {
    "id": "treasure_map_fragment",
    "name": "Map Fragment",
    "description": "Hints at a secret room somewhere in the tomb.",
    "grantedModifier": {
      "improveEffect": true,
      "uses": 1,
      "description": "from Map Fragment"
    }
  }
]

```

### `Content/interactables.json`

```

{
  "common_traps": [
    {
      "id": "template_pressure_plate",
      "title": "Pressure Plate",
      "description": "A slightly raised stone tile looks suspicious.",
      "availableActions": [
        {
          "name": "Deftly step over it",
          "actionType": "Finesse",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ]
          }
        }
      ]
    },
    {
      "id": "template_cursed_idol",
      "title": "Cursed Idol",
      "description": "A small, unnerving idol of a forgotten god.",
      "availableActions": [
        {
          "name": "Smash it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" },
              { "type": "gainTreasure", "treasureId": "treasure_purified_idol_shard" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "head_trauma" }
            ]
          }
        }
      ]
    }
    ,
    {
      "id": "template_crumbling_ledge",
      "title": "Crumbling Ledge",
      "description": "A narrow ledge over a dark chasm. It looks unstable.",
      "availableActions": [
        {
          "name": "Cross Carefully",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "standard",
          "isGroupAction": true,
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [
              { "type": "gainStress", "amount": 2 },
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" },
              { "type": "tickClock", "clockName": "Chasm Peril", "amount": 2 }
            ]
          }
        },
        {
          "name": "Test its Stability",
          "actionType": "Survey",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_mysterious_whispers",
      "title": "Mysterious Whispers",
      "description": "Voices echo softly from unseen sources.",
      "availableActions": [
        {
          "name": "Listen Closely",
          "actionType": "Attune",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_map_fragment" } ],
            "partial": [ { "type": "sufferHarm", "level": "lesser", "familyId": "mental_anguish" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "mental_anguish" } ]
          }
        },
        {
          "name": "Block Out Noise",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_jammed_lock",
      "title": "Jammed Lock",
      "description": "A sturdy door with a rusted mechanism.",
      "availableActions": [
        {
          "name": "Pick the Lock",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_precise_tools" } ],
            "partial": [ { "type": "tickClock", "clockName": "Lockdown Approaches", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "gear_damage" } ]
          }
        },
        {
          "name": "Force it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    },
    {
      "id": "template_unstable_rune",
      "title": "Unstable Rune",
      "description": "A glowing rune pulsates with dangerous energy.",
      "availableActions": [
        {
          "name": "Decode Glyphs",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [ { "type": "tickClock", "clockName": "Rune Overload", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Shatter it",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        }
      ]
    },
    {
      "id": "template_hidden_niche",
      "title": "Hidden Niche",
      "description": "A faint outline hints at a recess in the wall.",
      "availableActions": [
        {
          "name": "Search Carefully",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Finesse", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "tickClock", "clockName": "Chest Trap", "amount": 1 } ] } } ] } } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        },
        {
          "name": "Force it Open",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Wreck", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ] } } ] } } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    }
  ],
  "threats": [
    {
      "id": "threat_hungry_ghoul",
      "title": "Hungry Ghoul",
      "description": "A ravenous ghoul lurches from the shadows.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Drive it back",
          "actionType": "Skirmish",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" } ]
          }
        },
        {
          "name": "Flee",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "tickClock", "clockName": "Ghoul Pursuit", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "threat_reactor_breach",
      "title": "Reactor Breach",
      "description": "Alarms blare as a reactor begins to overload.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Stabilize Reactor",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Evacuate",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 2 } ]
          }
        }
      ]
    }
  ]
}

```

### `Content/harm_families.json`

```

{
  "families": [
    {
      "id": "head_trauma",
      "lesser": { "description": "Headache", "penalty": { "type": "actionPenalty", "actionType": "Study" } },
      "moderate": { "description": "Migraine", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Brain Lightning", "penalty": { "type": "banAction", "actionType": "Study" } },
      "fatal": { "description": "Head Explosion" }
    },
    {
      "id": "leg_injury",
      "lesser": { "description": "Twisted Ankle", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Torn Muscle", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Shattered Knee", "penalty": { "type": "banAction", "actionType": "Finesse" } },
      "fatal": { "description": "Crippled Beyond Recovery" }
    },
    {
      "id": "electric_shock",
      "lesser": { "description": "Electric Jolt" },
      "moderate": { "description": "Seared Nerves", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Nerve Damage", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "fatal": { "description": "Heart Stops" }
    },
    {
      "id": "mental_anguish",
      "lesser": { "description": "Unease", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "moderate": { "description": "Fleeting Shadows", "penalty": { "type": "actionPenalty", "actionType": "Survey" } },
      "severe": { "description": "Terror", "penalty": { "type": "reduceEffect" } },
      "fatal": { "description": "Mind Broken" }
    },
    {
      "id": "gear_damage",
      "lesser": { "description": "Frayed Rope", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Broken Tools", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "severe": { "description": "Lost Map", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "fatal": { "description": "Stranded and Helpless" }
    }
  ]
}

```

### `Content/Scenarios/tomb/treasures.json`

```

[
  {
    "id": "treasure_purified_idol_shard",
    "name": "Purified Idol Shard",
    "description": "A fragment of the idol, cleansed of its curse.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "Blessing of the Idol"
    }
  },
  {
    "id": "treasure_ancient_coin",
    "name": "Ancient Coin",
    "description": "A coin from a forgotten empire.",
    "grantedModifier": {
      "improveEffect": true,
      "description": "Lucky Find"
    }
  },
  {
    "id": "treasure_steadying_herbs",
    "name": "Steadying Herbs",
    "description": "Chewing these calms the nerves, for a time.",
    "grantedModifier": {
      "improvePosition": true,
      "uses": 1,
      "description": "from Steadying Herbs"
    }
  },
  {
    "id": "treasure_precise_tools",
    "name": "Set of Precise Tools",
    "description": "Ideal instruments for delicate work.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Tinker",
      "uses": 2,
      "description": "from Precise Tools"
    }
  },
  {
    "id": "treasure_charmed_talisman",
    "name": "Charmed Talisman",
    "description": "Offers fleeting protection from dark thoughts.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Attune",
      "uses": 1,
      "description": "from Charmed Talisman"
    }
  },
  {
    "id": "treasure_map_fragment",
    "name": "Map Fragment",
    "description": "Hints at a secret room somewhere in the tomb.",
    "grantedModifier": {
      "improveEffect": true,
      "uses": 1,
      "description": "from Map Fragment"
    }
  }
]

```

### `Content/Scenarios/tomb/interactables.json`

```

{
  "common_traps": [
    {
      "id": "template_pressure_plate",
      "title": "Pressure Plate",
      "description": "A slightly raised stone tile looks suspicious.",
      "availableActions": [
        {
          "name": "Deftly step over it",
          "actionType": "Finesse",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ]
          }
        }
      ]
    },
    {
      "id": "template_cursed_idol",
      "title": "Cursed Idol",
      "description": "A small, unnerving idol of a forgotten god.",
      "availableActions": [
        {
          "name": "Smash it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" },
              { "type": "gainTreasure", "treasureId": "treasure_purified_idol_shard" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "head_trauma" }
            ]
          }
        }
      ]
    }
    ,
    {
      "id": "template_crumbling_ledge",
      "title": "Crumbling Ledge",
      "description": "A narrow ledge over a dark chasm. It looks unstable.",
      "availableActions": [
        {
          "name": "Cross Carefully",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "standard",
          "isGroupAction": true,
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [
              { "type": "gainStress", "amount": 2 },
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" },
              { "type": "tickClock", "clockName": "Chasm Peril", "amount": 2 }
            ]
          }
        },
        {
          "name": "Test its Stability",
          "actionType": "Survey",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_mysterious_whispers",
      "title": "Mysterious Whispers",
      "description": "Voices echo softly from unseen sources.",
      "availableActions": [
        {
          "name": "Listen Closely",
          "actionType": "Attune",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_map_fragment" } ],
            "partial": [ { "type": "sufferHarm", "level": "lesser", "familyId": "mental_anguish" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "mental_anguish" } ]
          }
        },
        {
          "name": "Block Out Noise",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_jammed_lock",
      "title": "Jammed Lock",
      "description": "A sturdy door with a rusted mechanism.",
      "availableActions": [
        {
          "name": "Pick the Lock",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_precise_tools" } ],
            "partial": [ { "type": "tickClock", "clockName": "Lockdown Approaches", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "gear_damage" } ]
          }
        },
        {
          "name": "Force it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    },
    {
      "id": "template_unstable_rune",
      "title": "Unstable Rune",
      "description": "A glowing rune pulsates with dangerous energy.",
      "availableActions": [
        {
          "name": "Decode Glyphs",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [ { "type": "tickClock", "clockName": "Rune Overload", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Shatter it",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        }
      ]
    },
    {
      "id": "template_hidden_niche",
      "title": "Hidden Niche",
      "description": "A faint outline hints at a recess in the wall.",
      "availableActions": [
        {
          "name": "Search Carefully",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Finesse", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "tickClock", "clockName": "Chest Trap", "amount": 1 } ] } } ] } } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        },
        {
          "name": "Force it Open",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Wreck", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ] } } ] } } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    }
  ],
  "threats": [
    {
      "id": "threat_hungry_ghoul",
      "title": "Hungry Ghoul",
      "description": "A ravenous ghoul lurches from the shadows.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Drive it back",
          "actionType": "Skirmish",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" } ]
          }
        },
        {
          "name": "Flee",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "tickClock", "clockName": "Ghoul Pursuit", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "threat_reactor_breach",
      "title": "Reactor Breach",
      "description": "Alarms blare as a reactor begins to overload.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Stabilize Reactor",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Evacuate",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 2 } ]
          }
        }
      ]
    }
  ]
}

```

### `Content/Scenarios/tomb/harm_families.json`

```

{
  "families": [
    {
      "id": "head_trauma",
      "lesser": { "description": "Headache", "penalty": { "type": "actionPenalty", "actionType": "Study" } },
      "moderate": { "description": "Migraine", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Brain Lightning", "penalty": { "type": "banAction", "actionType": "Study" } },
      "fatal": { "description": "Head Explosion" }
    },
    {
      "id": "leg_injury",
      "lesser": { "description": "Twisted Ankle", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Torn Muscle", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Shattered Knee", "penalty": { "type": "banAction", "actionType": "Finesse" } },
      "fatal": { "description": "Crippled Beyond Recovery" }
    },
    {
      "id": "electric_shock",
      "lesser": { "description": "Electric Jolt" },
      "moderate": { "description": "Seared Nerves", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Nerve Damage", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "fatal": { "description": "Heart Stops" }
    },
    {
      "id": "mental_anguish",
      "lesser": { "description": "Unease", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "moderate": { "description": "Fleeting Shadows", "penalty": { "type": "actionPenalty", "actionType": "Survey" } },
      "severe": { "description": "Terror", "penalty": { "type": "reduceEffect" } },
      "fatal": { "description": "Mind Broken" }
    },
    {
      "id": "gear_damage",
      "lesser": { "description": "Frayed Rope", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Broken Tools", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "severe": { "description": "Lost Map", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "fatal": { "description": "Stranded and Helpless" }
    }
  ]
}

```

### `Content/Scenarios/tomb/scenario.json`

```

{
  "id": "tomb",
  "title": "Forgotten Tomb",
  "description": "Explore the depths of an ancient tomb.",
  "entryNode": "start"
}

```

### `Content/Scenarios/test_lab/treasures.json`

```

[
  {
    "id": "treasure_purified_idol_shard",
    "name": "Purified Idol Shard",
    "description": "A fragment of the idol, cleansed of its curse.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "Blessing of the Idol"
    }
  },
  {
    "id": "treasure_ancient_coin",
    "name": "Ancient Coin",
    "description": "A coin from a forgotten empire.",
    "grantedModifier": {
      "improveEffect": true,
      "description": "Lucky Find"
    }
  },
  {
    "id": "treasure_steadying_herbs",
    "name": "Steadying Herbs",
    "description": "Chewing these calms the nerves, for a time.",
    "grantedModifier": {
      "improvePosition": true,
      "uses": 1,
      "description": "from Steadying Herbs"
    }
  },
  {
    "id": "treasure_precise_tools",
    "name": "Set of Precise Tools",
    "description": "Ideal instruments for delicate work.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Tinker",
      "uses": 2,
      "description": "from Precise Tools"
    }
  },
  {
    "id": "treasure_charmed_talisman",
    "name": "Charmed Talisman",
    "description": "Offers fleeting protection from dark thoughts.",
    "grantedModifier": {
      "bonusDice": 1,
      "applicableToAction": "Attune",
      "uses": 1,
      "description": "from Charmed Talisman"
    }
  },
  {
    "id": "treasure_map_fragment",
    "name": "Map Fragment",
    "description": "Hints at a secret room somewhere in the tomb.",
    "grantedModifier": {
      "improveEffect": true,
      "uses": 1,
      "description": "from Map Fragment"
    }
  }
]

```

### `Content/Scenarios/test_lab/interactables.json`

```

{
  "common_traps": [
    {
      "id": "template_pressure_plate",
      "title": "Pressure Plate",
      "description": "A slightly raised stone tile looks suspicious.",
      "availableActions": [
        {
          "name": "Deftly step over it",
          "actionType": "Finesse",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ]
          }
        }
      ]
    },
    {
      "id": "template_cursed_idol",
      "title": "Cursed Idol",
      "description": "A small, unnerving idol of a forgotten god.",
      "availableActions": [
        {
          "name": "Smash it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" },
              { "type": "gainTreasure", "treasureId": "treasure_purified_idol_shard" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "head_trauma" }
            ]
          }
        }
      ]
    }
    ,
    {
      "id": "template_crumbling_ledge",
      "title": "Crumbling Ledge",
      "description": "A narrow ledge over a dark chasm. It looks unstable.",
      "availableActions": [
        {
          "name": "Cross Carefully",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "standard",
          "isGroupAction": true,
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [
              { "type": "gainStress", "amount": 2 },
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" },
              { "type": "tickClock", "clockName": "Chasm Peril", "amount": 2 }
            ]
          }
        },
        {
          "name": "Test its Stability",
          "actionType": "Survey",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_mysterious_whispers",
      "title": "Mysterious Whispers",
      "description": "Voices echo softly from unseen sources.",
      "availableActions": [
        {
          "name": "Listen Closely",
          "actionType": "Attune",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_map_fragment" } ],
            "partial": [ { "type": "sufferHarm", "level": "lesser", "familyId": "mental_anguish" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "mental_anguish" } ]
          }
        },
        {
          "name": "Block Out Noise",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "template_jammed_lock",
      "title": "Jammed Lock",
      "description": "A sturdy door with a rusted mechanism.",
      "availableActions": [
        {
          "name": "Pick the Lock",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_precise_tools" } ],
            "partial": [ { "type": "tickClock", "clockName": "Lockdown Approaches", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "gear_damage" } ]
          }
        },
        {
          "name": "Force it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    },
    {
      "id": "template_unstable_rune",
      "title": "Unstable Rune",
      "description": "A glowing rune pulsates with dangerous energy.",
      "availableActions": [
        {
          "name": "Decode Glyphs",
          "actionType": "Study",
          "position": "controlled",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "partial": [ { "type": "tickClock", "clockName": "Rune Overload", "amount": 1 } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Shatter it",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        }
      ]
    },
    {
      "id": "template_hidden_niche",
      "title": "Hidden Niche",
      "description": "A faint outline hints at a recess in the wall.",
      "availableActions": [
        {
          "name": "Search Carefully",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Finesse", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "tickClock", "clockName": "Chest Trap", "amount": 1 } ] } } ] } } ],
            "failure": [ { "type": "gainStress", "amount": 1 } ]
          }
        },
        {
          "name": "Force it Open",
          "actionType": "Wreck",
          "position": "risky",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "addInteractable", "inNodeID": "current", "interactable": { "id": "template_small_chest", "title": "Small Chest", "description": "Dusty but intact.", "availableActions": [ { "name": "Open", "actionType": "Wreck", "position": "risky", "effect": "standard", "outcomes": { "success": [ { "type": "gainTreasure", "treasureId": "treasure_charmed_talisman" }, { "type": "removeInteractable", "id": "self" } ], "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ] } } ] } } ],
            "failure": [ { "type": "sufferHarm", "level": "lesser", "familyId": "gear_damage" } ]
          }
        }
      ]
    }
  ],
  "threats": [
    {
      "id": "threat_hungry_ghoul",
      "title": "Hungry Ghoul",
      "description": "A ravenous ghoul lurches from the shadows.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Drive it back",
          "actionType": "Skirmish",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" } ]
          }
        },
        {
          "name": "Flee",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "tickClock", "clockName": "Ghoul Pursuit", "amount": 1 } ]
          }
        }
      ]
    },
    {
      "id": "threat_reactor_breach",
      "title": "Reactor Breach",
      "description": "Alarms blare as a reactor begins to overload.",
      "isThreat": true,
      "availableActions": [
        {
          "name": "Stabilize Reactor",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "sufferHarm", "level": "severe", "familyId": "electric_shock" } ]
          }
        },
        {
          "name": "Evacuate",
          "actionType": "Finesse",
          "position": "desperate",
          "effect": "limited",
          "outcomes": {
            "success": [ { "type": "removeInteractable", "id": "self" } ],
            "failure": [ { "type": "gainStress", "amount": 2 } ]
          }
        }
      ]
    }
  ]
}

```

### `Content/Scenarios/test_lab/harm_families.json`

```

{
  "families": [
    {
      "id": "head_trauma",
      "lesser": { "description": "Headache", "penalty": { "type": "actionPenalty", "actionType": "Study" } },
      "moderate": { "description": "Migraine", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Brain Lightning", "penalty": { "type": "banAction", "actionType": "Study" } },
      "fatal": { "description": "Head Explosion" }
    },
    {
      "id": "leg_injury",
      "lesser": { "description": "Twisted Ankle", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Torn Muscle", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Shattered Knee", "penalty": { "type": "banAction", "actionType": "Finesse" } },
      "fatal": { "description": "Crippled Beyond Recovery" }
    },
    {
      "id": "electric_shock",
      "lesser": { "description": "Electric Jolt" },
      "moderate": { "description": "Seared Nerves", "penalty": { "type": "reduceEffect" } },
      "severe": { "description": "Nerve Damage", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "fatal": { "description": "Heart Stops" }
    },
    {
      "id": "mental_anguish",
      "lesser": { "description": "Unease", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "moderate": { "description": "Fleeting Shadows", "penalty": { "type": "actionPenalty", "actionType": "Survey" } },
      "severe": { "description": "Terror", "penalty": { "type": "reduceEffect" } },
      "fatal": { "description": "Mind Broken" }
    },
    {
      "id": "gear_damage",
      "lesser": { "description": "Frayed Rope", "penalty": { "type": "actionPenalty", "actionType": "Finesse" } },
      "moderate": { "description": "Broken Tools", "penalty": { "type": "banAction", "actionType": "Tinker" } },
      "severe": { "description": "Lost Map", "penalty": { "type": "increaseStressCost", "amount": 1 } },
      "fatal": { "description": "Stranded and Helpless" }
    }
  ]
}

```

### `Content/Scenarios/test_lab/scenario.json`

```

{
  "id": "test_lab",
  "title": "Test Lab",
  "description": "A sterile testing environment.",
  "entryNode": "entry"
}

```

### `Docs/S6_MechanicalDepth/1-HarmSystemOverhaul.md`

```

Task 1: Overhaul the Harm System
Harm should be more than a simple damage counter; it should be a narrative and mechanical complication that players have to actively work around.

Action: Redefine the HarmState and introduce HarmCondition and Penalty models.
Action: Update the GameViewModel to apply penalties from Harm to a character's actions.
Models.swift (Updates)

Swift

// In Models.swift

// A specific injury or affliction with a mechanical effect.
struct HarmCondition: Codable, Identifiable {
    let id: UUID = UUID()
    var description: String // e.g., "Shattered Hand", "Spiraling Paranoia"
    var penalty: Penalty
}

// The mechanical penalty imposed by a HarmCondition.
enum Penalty: Codable {
    case reduceEffect // All actions are one effect level lower.
    case increaseStressCost(amount: Int) // Pushing yourself or resisting costs more stress.
    case actionPenalty(actionType: String) // A specific action (e.g., "Wreck") is at a disadvantage (e.g., -1d).
    // Future penalties could include locking an action entirely.
}

// HarmState now holds specific conditions instead of just strings.
struct HarmState: Codable {
    var lesser: [HarmCondition] = []
    var moderate: [HarmCondition] = []
    var severe: [HarmCondition] = []
}
GameViewModel.swift (Updates)

We need to update calculateProjection to reflect these penalties before the roll.

Swift

// In GameViewModel.swift

func calculateProjection(for action: ActionOption, with character: Character) -> String {
    var diceCount = character.actions[action.actionType] ?? 0
    var position = action.position
    var effect = action.effect
    var notes: [String] = []

    // Apply penalties from all active harm conditions
    let allHarm = character.harm.lesser + character.harm.moderate + character.harm.severe
    for condition in allHarm {
        switch condition.penalty {
        case .reduceEffect:
            effect = effect.decreased() // We'll need to add this helper function to the enum
            notes.append("(-1 Effect from \(condition.description))")
        case .actionPenalty(let actionType) where actionType == action.actionType:
            diceCount -= 1
            notes.append("(-1d from \(condition.description))")
        default:
            break
        }
    }
    diceCount = max(diceCount, 0) // Can't roll negative dice

    let notesString = notes.isEmpty ? "" : " " + notes.joined(separator: ", ")
    return "Roll \(diceCount)d6. Position: \(position.rawValue), Effect: \(effect.rawValue)\(notesString)"
}

// We'll also need a helper on RollEffect enum in Models.swift
enum RollEffect: String, Codable {
    // ... cases
    func decreased() -> RollEffect {
        switch self {
        case .great: return .standard
        case .standard: return .limited
        case .limited: return .limited
        }
    }
}
```

### `Docs/S6_MechanicalDepth/3-Treasures.md`

```

Task 3: Introduce "Treasures" for Intra-Run Progression
Treasures are the "loot" of this game. They are the primary way players will gain these new Modifiers, creating a satisfying progression loop within a single run.

Action: Create a Treasure model that can grant Modifiers.
Action: Create a new Consequence type to allow players to gain treasures.
Models.swift (Updates)

Swift

// In Models.swift

struct Treasure: Codable, Identifiable {
    let id: UUID = UUID()
    var name: String
    var description: String
    var grantedModifier: Modifier // The benefit this treasure provides
}

// Add to the Character struct
struct Character: Identifiable, Codable {
    // ...
    var treasures: [Treasure] = []
    var modifiers: [Modifier] = []
}

// Add a new case to the Consequence enum
enum Consequence: Codable {
    // ... existing cases
    case gainTreasure(treasure: Treasure)
}
GameViewModel.swift (Updates)

We need to update our consequence processor to handle gaining treasures.

Swift

// In processConsequences() in GameViewModel

case .gainTreasure(let treasure):
    if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
        // Add the treasure to their inventory
        gameState.party[charIndex].treasures.append(treasure)
        // AND add its modifier to their active modifiers
        gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
        descriptions.append("Gained Treasure: \(treasure.name)!")
    }
Now, we can update our generateDungeon function to include a treasure as a reward:

Swift

// In generateDungeon(), inside an interactable's outcomes
let pedestalID = UUID()
let pedestalInteractable = Interactable(
    id: pedestalID,
    title: "Trapped Pedestal",
    //...
    outcomes: [
        .success: [
            .removeInteractable(id: pedestalID),
            .gainTreasure(treasure: Treasure(
                name: "Lens of True Sight",
                description: "This crystal lens reveals hidden things.",
                grantedModifier: Modifier(
                    improveEffect: true,
                    applicableToAction: "Survey",
                    uses: 2,
                    description: "from Lens of True Sight"
                )
            ))
        ],
        .failure: [.sufferHarm(level: .lesser, description: "Electric Jolt")]
    ]
)
```

### `Docs/S6_MechanicalDepth/2-GeneralPurposeModifiers.md`

```

Task 2: Implement a General-Purpose Modifier System
This system will allow items, boons, or special circumstances to temporarily grant bonuses to a roll.

Action: Define a Modifier model.
Action: Add a list of active modifiers to the Character model.
Models.swift (Additions)

Swift

// In Models.swift, a universal modifier struct.

struct Modifier: Codable {
    var bonusDice: Int = 0
    var improvePosition: Bool = false // e.g., Risky -> Controlled
    var improveEffect: Bool = false   // e.g., Standard -> Great
    var applicableToAction: String? = nil // Optional: only applies to a specific action like "Tinker"
    var uses: Int = 1 // How many times it can be used. -1 for infinite.
    var description: String // e.g., "From 'Fine Tools'"
}

// Add to the Character struct
struct Character: Identifiable, Codable {
    // ... existing properties
    var modifiers: [Modifier] = []
}
```

### `Docs/S12_ThreatAndScenarioInfrastructure/4-MainMenuAndScenarioSelect.md`

```

## Task 4: Main Menu & Scenario Selection

**Goal:** Create a welcoming main menu, support starting a new game, continuing a saved run, and scenario selection.

**Actions:**
- Implement `MainMenuView.swift`:
    - Buttons for "Start New Game", "Continue", "Scenario Select", "Settings" (placeholder).
    - Scenario Select: Reads scenario list from content folder, displays with title and blurb.
- Wire up navigation to game, scenario loader, and save system.
```

### `Docs/S12_ThreatAndScenarioInfrastructure/1-ImplementThreatInteractables.md`

```

## Task 1: Implement Threat Interactables (Enemy/Hazard Encounters)

**Goal:** Allow rooms to contain "Threats" that must be resolved before any other actions or movement can be taken. Expresses enemies, environmental hazards, or narrative crises without requiring a combat subsystem.

**Actions:**
- Add a `subtype: "threat"` (or `isThreat: true`) property to Interactable model and content schema.
- Update node rendering logic: If a Threat is present in the current node, disable/hide all other interactables and navigation.
- In UI, visually differentiate Threats from normal interactables (e.g., red border, warning icon).
- Update InteractableCardView to render threat status.
- Playtest with sample Threats (e.g., monster, reactor breach).
```

### `Docs/S12_ThreatAndScenarioInfrastructure/2-AddDungeonMap.md`

```

## Task 2: Add Dungeon Map Screen

**Goal:** Provide a map UI so the player can see explored nodes, connections, and their current location.

**Actions:**
- Create `MapView.swift`:  
  - Draw nodes as circles/squares, connections as lines.
  - Show discovered vs. undiscovered nodes.
  - Highlight current party location.
- Add "Show Map" button to main game UI to present MapView as a modal/sheet.
- Wire MapView to read from GameState’s dungeon model.
```

### `Docs/S12_ThreatAndScenarioInfrastructure/5-SaveAndLoadSystem.md`

```

## Task 5: Save & Load System

**Goal:** Persist and restore game state, allowing “Continue” after quitting.

**Actions:**
- Add serialization helpers to GameState (Codable).
- Implement `saveGame()` and `loadGame()` methods using UserDefaults or local file storage.
- Save after significant actions, auto-save at game over, and on quit.
- "Continue" loads saved state and resumes scenario.
- Main menu disables Continue if no save exists.
```

### `Docs/S12_ThreatAndScenarioInfrastructure/3-ModularizeScenarioLoading.md`

```

## Task 3: Modularize Scenario Loading

**Goal:** Support multiple scenarios as discrete content bundles, with plug-and-play architecture for scenario selection and loading.

**Actions:**
- Refactor ContentLoader:
    - Accept a scenario id/name and load content (`interactables.json`, `harm_families.json`, etc.) from a scenario-specific directory.
    - Add a `scenario.json` manifest with metadata: title, description, entry node, etc.
- Support fallback/default content for missing fields (for backwards compatibility).
- Playtest with two scenario folders ("tomb", "test_lab").
```

### `Docs/S11_UIClarity/2-IntegrateModiferAndPenaltyInfoInDiceRollView.md`

```

Task 2: Integrate Modifier/Penalty Info into DiceRollView Projection
Description: The calculateProjection string is good, but we need to make it explicitly clear why the dice pool, Position, or Effect might be different from their base values, especially due to Harm penalties or active Modifiers. The DiceRollView itself should also visually hint at these changes.

Implementation Plan:

Refactor GameViewModel.calculateProjection:
Instead of returning a simple String, modify it to return a new struct, e.g., RollProjectionDetails.
Swift

struct RollProjectionDetails {
    var baseDiceCount: Int
    var finalDiceCount: Int
    var basePosition: RollPosition
    var finalPosition: RollPosition
    var baseEffect: RollEffect
    var finalEffect: RollEffect
    var notes: [String] // e.g., ["-1d from Shattered Hand", "+1 Effect from Lens (1 use left)"]
}
The function should calculate the base values, then iterate through active HarmCondition penalties and applicable Modifier bonuses, adjusting the finalDiceCount, finalPosition, finalEffect, and populating the notes array.
Update DiceRollView.swift:
When presenting the pre-roll information (before result is set), use the RollProjectionDetails.
Display the finalDiceCount, finalPosition, and finalEffect prominently.
Below this, list each string from projectionDetails.notes. Use color-coding: red for notes originating from Harm, green or blue for notes from Modifiers/Treasures.
If a modifier is about to be consumed (e.g., a Treasure with uses: 1), make this clear in the notes (e.g., "Lens of True Sight will be consumed").
Visual Cues for ActionOption Buttons:
In InteractableCardView.swift, before an action is even tapped, if a selected character has a Harm penalty directly affecting an actionType for one of the availableActions (e.g., "Brain Lightning" banAction for "Study"), visually indicate this on the button itself.
This could be greying out the button slightly, adding a "cracked" overlay, or a small warning icon. This requires InteractableCardView to have access to the selectedCharacter's state or for ContentView to pass down pre-calculated penalty info.
Asset Callouts:

icon_penalty_action.png: A small, dithered red "X" or "broken tool" icon to overlay on an action button if it's negatively affected by Harm.
Canvas Size: 48x48 pixels (to be scaled down next to button text).
icon_bonus_action.png: A small, dithered green/cyan "+" or "star" icon if an action is positively affected by a Modifier.
Canvas Size: 48x48 pixels.
```

### `Docs/S11_UIClarity/1-EnhanceCharacterStatDisplay.md`

```

Task 1: Enhance Character Stat Display in PartyStatusView
Description: The current PartyStatusView shows Stress and Harm icons. Let's make it more comprehensive by clearly listing action ratings and any active Modifiers a character has.

Implementation Plan:

In PartyStatusView.swift, for each character, below their Harm icons, add a new section.
Action Ratings: Display each of the character's actions (e.g., "Study: 3," "Tinker: 2") in a compact list or grid.
Active Modifiers: If a character has any active modifiers from their treasures, list their descriptions (e.g., "from Lens of True Sight: +1 Effect to Survey (1 use left)").
Consider a distinct visual treatment (e.g., a different color, a small icon next to them) for active modifiers.
```

### `Docs/S11_UIClarity/3-FeedbackForModifierConsumption.md`

```

Task 3: Explicit Feedback for Modifier Consumption
Description: When a Treasure's Modifier with limited uses is consumed, provide clear feedback that it happened.

Implementation Plan:

GameViewModel.performAction():
When applying Modifiers, if a modifier has its uses decremented to 0 (or removed if it was the last use), this information should be part of the DiceRollResult.consequences string. E.g., "Used up Lens of True Sight."
DiceRollView.swift: The result.consequences text will automatically display this.
PartyStatusView.swift: This view will naturally update as the character's modifiers list changes (as GameViewModel is an @ObservedObject), so consumed modifiers will disappear from the list.
Sound Effect (Optional but Recommended):
Play a distinct sound effect when a limited-use modifier is consumed.
Asset Callouts:

Audio:
sfx_modifier_consume.wav: A short, slightly "magical" or "vanishing" sound (e.g., a quick shimmer or puff).
```

### `Docs/PRD.md`

```

Forged in the Tomb: A Product Requirements Document
Project: Forged in the Tomb
Platform: iPhone (SwiftUI)
Version: 1.0

1. Overview
Forged in the Tomb is a single-player, rogue-lite dungeon crawl for iOS, built with SwiftUI. It draws inspiration from the high-stakes, trap-filled exploration of the classic D&D module "Tomb of Horrors" and the adventurous spirit of the Indiana Jones franchise. The game will leverage a simplified interpretation of the Forged in the Dark (FitD) tabletop roleplaying game's core mechanics, specifically its dice, stress, and harm systems, which are available under a creative commons license. The gameplay will eschew traditional combat, focusing instead on overcoming environmental hazards, disarming traps, and deciphering cryptic curses.

The game will be structured as a node-based crawl, with players navigating a procedurally generated dungeon. Each run will feature a randomly rolled party of three adventurers, each with unique starting statistics and equipment. The core gameplay loop will revolve around players selecting a character to interact with various "Interactables" within each node, using a chosen statistic to make a roll. A key feature will be the "dice roll projection" which will clearly communicate the potential outcomes (position and effect) to the player before they commit to an action.

2. Goals
To create a compelling and challenging single-player, rogue-lite experience on iOS.
To successfully translate the core tension and player agency of the Forged in the Dark system into a digital format.
To deliver a unique dungeon crawl experience by focusing on non-combat challenges.
To build a robust and scalable architecture in SwiftUI that can be expanded with new content in the future.
To establish a clear and intuitive user interface centered around a "card" metaphor for interactable elements.
3. Target Audience
Players of tabletop roleplaying games, particularly those familiar with Forged in the Dark or other narrative-driven systems.
Fans of rogue-lite and dungeon crawl genres on mobile platforms.
Players who enjoy puzzle-solving and strategic decision-making over fast-paced action.
Admirers of the "Tomb of Horrors" and Indiana Jones style of adventure.
4. Core Mechanics
4.1. The Dice Roll
All actions that involve risk or uncertainty are resolved by a dice roll. The player will assemble a pool of six-sided dice (d6) based on their character's chosen Action Rating. The number of dice in the pool will typically be between one and four. The player rolls the dice and the single highest result determines the outcome:

6: Full Success. The character achieves their goal without any negative consequences.
4-5: Partial Success. The character achieves their goal, but at a cost. This could be taking Stress, suffering Harm, or some other complication.
1-3: Failure. The character fails to achieve their goal and suffers a consequence.
A Critical Success occurs when multiple sixes are rolled. This will result in an enhanced effect or an additional benefit.

4.2. Position & Effect
Before a player commits to a roll, the game will display a "dice roll projection" that communicates the Position and Effect of the action.

Position: This represents the level of risk involved in the action. There are three positions:

Controlled: A failed roll has a minor consequence.
Risky: A failed roll has a standard consequence. This is the default position.
Desperate: A failed roll has a severe consequence.
Effect: This represents the potential level of reward or impact of a successful action. There are three effect levels:

Limited: A less-than-ideal outcome.
Standard: The expected outcome.
Great: A more-than-ideal outcome.
The player's choice of action and the current circumstances will determine the initial Position and Effect.

4.3. Stress
Stress is a resource that players can spend to improve their odds or mitigate negative outcomes. Each character has a Stress track (e.g., 0-9). Players can choose to take Stress to:

Push Themselves: Gain +1d to their dice pool for a roll.
Resist a Consequence: Reduce the severity of a negative outcome. The cost in Stress is determined by a resistance roll.
If a character's Stress track is filled, they suffer Trauma.

4.4. Harm & Trauma
Harm represents physical and mental injuries. Harm comes in levels of severity:

Level 1: Lesser (e.g., "Shaken," "Bruised")
Level 2: Moderate (e.g., "Gashed Arm," "Concussion")
Level 3: Severe (e.g., "Broken Leg," "Cursed")
Each level of Harm imposes a penalty on the character's actions. If a character suffers Harm when all slots of that severity are full, the Harm is upgraded to the next level. If a character with a Severe Harm takes another, they are taken out of the current run.

Trauma is a permanent negative trait a character gains when their Stress track is filled. Each Trauma condition will have a specific mechanical and narrative effect. Accumulating a certain number of Traumas will force a character's retirement from the party.

5. Game Structure
5.1. The Rogue-lite Loop
Party Generation: The player begins a new run with a randomly generated party of three characters. Each character will have a "class" with unique starting stats and gear.
Dungeon Crawl: The player navigates the node-based dungeon.
Interactables: Within each node, the player will encounter Interactables presented as cards.
Action & Resolution: The player chooses a character and an action to interact with the card, leading to a dice roll.
Consequences & Rewards: The outcome of the roll determines the rewards (e.g., new paths, loot, information) and consequences (e.g., Stress, Harm, environmental changes).
Perma-death (for the run): Characters taken out by Harm are gone for the remainder of the run. If all characters are defeated, the run ends.
Meta-Progression: Successful runs will unlock new character classes, starting gear, and potentially new dungeon types for future runs.
5.2. The Dungeon: A Node Crawl
The dungeon will be represented as a map of interconnected nodes. The player's party will occupy a single node at a time. Connections between nodes may be initially hidden or locked, requiring successful checks to reveal or open them. Each node will contain one or more "Interactables."

6. User Interface & User Experience (UI/UX)
6.1. The "Card" Metaphor
The primary visual metaphor for interacting with the game world will be through "cards." Each Interactable (e.g., a trapped chest, a mysterious lever, a cryptic riddle) will be presented as a card. The card will contain:

A title and descriptive text.
An illustration of the Interactable.
A list of possible actions a player can take, along with the corresponding stat to be used.
Tapping on an action will bring up the "dice roll projection" view, showing the Position and Effect before the player confirms the roll.

6.2. Main Screens
Main Menu: Start New Run, Continue Run, Unlocks/Meta-Progression, Settings.
Party View: Shows the status of the three party members, including their stats, Stress, Harm, and equipment.
Dungeon Map View: Displays the node map, the party's current location, and known connections.
Node View: The primary gameplay screen, displaying the Interactable cards for the current node.
Dice Roll Projection View: A modal view that appears before a roll, detailing the Position, Effect, and any modifiers.
7. Content
7.1. Character Classes
Each class will have a unique set of starting Action Ratings and a special ability. Examples include:

The Archaeologist: High in Study and Tinker. Special Ability: Once per run, can automatically succeed at a roll to decipher ancient texts.
The Brawler: High in Wreck and Finesse. Special Ability: Can take an extra level of Harm before being taken out.
The Mystic: High in Attune and Survey. Special Ability: Can spend Stress to have a vision about a nearby node.
7.2. Action Ratings
Action Ratings will be simplified from the full FitD set to better suit the non-combat focus. Examples include:

Study: Deciphering texts, understanding mechanisms.
Survey: Spotting hidden dangers, finding secret passages.
Tinker: Disarming traps, repairing gear.
Finesse: Delicate movements, sleight of hand.
Wreck: Applying brute force.
Attune: Sensing supernatural energies, resisting curses.
7.3. Interactables
Interactables will be the core of the gameplay. They will be designed to present interesting choices and challenges that can be overcome in multiple ways, depending on the chosen character and action. Examples:

A Pressure Plate: Can be Tinkered with to disarm, Finessed across to avoid, or Wrecked to trigger from a safe distance.
A Cursed Idol: Can be Attuned with to understand the curse, Studied to find a weakness, or Wrecked from afar.
8. Technical Considerations
Engine: SwiftUI. The declarative nature of SwiftUI is well-suited for the card-based UI and displaying dynamic information like the dice roll projection.
Architecture: A Model-View-ViewModel (MVVM) architecture is recommended to separate the game logic from the UI.
Data Persistence: Player progress, unlocks, and run state will be saved locally using Swift's Codable and UserDefaults or a more robust solution like Core Data if necessary.
Procedural Generation: The dungeon layout, node connections, and Interactable placement will be procedurally generated at the start of each run to enhance replayability.
9. Future Development
Content Expansion: New character classes, dungeon types, Interactables, and enemy factions (though not in a traditional combat sense) can be added as updates.
9.1. The "Clocks" Mechanic (Addendum to PRD)
Clocks are visual progress trackers used for complex or ongoing challenges that cannot be resolved with a single action. Examples include: "The Guards' Suspicion," "Disarming the Complex Trap," or "Deciphering the Ancient Mural."

Structure: A clock is represented as a segmented circle (e.g., 4, 6, or 8 segments).
Progression: Successful actions can fill in one or more segments of a clock. The Effect level of the roll determines how many segments are filled (e.g., Limited = 1, Standard = 2, Great = 3).
Complications: Partial successes or failures might add segments to a negative clock (e.g., "Reinforcements Arrive") or introduce a new, linked clock.
Resolution: When a clock is completely filled, the event it represents comes to pass. This can be positive (the trap is disarmed) or negative (the alarm is raised).
UI Implementation: A dedicated, non-intrusive view will display all currently active clocks, allowing the player to track ongoing progress and threats at a glance.
Leaderboards: Integration with Game Center for high score tracking.
iCloud Sync: Allowing players to continue their runs across multiple devices.
Accessibility: Implementing features like Dynamic Type and VoiceOver to ensure the game is playable by a wider audience.
```

### `Docs/S10_ContentPipelineAndGenerationPolish/2-EnhanceDungeonGenerator.md`

```

Task 2: Enhance DungeonGenerator.swift
Now we make the generator smarter and use our new content.

Action: Refactor DungeonGenerator.generate(level: Int) to incorporate more sophisticated logic.
Implementation Plan:
Node Theming/Tagging (Optional but Recommended):
In your MapNode model, consider adding var theme: String? or var tags: [String]?.
The DungeonGenerator can then assign themes (e.g., "corridor," "trap_chamber," "shrine," "antechamber") to nodes as it creates them.
Content Selection based on Theme:
When populating a node, filter content.interactableTemplates based on the node's theme/tags. This makes room content more logical. (e.g., a "trap_chamber" is more likely to get template_pressure_plate).
Clock Generation:
Define a few placeholder clock names/segment counts (e.g., in DungeonGenerator or a new simple JSON like clocks_templates.json).
At the start of generate(), randomly select 1-2 of these and add them to the GameState.activeClocks.
Dynamic Connection Locking & Unlocking:
When creating connections, randomly decide for some of them to set isUnlocked = false.
Crucially: For each locked connection, ensure the generator also places an interactable somewhere in the dungeon (perhaps in a preceding or adjacent node) that has an unlockConnection consequence in its outcomes targeting that specific locked connection's fromNodeID and toNodeID. This requires the generator to keep track of locked doors and the interactables that can unlock them.
Pathfinding Check (Simplified): To ensure the dungeon is solvable, always ensure there's at least one path from startingNodeID to a designated "exit node" (e.g., the last node in your linear generation) that is either initially unlocked or has its unlocking interactable placed in an accessible location. For now, you could just ensure the main chain of nodes is always unlockable.
Treasure Distribution:
Ensure your new Interactable templates with gainTreasure consequences are part of the pool the generator picks from. The current random selection should handle this if the templates exist.
Varying Node Count & Branching (Stretch Goal):
Instead of a purely linear nodeCount, consider a simple branching algorithm. For example, some nodes could have two forward connections instead of one, leading to small dead-end branches with special rewards or dangers.
Updated GameViewModel.startNewRun():
No major changes expected here other than potentially passing more parameters to generator.generate() if you add complexity like a "dungeon seed" or "target difficulty." The primary work is within the DungeonGenerator itself.
```

### `Docs/S10_ContentPipelineAndGenerationPolish/1-ExpandPlaceholderContentJsons.md`

```

Task 1: Expand Placeholder Content Definitions (JSON)
The goal here is not final writing, but to create a diverse set of templates that exercise all your systems.

harm_families.json:

Action: Add 2-3 new HarmFamily definitions.
Details:
One family focused on mental or sensory effects (e.g., "Growing Dread" -> "Hallucinations" -> "Maddening Visions"). Penalties could include increaseStressCost or actionPenalty on Attune or Survey.
One family focused on equipment damage or loss (e.g., "Frayed Rope" -> "Broken Tools" -> "Lost Map"). Penalties could banAction for Tinker or make certain Finesse checks automatically result in limited effect.
Example Snippet (to add to your existing JSON structure):
JSON

{
  "id": "mental_anguish",
  "lesser": { "description": "Unease", "penalty": { "type": "increaseStressCost", "amount": 1 } },
  "moderate": { "description": "Fleeting Shadows", "penalty": { "type": "actionPenalty", "actionType": "Survey" } },
  "severe": { "description": "Terror", "penalty": { "type": "reduceEffect" } },
  "fatal": { "description": "Mind Broken" }
}
treasures.json:

Action: Add 3-5 new Treasure definitions.
Details: Aim for variety in the grantedModifier.
One that grants bonusDice to a specific action type.
One that improvePosition for one use.
One that grants a temporary (1-2 uses) resistance to a specific HarmFamily (this would require a new Modifier type or a very specific description and manual check in applyHarm if we want to avoid model changes for now). For simplicity this sprint, let's stick to existing modifier types.
One that is purely narrative or unlocks a specific, rare interactable if we want to go complex (can be just text for now).
Example Snippet:
JSON

{
  "id": "treasure_steadying_herbs",
  "name": "Steadying Herbs",
  "description": "Chewing these calms the nerves, for a time.",
  "grantedModifier": {
    "improvePosition": true,
    "uses": 1,
    "description": "from Steadying Herbs"
  }
}
interactables.json:

Action: Add 5-7 new Interactable templates. This is where we test the breadth of the Consequence system.
Details: Each template should vary:
Action Types Used: Ensure all your action types (Study, Wreck, Finesse, Tinker, Attune, Survey) are used.
Position/Effect Defaults: Mix these up.
Consequences:
Have outcomes that apply the new Harm Families.
Have outcomes that tickClock on different named clocks (e.g., "Ancient Machinery Grinds," "The Walls Are Closing In").
Have outcomes that gainTreasure using your new treasure templates.
Have outcomes that unlockConnection (we'll make the generator use this).
Have outcomes that removeInteractable (itself or another specific placeholder ID if we want linked interactables).
Have outcomes that addInteractable (e.g., successfully disarming a trap reveals a treasure chest interactable).
Example Snippet (for one new interactable):
JSON

{
  "id": "template_crumbling_ledge",
  "title": "Crumbling Ledge",
  "description": "A narrow ledge over a dark chasm. It looks unstable.",
  "availableActions": [
    {
      "name": "Cross Carefully",
      "actionType": "Finesse",
      "position": "desperate",
      "effect": "standard",
      "outcomes": {
        "success": [
          { "type": "removeInteractable", "id": "self" } // Ledge is crossed
        ],
        "partial": [
          { "type": "gainStress", "amount": 2 },
          { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
        ],
        "failure": [
          { "type": "sufferHarm", "level": "moderate", "familyId": "leg_injury" },
          { "type": "tickClock", "clockName": "Chasm Peril", "amount": 2 }
        ]
      }
    },
    {
      "name": "Test its Stability",
      "actionType": "Survey",
      "position": "risky",
      "effect": "limited",
      "outcomes": {
        "success": [
          // Could add a temporary modifier: "Insight: Ledge is weak" +1d Finesse
        ],
        "failure": [
           { "type": "gainStress", "amount": 1 }
        ]
      }
    }
  ]
}
```

### `Docs/S10_ContentPipelineAndGenerationPolish/Side-ModelAndLoaderTweaks.md`

```

Minor Model/Loader Adjustments
Action: As you define new content, if you realize a new type of Consequence, Penalty, or Modifier is essential for a placeholder idea, update Models.swift accordingly.
Details: Ensure any new enum cases or struct properties are Codable and that ContentLoader.swift and your custom init(from decoder: Decoder) / encode(to encoder: Encoder) methods can handle them. The goal is to support the content, not to add entirely new game systems unless absolutely necessary for variety.
```

### `Docs/S9_GameJuice/1-AmbientWorld.md`

```

Ticket 1: Ambient World
Description: Make the dungeon feel like a real place by giving each room a subtle, looping ambient soundscape. We'll also replace the default view transition with a more thematic "sliding stone door" effect when moving between nodes.

Implementation Plan:

Ambient Audio:
Create a simple AudioManager singleton class to handle playback of background audio. It will need functions like play(sound: String, loop: Bool) and stop().
In GameViewModel.swift, when calling move(to:), also call AudioManager.shared.play(sound: "ambient_\(newNode.soundProfile).wav", loop: true).
We'll add a new property to our MapNode model, var soundProfile: String, which we can set in our content files (e.g., "cave_drips", "chasm_wind").
Thematic Transition:
Instead of the default .transition(.opacity) on the content VStack in ContentView, we will use a .matchedGeometryEffect.
We will create a "door" view that slides across the screen. We can achieve this with a ZStack in ContentView. When a move is initiated, we'll show a black rectangle (our door) that animates its width from 0 to the screen's full width, and then back to 0, revealing the new content underneath.
Asset Callouts:

Audio (Ambient Loops):
ambient_cave_drips.wav: A quiet, sparse loop of echoing water drips.
ambient_chasm_wind.wav: A low, windy rumble with an occasional pebble-skittering sound.
ambient_silent_tomb.wav: Mostly silence, with a very faint, deep hum.
Audio (Transitions):
sfx_stone_door_slide.wav: A heavy, scraping sound of stone on stone to play during the screen transition.
Visual:
texture_stone_door.png: A full-screen tiling image of dithered, retro-style stone. This will be used for the transition view instead of a plain black color.
Canvas Size: 256x256 pixels. (A square, power-of-two texture is efficient for tiling.)
```

### `Docs/S9_GameJuice/3-ThematicStatusVisualization.md`

```

Ticket 3: Thematic Status Visualization
Description: Replace the default ProgressView bars for Stress and Harm with custom-drawn, thematic icons that better reflect the game's aesthetic and provide clearer at-a-glance information.

Implementation Plan:

Stress Pips: In PartyStatusView.swift, remove the ProgressView for Stress. Replace it with an HStack that iterates from 1 to 9. For each number, draw a "pip" icon. If the character's stress is greater than or equal to the pip's number, the pip is "lit"; otherwise, it's "unlit."
Harm Icons: Remove the three harm ProgressViews. Replace them with a single HStack.
Draw two "Lesser" icons. For each filled lesser harm slot, draw the "cracked" version of the icon.
Draw two "Moderate" icons. For each filled moderate harm slot, draw its cracked version.
Draw one "Severe" icon. If the severe slot is filled, draw its cracked version.
Asset Callouts:

Visual (Stress):
icon_stress_pip_unlit.png: A small, dithered gray or dark purple circle or rune.
Canvas Size: 48x48 pixels.
icon_stress_pip_lit.png: The same icon, but with a bright, ominous purple or red dithered glow.
Canvas Size: 48x48 pixels.
Visual (Harm): We'll use a "cracked skull" motif.
icon_harm_lesser_empty.png: A small, simple, dithered skull icon.
Canvas Size: 64x64 pixels.
icon_harm_lesser_full.png: The same skull with a single, dithered crack on it.
Canvas Size: 64x64 pixels.
icon_harm_moderate_empty.png: A slightly more detailed/angular skull icon.
Canvas Size: 64x64 pixels.
icon_harm_moderate_full.png: The moderate skull with more severe, branching cracks.
Canvas Size: 64x64 pixels.
icon_harm_severe_empty.png: A stylized, grim-looking skull.
Canvas Size: 64x64 pixels.
icon_harm_severe_full.png: The severe skull, heavily cracked and possibly with a red dithered glow in one eye socket.
Canvas Size: 64x64 pixels.
```

### `Docs/S9_GameJuice/2-HighStakesDiceRolls.md`

```

Ticket 2: The High-Stakes Dice Roll
Description: The dice roll is the moment of truth. We'll make it a physical, multi-stage animation with clear visual feedback, combining several ideas from your brainstorm.

Implementation Plan:

Shake & Roll: In DiceRollView, on button press, trigger a 1-second animation where the dice images are given small, random x/y offsets and rotation effects to "shake."
Highlight Result: After the performAction logic runs, instead of just showing the text, we'll start a new animation.
The dice that did not contribute to the highest roll will have their opacity animated to 0.5.
The single highest-rolling die will animate its scale to 1.3x and back down to 1.0x (a "pop" effect) and gain a temporary glow using .shadow(color: .cyan, radius: 10).
Animate Outcome Text: The Text(result.outcome) view will be modified with .transition(.scale.combined(with: .opacity)) and we will wrap its appearance in a withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) block to make it pop onto the screen.
Asset Callouts:

Audio:
sfx_dice_shake.wav: A short, lo-fi rattling sound.
sfx_dice_land.wav: A single sharp "clack" sound.
sfx_ui_pop.wav: A satisfying "pop" to accompany the highest die and result text scaling up.
Visual:
vfx_damage_vignette.png: A full-screen, mostly transparent PNG. The edges should have a dithered red or black pattern. We can flash this on screen for a split second along with the shake to amplify the effect.
Canvas Size: 1024x1024 pixels. (A large square allows it to be scaled to fit any device screen without distortion.)
```

### `Docs/S13_ExpressiveActionsAndTags/1-ImplementFreeActions.md`

```

## Task 1: Implement Free Actions (Non-Test Actions)

**Goal:** Allow Interactables to present actions that do **not require a dice roll**, but simply execute their Consequences—unlocking narrative, utility, or environmental interactions without unnecessary randomness.

### Actions:
- Add a `requiresTest: Bool = true` property to the `ActionOption` model (defaulting to `true` for backwards compatibility).
- Update InteractableCardView:
    - If `requiresTest` is `false`, skip DiceRollView and process the `.success` consequences directly when the button is tapped.
    - Optionally, visually distinguish free actions (e.g., special icon, color, or label like “Automatic”).
- Update content schema and loader to allow `requiresTest: false` in JSON.
- Add/test example interactables such as levers, switches, readable inscriptions, or safe item pickups.
- (Optional stretch) Allow for consequences with costs (e.g., “Spend 1 Stress” for an automatic action).
```

### `Docs/S13_ExpressiveActionsAndTags/2-AddTagSystem.md`

```

## Task 2: Add a Tag System for Treasures (and Interactables)

**Goal:** Make Treasures and Interactables richer by supporting a flexible, composable “tags” system—enabling scenario logic and emergent design patterns without hardcoding.

### Actions:
- Add a `tags: [String] = []` property to the `Treasure` struct.
    - Update `treasures.json` format to allow a `"tags": [...]` array.
- Add an optional `tags: [String] = []` property to the `Interactable` struct.
    - Update `interactables.json` accordingly.
- Expose tags in the UI (as icon chips or small labels) for treasures (and optionally interactables).
- Update the scenario design language:
    - Document how to check for tags on treasures when evaluating interactable options or consequences.
    - Support action gating or bonuses in interactables based on tag presence (e.g., “If any party member has a Treasure tagged Light Source, reveal secret passage”).
- (Optional stretch) Allow tags to gate additional ActionOptions or Consequence branches in future scenario logic.
- Add a few test treasures (e.g., “Cursed Lantern” with tags `[“Haunted”, “Light Source”]`) and at least one interactable or scenario effect that checks tags.
```

### `Docs/S13_ExpressiveActionsAndTags/3-DocumentationAndExamples.md`

```

## Task 3: Documentation and Content Examples

**Goal:** Make these systems self-documenting for future contributors or content designers.

### Actions:
- Add JSON schema/documentation for ActionOption’s `requiresTest`, and for Treasure/Interactable `tags` fields.
- Add example entries to `treasures.json` and `interactables.json` demonstrating proper usage.
- Write a brief “how to use tags” guide or sample code for checking tags in scenario logic.
```

### `Docs/S4_FullGameLoop/1-DynamicActionConsequences.md`

```

Task 1: Create Dynamic Action Consequences
Right now, succeeding at an action only adds ticks to a clock. We need a system where actions can have specific, tangible outcomes, like unlocking a path or disabling an interactable.

Action: Introduce a Consequence model and link it to roll outcomes.
Action: Refactor performAction to process these new consequences.
Models.swift (Additions)

Swift

// In Models.swift

// Add an optional ID to Interactable to make it easier to find and remove
struct Interactable: Codable, Identifiable {
    let id: UUID = UUID() // NEW
    var title: String
    //...
}

// Define the types of consequences an action can have
enum Consequence: Codable {
    case gainStress(amount: Int)
    case sufferHarm(level: HarmLevel, description: String)
    case tickClock(clockName: String, amount: Int)
    case unlockConnection(fromNodeID: UUID, toNodeID: UUID)
    case removeInteractable(id: UUID)
    case addInteractable(inNodeID: UUID, interactable: Interactable)
    // We can add many more types later (gain item, etc.)
}

enum HarmLevel: String, Codable { case lesser, moderate, severe }

// Update ActionOption to include specific consequences for each outcome
struct ActionOption: Codable {
    // ... existing properties
    var outcomes: [RollOutcome: [Consequence]]
}

// Define a key for the dictionary
enum RollOutcome: String, Codable { case success, partial, failure }
GameViewModel.swift (Major Refactor)
This is the key task. We'll update an interactable to use this new system and refactor performAction to be a generic consequence processor.

Swift

// In generateDungeon(), update the "Sealed Stone Door" interactable
let stoneDoorID = UUID()
let doorInteractable = Interactable(
    id: stoneDoorID,
    title: "Sealed Stone Door",
    description: "A massive circular door covered in dust.",
    availableActions: [
        ActionOption(
            name: "Examine the Mechanism",
            actionType: "Study",
            position: .controlled,
            effect: .standard,
            outcomes: [ // The new outcomes dictionary
                .success: [
                    .unlockConnection(fromNodeID: startNodeID, toNodeID: secondNodeID),
                    .removeInteractable(id: stoneDoorID)
                ],
                .partial: [.gainStress(amount: 1)],
                .failure: [.tickClock(clockName: "The Guardian Wakes", amount: 1)]
            ]
        )
    ]
)

// In GameViewModel, refactor performAction
func performAction(for action: ActionOption, with character: Character) -> DiceRollResult {
    // ... (keep the dice rolling logic) ...

    var consequencesToApply: [Consequence] = []
    var outcomeString = ""

    switch highestRoll {
    case 6:
        outcomeString = "Full Success!"
        consequencesToApply = action.outcomes[.success] ?? []
    case 4...5:
        outcomeString = "Partial Success..."
        consequencesToApply = action.outcomes[.partial] ?? []
    default:
        outcomeString = "Failure."
        consequencesToApply = action.outcomes[.failure] ?? []
    }
    
    // Process the consequences
    let consequencesDescription = processConsequences(consequencesToApply, forCharacter: character)

    return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
}

private func processConsequences(_ consequences: [Consequence], forCharacter character: Character) -> String {
    var descriptions: [String] = []
    for consequence in consequences {
        switch consequence {
        case .gainStress(let amount):
            if let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                gameState.party[charIndex].stress += amount
                descriptions.append("Gained \(amount) Stress.")
            }
        // ... Implement cases for .sufferHarm, .tickClock, etc.
        case .unlockConnection(let fromNodeID, let toNodeID):
            if let fromNodeIndex = gameState.dungeon?.nodes.firstIndex(where: { $0.key == fromNodeID }),
               let connIndex = gameState.dungeon?.nodes[fromNodeID]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                gameState.dungeon?.nodes[fromNodeID]?.connections[connIndex].isUnlocked = true
                descriptions.append("A path has opened!")
            }
        case .removeInteractable(let id):
            if let nodeID = gameState.currentNodeID {
                gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == id })
                descriptions.append("The way is clear.")
            }
        default:
            break
        }
    }
    return descriptions.joined(separator: "\n")
}

```

### `Docs/S4_FullGameLoop/3-ImplementRoguelikeRuns.md`

```

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
```

### `Docs/S4_FullGameLoop/2-ImproveUIFeedback.md`

```

Task 2: Improve UI Feedback
Let's make our status displays more visually appealing than plain text.

Action: Create a proper, graphical ClockView that shows a segmented circle.
Action: Enhance PartyStatusView to show stress/harm bars.
ClockView.swift (Graphical Update)
There are many ways to draw a clock. Here's a simple approach using Circle and trim.

Swift

// In ClocksView.swift, replace the Text with a graphical representation
struct GraphicalClockView: View {
    let clock: GameClock
    
    var body: some View {
        VStack {
            Text(clock.name).font(.caption)
            ZStack {
                Circle().stroke(lineWidth: 10).opacity(0.3)
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(clock.progress) / CGFloat(clock.segments), 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: 270.0))
                Text("\(clock.progress)/\(clock.segments)")
            }
            .frame(width: 60, height: 60)
        }
    }
}
// Then in ClocksView, use this in a ScrollView:
// ScrollView(.horizontal) { HStack { ForEach(...) { GraphicalClockView(...) } } }
```

### `Docs/S1_CoreSlice/3-BasicUI.md`

```

Task 3: Building the UI (The "View")
Action: Create the most basic possible views to display the state and trigger actions. Use placeholder UI and minimal styling for now.

PartyStatusView.swift:

Displays a list of the characters.
For each character, shows their name, stress, and harm levels.
This view will read from the GameViewModel.
ClocksView.swift:

Displays a list of active clocks.
For each clock, shows its name and a simple text representation of its progress (e.g., "2 / 6").
ContentView.swift (Main Game Screen):

Instantiate the @StateObject var viewModel = GameViewModel().
Display the PartyStatusView and ClocksView.
Display a single, hardcoded "Interactable Card" for a "Trapped Pedestal".
The card will have buttons for its availableActions (e.g., "Tinker with it," "Study the Glyphs").
Tapping an action button will:
Present a simple Alert or modal sheet showing the output from viewModel.calculateProjection().
The alert will have a "Roll" button that calls viewModel.performAction().
```

### `Docs/S1_CoreSlice/1-ProjectSetupAndCoreDataModels.md`

```

Task 1: Project Setup & Core Data Models (The "Model" part of MVVM)
Action: Set up a new SwiftUI project in Xcode.

Action: Create the initial data model structs. These should be simple, Codable, and Identifiable where appropriate.

Swift

// In a file named Models.swift

struct GameState {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    // ... other global state
}

struct Character: Identifiable {
    let id = UUID()
    var name: String
    var characterClass: String
    var stress: Int
    var harm: HarmState
    var actions: [String: Int] // e.g., ["Study": 2, "Tinker": 1]
}

struct HarmState {
    var lesser: [String] = []
    var moderate: [String] = []
    var severe: [String] = []
}

struct GameClock: Identifiable {
    let id = UUID()
    var name: String
    var segments: Int // e.g., 6
    var progress: Int
}

// Models for the interactable itself
struct Interactable {
    var title: String
    var description: String
    var availableActions: [ActionOption]
}

struct ActionOption {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
}

enum RollPosition { case controlled, risky, desperate }
enum RollEffect { case limited, standard, great }
```

### `Docs/S1_CoreSlice/2-ViewModelGameLogicEngine.md`

```

Task 2: The Game Logic Engine (The "ViewModel")
Action: Create the main GameViewModel. This will be the heart of our sprint.

Swift

// In a file named GameViewModel.swift
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    init() {
        // For the sprint, we'll use hardcoded starting data.
        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ]
        )
    }

    // --- Core Logic Functions for the Sprint ---

    // Calculates the projection before the roll
    func calculateProjection(for action: ActionOption, with character: Character) -> String {
        // Logic to determine base dice pool from character.actions[action.actionType]
        // For now, just return a descriptive string.
        let diceCount = character.actions[action.actionType] ?? 0
        return "Roll \(diceCount)d6. Position: \(action.position), Effect: \(action.effect)"
    }

    // The main dice roll function
    func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) {
        // 1. Get dice pool from character stats.
        // 2. Roll the dice (Int.random(in: 1...6)).
        // 3. Determine outcome (Success, Partial, Failure).
        // 4. Apply consequences/rewards based on Position & Effect.
        //    - On a 4-5 (Partial): self.gameState.party[characterIndex].stress += 2
        //    - On a 1-3 (Failure): self.gameState.party[characterIndex].harm.lesser.append("Bruised")
        //    - On a 6 (Success): Update the clock if a clockID was provided.
        //       if let clockID = clockID { updateClock(id: clockID, ticks: 2) } // 2 for standard effect
        // 5. Ensure the UI updates by modifying the @Published gameState.
    }

    private func updateClock(id: UUID, ticks: Int) {
        if let index = gameState.activeClocks.firstIndex(where: { $0.id == id }) {
            gameState.activeClocks[index].progress = min(gameState.activeClocks[index].segments, gameState.activeClocks[index].progress + ticks)
        }
    }
}
```

### `Docs/S7_AdvancedFitDMechanics/2-ImplementPushYourselfMechanic.md`

```

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
```

### `Docs/S7_AdvancedFitDMechanics/3-HarmEscalation.md`

```

Task 3: Implement Harm Escalation Logic
This is the most critical part. When harm is applied, we need to check if the slots are full and upgrade it if necessary.

Action: Create a new, dedicated applyHarm function in the GameViewModel that encapsulates this complex logic.
Action: Update the processConsequences function to call this new helper.
GameViewModel.swift (Logic Updates)

Swift

// In GameViewModel

// This new function handles all the complex escalation logic.
private func applyHarm(familyId: String, level: HarmLevel, toCharacter characterId: UUID) -> String {
    guard let charIndex = gameState.party.firstIndex(where: { $0.id == characterId }) else { return "" }
    guard let harmFamily = HarmLibrary.families[familyId] else { return "" }
    
    var currentLevel = level

    // The Escalation Loop
    while true {
        switch currentLevel {
        case .lesser:
            if gameState.party[charIndex].harm.lesser.count < HarmState.lesserSlots {
                let harm = harmFamily.lesser
                gameState.party[charIndex].harm.lesser.append((familyId, harm.description))
                return "Suffered Lesser Harm: \(harm.description)."
            } else {
                currentLevel = .moderate // Upgrade!
            }
        case .moderate:
            if gameState.party[charIndex].harm.moderate.count < HarmState.moderateSlots {
                let harm = harmFamily.moderate
                gameState.party[charIndex].harm.moderate.append((familyId, harm.description))
                return "Suffered Moderate Harm: \(harm.description)."
            } else {
                currentLevel = .severe // Upgrade!
            }
        case .severe:
            if gameState.party[charIndex].harm.severe.count < HarmState.severeSlots {
                let harm = harmFamily.severe
                gameState.party[charIndex].harm.severe.append((familyId, harm.description))
                return "Suffered SEVERE Harm: \(harm.description)."
            } else {
                // FATAL HARM!
                gameState.status = .gameOver
                let fatalDescription = harmFamily.fatal.description
                return "Suffered FATAL Harm: \(fatalDescription)."
            }
        }
    }
}

// Refactor processConsequences to use the new system.
private func processConsequences(_ consequences: [Consequence], forCharacter character: Character) -> String {
    var descriptions: [String] = []
    for consequence in consequences {
        switch consequence {
        // ... other cases ...
        case .sufferHarm(let level, let familyId): // We now pass the family ID
            let description = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
            descriptions.append(description)
        // ...
        }
    }
    return descriptions.joined(separator: "\n")
}
```

### `Docs/S7_AdvancedFitDMechanics/1-HarmFamiliesAndSlots.md`

```

Task 1: Model Harm Families and Slots
We need to evolve our data models to understand the concept of a "family" of related harms and the limited slots at each tier.

Action: Create a HarmFamily model to define the progression of a specific injury.
Action: Refactor HarmState to use these families and respect the slot limits.
Models.swift (Updates)

Swift

// In Models.swift

// Defines a single tier of a harm family.
struct HarmTier: Codable {
    var description: String
    var penalty: Penalty? // Penalty is optional for the "Fatal" tier
}

// Defines a full "family" of related harms, from minor to fatal.
struct HarmFamily: Codable, Identifiable {
    let id: String // e.g., "head_trauma", "leg_injury"
    var lesser: HarmTier
    var moderate: HarmTier
    var severe: HarmTier
    var fatal: HarmTier // The "game over" description
}

// Overhaul HarmState to use slots.
struct HarmState: Codable {
    // We now store the FAMILY ID and the specific DESCRIPTION of the harm taken.
    // The number of slots is defined by the array's capacity.
    var lesser: [(familyId: String, description: String)] = []
    var moderate: [(familyId: String, description: String)] = []
    var severe: [(familyId: String, description: String)] = []

    // Define the capacity of each tier.
    static let lesserSlots = 2
    static let moderateSlots = 2
    static let severeSlots = 1
}

// We'll also need a central place to define all our harm families.
// This could be a static property or loaded from a JSON file.
struct HarmLibrary {
    static let families: [String: HarmFamily] = [
        "head_trauma": HarmFamily(
            id: "head_trauma",
            lesser: HarmTier(description: "Headache", penalty: .actionPenalty(actionType: "Study")),
            moderate: HarmTier(description: "Migraine", penalty: .reduceEffect),
            severe: HarmTier(description: "Brain Lightning", penalty: .banAction(actionType: "Study")),
            fatal: HarmTier(description: "Head Explosion")
        ),
        "leg_injury": HarmFamily(
            id: "leg_injury",
            lesser: HarmTier(description: "Twisted Ankle", penalty: .actionPenalty(actionType: "Finesse")),
            moderate: HarmTier(description: "Torn Muscle", penalty: .reduceEffect),
            severe: HarmTier(description: "Shattered Knee", penalty: .banAction(actionType: "Finesse")),
            fatal: HarmTier(description: "Crippled Beyond Recovery")
        )
        // ... add more families
    ]
}

// Add the new penalty type to the Penalty enum
enum Penalty: Codable {
    // ... existing cases
    case banAction(actionType: String) // An action is impossible without a special effort
}
```

### `Docs/S5_VisualPolishAndRefactor/2-ReorganizeStatusViewsIntoPartySheet.md`

```

Task 2: Reorganize Status Views into a "Party Sheet"
The PartyStatusView and ClocksView provide crucial information, but they take up a lot of permanent screen real estate. Let's move them into a secondary, accessible sheet that the player can pull up when needed. This declutters the main view, focusing the player on the current node's interactables.

Action: Combine PartyStatusView and ClocksView into a new StatusSheetView.swift.
Action: Add a persistent "Party" button to ContentView that presents this sheet.
StatusSheetView.swift (New File)

Swift

import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            PartyStatusView(viewModel: viewModel)
            Divider()
            ClocksView(viewModel: viewModel)
            Spacer()
        }
        .padding()
    }
}
ContentView.swift (Sheet Implementation)

Swift

struct ContentView: View {
    // ...
    @State private var showingStatusSheet = false // New state to control the sheet

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ... HeaderView ...

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // The PartyStatusView and ClocksView are REMOVED from here
                        
                        // ... Interactables and NodeConnections ...
                    }
                    .padding()
                }
            }
            // ...

            // Add a floating button to show the status sheet
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
        }
        .sheet(isPresented: $showingStatusSheet) {
            StatusSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large]) // Allow a half-sheet
        }
        //...
    }
}
```

### `Docs/S5_VisualPolishAndRefactor/3-SubtleAnimationsAndTransitions.md`

```

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
```

### `Docs/S5_VisualPolishAndRefactor/1-IsolatedHeader.md`

```

Task 1: Isolate the Header
Let's fix the overlap bugs by creating a dedicated, self-contained view for the top part of the screen.

Action: Create a new HeaderView.swift.
Action: Move the Navigation Title, CharacterSelectorView, and any other top-level status indicators into this new view.
HeaderView.swift (New File)

Swift

import SwiftUI

struct HeaderView: View {
    let title: String
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes space
            
            CharacterSelectorView(characters: characters,
                                  selectedCharacterID: $selectedCharacterID)
        }
        .padding(.horizontal)
        .padding(.bottom) // Give it some breathing room from the content below
    }
}
ContentView.swift (Updates)
We will remove the NavigationView and its .navigationTitle modifier, instead treating the HeaderView as our custom title area. This gives us more control.

Swift

struct ContentView: View {
    // ... existing properties

    var body: some View {
        ZStack {
            // Main game view
            VStack(spacing: 0) { // Use spacing: 0 for more control
                HeaderView(
                    title: viewModel.currentNode?.name ?? "Unknown Location",
                    characters: viewModel.gameState.party,
                    selectedCharacterID: $selectedCharacterID
                )

                // Use a ScrollView for the main content to prevent overflow
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // All other views go here
                        PartyStatusView(viewModel: viewModel)
                        ClocksView(viewModel: viewModel)
                        Divider()
                        // ... Interactables and NodeConnections
                    }
                    .padding()
                }
            }
            .disabled(viewModel.gameState.status == .gameOver) // Disable interaction behind overlay

            // Game Over overlay remains the same
            if viewModel.gameState.status == .gameOver {
                // ...
            }
        }
        .ignoresSafeArea(.all, edges: .bottom) // Let content go to the bottom
    }
}
```

### `Docs/S2_ImproveDynamicism/1-DynamicCharacterSelection.md`

```

Task 1: Implement Dynamic Character Selection
The current implementation in ContentView.swift always uses the first character in the party (viewModel.gameState.party.first). We need to let the player choose which character to use for an action.

Action: Modify ContentView to manage a selected character.
Action: Create a CharacterSelectorView.
CharacterSelectorView.swift (New File)

Swift

import SwiftUI

struct CharacterSelectorView: View {
    let characters: [Character]
    @Binding var selectedCharacterID: UUID?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a Character")
                .font(.headline)
            Picker("Select Character", selection: $selectedCharacterID) {
                ForEach(characters) { character in
                    Text(character.name).tag(character.id as UUID?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
ContentView.swift (Updates)

Swift

struct ContentView: View {
    @StateObject var viewModel = GameViewModel()
    // ... (other @State properties)
    @State private var selectedCharacterID: UUID? // New state to track selection

    // Helper to get the full character object
    private var selectedCharacter: Character? {
        viewModel.gameState.party.first { $0.id == selectedCharacterID }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // We'll initialize the selected character ID on appear
                .onAppear {
                    if selectedCharacterID == nil {
                        selectedCharacterID = viewModel.gameState.party.first?.id
                    }
                }

                CharacterSelectorView(characters: viewModel.gameState.party,
                                      selectedCharacterID: $selectedCharacterID) // Add the new view

                PartyStatusView(viewModel: viewModel)
                // ...
                // Update the Button's action closure
                Button(action.name) {
                    pendingAction = action
                    // Use the new selectedCharacter property
                    if let character = selectedCharacter {
                        projectionText = viewModel.calculateProjection(for: action, with: character)
                        showingAlert = true
                    }
                }
                // ...
            }
            // ...
            // Update the Alert's Roll button action
            Button("Roll") {
                if let action = pendingAction,
                   let character = selectedCharacter { // Use the selected character
                    let clockID = viewModel.gameState.activeClocks.first?.id
                    viewModel.performAction(for: action, with: character, onClock: clockID)
                }
            }
            // ...
        }
    }
}
```

### `Docs/S2_ImproveDynamicism/3-DesignDedicatedDiceRollView.md`

```

Task 3: Design a Dedicated DiceRollView
The Alert is functional but not thematic. A dedicated modal view for the dice roll will significantly improve the game's feel.

Action: Create a new view DiceRollView.swift.
Action: Change ContentView to present this view as a sheet instead of an alert.
DiceRollView.swift (New File)

Swift

import SwiftUI

struct DiceRollResult {
    let highestRoll: Int
    let outcome: String // e.g., "Success", "Partial Success"
    let consequences: String
}

struct DiceRollView: View {
    @ObservedObject var viewModel: GameViewModel
    let action: ActionOption
    let character: Character
    let clockID: UUID?

    // Internal state for the animation
    @State private var diceValues: [Int] = []
    @State private var result: DiceRollResult? = nil
    @State private var isRolling = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(character.name).font(.title)
            Text("is attempting to...").font(.subheadline).foregroundColor(.secondary)
            Text(action.name).font(.title2).bold()
            
            Spacer()

            if let result = result {
                // View to show after the roll
                VStack {
                    Text(result.outcome).font(.largeTitle).bold()
                    Text("Rolled a \(result.highestRoll)").font(.title3)
                    Text(result.consequences).padding()
                }
            } else {
                // View to show before the roll
                HStack(spacing: 10) {
                    ForEach(0..<diceValues.count, id: \.self) { index in
                        Image(systemName: "die.face.\(diceValues[index]).fill")
                            .font(.largeTitle)
                            .rotationEffect(.degrees(isRolling ? 360 : 0))
                    }
                }
            }

            Spacer()

            if result == nil {
                Button("Roll the Dice!") {
                    // This is where we call the VM logic.
                    // For a better UX, we'd add animation.
                    withAnimation {
                        isRolling = true
                        // The actual logic is now moved here!
                        self.result = viewModel.performAction(for: action, with: character, onClock: clockID)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(30)
        .onAppear {
            let diceCount = max(character.actions[action.actionType] ?? 0, 1)
            self.diceValues = Array(repeating: 1, count: diceCount)
        }
    }
}
To make this work, we'll need to refactor GameViewModel.performAction to return the result instead of just modifying the state directly. This makes the logic more testable and reusable.

GameViewModel.swift (Refactor)

Swift

/// The main dice roll function, now returns the result for the UI.
func performAction(for action: ActionOption, with character: Character, onClock clockID: UUID?) -> DiceRollResult {
    guard let characterIndex = gameState.party.firstIndex(where: { $0.id == character.id }) else {
        // This should not happen in a controlled environment
        return DiceRollResult(highestRoll: 0, outcome: "Error", consequences: "Character not found.")
    }

    let dicePool = max(character.actions[action.actionType] ?? 0, 1)
    var highestRoll = 0
    for _ in 0..<dicePool {
        highestRoll = max(highestRoll, Int.random(in: 1...6))
    }

    var outcome: String
    var consequences: String

    switch highestRoll {
    case 6:
        outcome = "Full Success!"
        consequences = "You master the situation."
        if let clockID = clockID {
            let ticks = 2 // Standard effect
            updateClock(id: clockID, ticks: ticks)
            consequences += "\nThe '\(gameState.activeClocks.first(where: {$0.id == clockID})?.name ?? "")' clock progresses by \(ticks)."
        }
    case 4...5:
        outcome = "Partial Success..."
        gameState.party[characterIndex].stress += 2
        consequences = "You do it, but at a cost. Gained 2 Stress."
    default:
        outcome = "Failure."
        gameState.party[characterIndex].harm.lesser.append("Bruised")
        consequences = "Things go wrong. You suffer minor harm."
    }
    
    return DiceRollResult(highestRoll: highestRoll, outcome: outcome, consequences: consequences)
}
```

### `Docs/S2_ImproveDynamicism/2-CreateReusableInteractableCardView.md`

```

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
```

### `Docs/S8_ContentAndGenerationArchitecture/2-ArchitectDungeonGenerator.md`

```

Task 2: Architect the Dungeon Generator
This is the engine that will create variety. It will be a dedicated service that takes the loaded content and outputs a complete DungeonMap.

Action: Create a new DungeonGenerator.swift file.
Action: Design a basic generation algorithm.
Action: Update GameViewModel to call this generator instead of using its own hardcoded generateDungeon method.
DungeonGenerator.swift (New File)

Swift

import Foundation

class DungeonGenerator {
    private let content: ContentLoader

    init(content: ContentLoader = .shared) {
        self.content = content
    }

    func generate(level: Int) -> DungeonMap {
        var nodes: [UUID: MapNode] = [:]
        let nodeCount = 5 + level // Simple scaling: the deeper you go, the bigger the dungeon

        // 1. Create a chain of nodes
        var previousNodeID: UUID?
        var nodeIDs: [UUID] = []

        for i in 0..<nodeCount {
            let newNodeID = UUID()
            var connections: [NodeConnection] = []
            if let prevID = previousNodeID {
                // Connect back to the previous node
                connections.append(NodeConnection(toNodeID: prevID, description: "Go back"))
            }

            let newNode = MapNode(
                id: newNodeID,
                name: "Forgotten Antechamber \(i+1)",
                interactables: [], // We'll populate these next
                connections: connections
            )
            nodes[newNodeID] = newNode
            nodeIDs.append(newNodeID)

            // Connect the previous node forward to this one
            if let prevID = previousNodeID {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                nodes[prevID]?.connections.append(NodeConnection(toNodeID: newNodeID, description: desc))
            }
            previousNodeID = newNodeID
        }

        // 2. Populate nodes with interactables
        for id in nodeIDs.dropFirst() { // Don't put interactables in the very first room
            if var node = nodes[id] {
                let numberOfInteractables = Int.random(in: 1...2)
                for _ in 0..<numberOfInteractables {
                    if let randomTemplate = content.interactableTemplates.randomElement() {
                        node.interactables.append(randomTemplate)
                    }
                }
                nodes[id] = node
            }
        }

        // For now, the start is the first node we made.
        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID]?.isDiscovered = true
        
        return DungeonMap(nodes: nodes, startingNodeID: startingNodeID)
    }
}
GameViewModel.swift (Updates)

Swift

// In GameViewModel

// The old generateDungeon is removed entirely.
func startNewRun() {
    let generator = DungeonGenerator()
    let newDungeon = generator.generate(level: 1) // Start with a level 1 dungeon

    self.gameState = GameState(
        party: [/* ... generate random party ... */],
        activeClocks: [/* ... starting clocks ... */],
        dungeon: newDungeon,
        currentNodeID: newDungeon.startingNodeID,
        status: .playing
    )
}
```

### `Docs/S8_ContentAndGenerationArchitecture/1-ExternalizeContentToJson.md`

```

Task 1: Externalize Content to JSON
Currently, our HarmLibrary and Interactable definitions live directly in the code. This is inflexible. By moving them to JSON files, we can edit, add, and balance content without recompiling the app.

Action: Create a Content directory in your project to hold new JSON files.
Action: Create harm_families.json, interactables.json, and treasures.json.
Action: Create a ContentLoader service to parse these files at launch.
Example: interactables.json

JSON

{
  "common_traps": [
    {
      "id": "template_pressure_plate",
      "title": "Pressure Plate",
      "description": "A slightly raised stone tile looks suspicious.",
      "availableActions": [
        {
          "name": "Deftly step over it",
          "actionType": "Finesse",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "lesser", "familyId": "leg_injury" }
            ]
          }
        }
      ]
    },
    {
      "id": "template_cursed_idol",
      "title": "Cursed Idol",
      "description": "A small, unnerving idol of a forgotten god.",
      "availableActions": [
        {
          "name": "Smash it",
          "actionType": "Wreck",
          "position": "desperate",
          "effect": "great",
          "outcomes": {
            "success": [
              { "type": "removeInteractable", "id": "self" },
              { "type": "gainTreasure", "treasureId": "treasure_purified_idol_shard" }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "head_trauma" }
            ]
          }
        }
      ]
    }
  ]
}
(Note: We'll need to update our Consequence and ActionOption models to be initializable from these dictionary structures, often by adding a custom init(from decoder: Decoder) implementation that looks at a "type" field.)

ContentLoader.swift (New File)

Swift

import Foundation

class ContentLoader {
    static let shared = ContentLoader()

    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let treasureTemplates: [Treasure]

    private init() {
        // In a real app, you'd handle errors gracefully.
        self.interactableTemplates = Self.load("interactables.json")
        self.harmFamilies = Self.load("harm_families.json")
        self.treasureTemplates = Self.load("treasures.json")
    }

    static func load<T: Decodable>(_ filename: String) -> [T] {
        // Standard JSON file loading and decoding logic...
        // ...
        return [] // return decoded data
    }
}
```

### `Docs/S3_DungeonCrawl/1-DungeonModel.md`

```

Task 1: Model the Dungeon
We need new data structures in Models.swift to represent the dungeon map, its nodes, and the connections between them.

Action: Add DungeonMap, MapNode, and NodeConnection structs to Models.swift.
Models.swift (Additions)

Swift

// ... existing models

// Represents the entire dungeon layout
struct DungeonMap: Codable {
    var nodes: [UUID: MapNode] // Use a dictionary for quick node lookup by ID
    var startingNodeID: UUID
}

// Represents a single room or location on the map
struct MapNode: Identifiable, Codable {
    let id: UUID = UUID()
    var name: String
    var interactables: [Interactable]
    var connections: [NodeConnection]
    var isDiscovered: Bool = false // To support fog of war
}

// Represents a path from one node to another
struct NodeConnection: Codable {
    var toNodeID: UUID
    var isUnlocked: Bool = true // A path could be locked initially
    var description: String // e.g., "A dark tunnel", "A rickety bridge"
}
```

### `Docs/S3_DungeonCrawl/2-GenerateAndManageDungeonState.md`

```

Task 2: Generate and Manage the Dungeon State
The GameViewModel needs to be updated to create, store, and manage the state of the dungeon map and the player's current location.

Action: Update GameState to include the map and the party's location.
Action: Add logic to GameViewModel to generate a simple, static map for this sprint.
Action: Create a new function in GameViewModel for moving between nodes.
Models.swift (GameState update)

Swift

struct GameState: Codable {
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location
}
GameViewModel.swift (Updates)

Swift

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    // Helper to get the current node
    var currentNode: MapNode? {
        guard let map = gameState.dungeon, let currentNodeID = gameState.currentNodeID else { return nil }
        return map.nodes[currentNodeID]
    }

    init() {
        // ... existing party/clock setup
        self.gameState = GameState(/*...party/clocks...*/)
        generateDungeon() // Call the new map generation function
    }

    func generateDungeon() {
        // For this sprint, we'll create a static 3-node map.
        // In the future, this will be procedural.
        var nodes: [UUID: MapNode] = [:]

        // Create Nodes
        let startNodeID = UUID()
        let secondNodeID = UUID()
        let thirdNodeID = UUID()

        let startNode = MapNode(
            name: "Entrance Chamber",
            interactables: [
                Interactable(title: "Sealed Stone Door", description: "A massive circular door covered in dust.", availableActions: [
                    ActionOption(name: "Examine the Mechanism", actionType: "Study", position: .controlled, effect: .standard),
                    ActionOption(name: "Push with all your might", actionType: "Wreck", position: .desperate, effect: .great)
                ])
            ],
            connections: [NodeConnection(toNodeID: secondNodeID, isUnlocked: false, description: "The Stone Door")],
            isDiscovered: true
        )

        let secondNode = MapNode(
            name: "The Trap Room",
            interactables: [
                Interactable(title: "Trapped Pedestal", description: "An ancient pedestal covered in suspicious glyphs.", availableActions: [
                    ActionOption(name: "Tinker with it", actionType: "Tinker", position: .risky, effect: .standard)
                ])
            ],
            connections: [
                NodeConnection(toNodeID: startNodeID, description: "Back to the entrance"),
                NodeConnection(toNodeID: thirdNodeID, description: "A narrow corridor")
            ]
        )
        
        let thirdNode = MapNode(name: "The Echoing Chasm", interactables: [], connections: [])

        nodes[startNodeID] = startNode
        nodes[secondNodeID] = secondNode
        nodes[thirdNodeID] = thirdNode

        let map = DungeonMap(nodes: nodes, startingNodeID: startNodeID)
        self.gameState.dungeon = map
        self.gameState.currentNodeID = startNodeID
    }

    func move(to newConnection: NodeConnection) {
        if newConnection.isUnlocked {
            self.gameState.currentNodeID = newConnection.toNodeID
            // Mark the new node as discovered
            self.gameState.dungeon?.nodes[newConnection.toNodeID]?.isDiscovered = true
        }
        // In the future, we can handle locked doors here.
    }
}
```

### `Docs/S3_DungeonCrawl/3-BuildDungeonViews.md`

```

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
```

