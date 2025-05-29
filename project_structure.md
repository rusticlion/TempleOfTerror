# Project and Content Structure

## Directory Tree for CardGame
```
CardGame
|____PartyStatusView.swift
|____DiceRollView.swift
|____NodeConnectionsView.swift
|____.DS_Store
|____Persistence.swift
|____StatusSheetView.swift
|____CardGameApp.swift
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
| |____sfx_ui_pop.md
| |____sfx_dice_shake.md
| |____texture_stone_door.md
| |____icon_harm_moderate_full.md
| |____texture_stone_door.png
| |____sfx_dice_land.md
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
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.subheadline)
                        .bold()

                    VStack(alignment: .leading, spacing: 2) {
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

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Harm")
                            .font(.caption2)
                        HStack {
                            ForEach(0..<HarmState.lesserSlots, id: \.self) { index in
                                Image(index < character.harm.lesser.count ? "icon_harm_lesser_full" : "icon_harm_lesser_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                                Image(index < character.harm.moderate.count ? "icon_harm_moderate_full" : "icon_harm_moderate_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            ForEach(0..<HarmState.severeSlots, id: \.self) { index in
                                Image(index < character.harm.severe.count ? "icon_harm_severe_full" : "icon_harm_severe_empty")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
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
            let diceCount = max(character.actions[action.actionType] ?? 0, 1)
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
            ContentView()
        }
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
            Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3]),
            Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Wreck": 2])
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
        var nodes: [UUID: MapNode] = [:]
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
                name: "Forgotten Antechamber \(i + 1)",
                soundProfile: soundProfiles.randomElement() ?? "silent_tomb",
                interactables: [],
                connections: connections,
                theme: theme
            )
            nodes[newNode.id] = newNode
            nodeIDs.append(newNode.id)

            if let prev = previousNode {
                let desc = i == nodeCount - 1 ? "Path to the final chamber" : "Deeper into the tomb"
                let connection = NodeConnection(toNodeID: newNode.id, description: desc)
                nodes[prev.id]?.connections.append(connection)
            }
            previousNode = newNode
        }

        // Choose a single connection along the main path to lock
        if nodeIDs.count > 2 {
            let lockIndex = Int.random(in: 1..<(nodeIDs.count - 1))
            let fromID = nodeIDs[lockIndex]
            let toID = nodeIDs[lockIndex + 1]
            if let idx = nodes[fromID]?.connections.firstIndex(where: { $0.toNodeID == toID }) {
                nodes[fromID]?.connections[idx].isUnlocked = false
                lockedConnection = (from: fromID, to: toID)
            }
        }

        for id in nodeIDs {
            if var node = nodes[id] {
                let number = Int.random(in: 1...2)
                for _ in 0..<number {
                    if let template = content.interactableTemplates.randomElement() {
                        node.interactables.append(template)
                    }
                }
                nodes[id] = node
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
            nodes[lock.from]?.interactables.append(lever)
        }

        let startingNodeID = nodeIDs.first!
        nodes[startingNodeID]?.isDiscovered = true

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

class ContentLoader {
    static let shared = ContentLoader()

    let interactableTemplates: [Interactable]
    let harmFamilies: [HarmFamily]
    let treasureTemplates: [Treasure]

    private init() {
        self.interactableTemplates = Self.load("interactables.json")
        self.harmFamilies = Self.load("harm_families.json")
        self.treasureTemplates = Self.load("treasures.json")
    }

    private static func load<T: Decodable>(_ filename: String) -> [T] {
        // The JSON files are stored within the "Content" folder reference in the
        // Xcode project. When bundled, this folder becomes a subdirectory in the
        // app bundle, so we must specify it when looking up the resource.
        guard let url = Bundle.main.url(forResource: filename,
                                        withExtension: nil,
                                        subdirectory: "Content") else {
            print("Failed to locate \(filename)")
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
    var party: [Character] = []
    var activeClocks: [GameClock] = []
    var dungeon: DungeonMap? // The full map
    var currentNodeID: UUID? // The party's current location
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
    let id: UUID = UUID()
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
struct HarmLibrary {
    static let families: [String: HarmFamily] = [
        "head_trauma": HarmFamily(
            id: "head_trauma",
            lesser: HarmTier(description: "Headache", penalty: .actionPenalty(actionType: "Study")),
            moderate: HarmTier(description: "Migraine", penalty: .reduceEffect),
            severe: HarmTier(description: "Brain Lightning", penalty: .banAction(actionType: "Study")),
            fatal: HarmTier(description: "Head Explosion", penalty: nil)
        ),
        "leg_injury": HarmFamily(
            id: "leg_injury",
            lesser: HarmTier(description: "Twisted Ankle", penalty: .actionPenalty(actionType: "Finesse")),
            moderate: HarmTier(description: "Torn Muscle", penalty: .reduceEffect),
            severe: HarmTier(description: "Shattered Knee", penalty: .banAction(actionType: "Finesse")),
            fatal: HarmTier(description: "Crippled Beyond Recovery", penalty: nil)
        ),
        "electric_shock": HarmFamily(
            id: "electric_shock",
            lesser: HarmTier(description: "Electric Jolt", penalty: nil),
            moderate: HarmTier(description: "Seared Nerves", penalty: .reduceEffect),
            severe: HarmTier(description: "Nerve Damage", penalty: .banAction(actionType: "Tinker")),
            fatal: HarmTier(description: "Heart Stops", penalty: nil)
        )
        // Additional families can be added here
    ]
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
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.outcomes = outcomes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actionType = try container.decode(String.self, forKey: .actionType)
        position = try container.decode(RollPosition.self, forKey: .position)
        effect = try container.decode(RollEffect.self, forKey: .effect)
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
}


// Represents the entire dungeon layout
struct DungeonMap: Codable {
    var nodes: [UUID: MapNode] // Use a dictionary for quick node lookup by ID
    var startingNodeID: UUID
}

// Represents a single room or location on the map
struct MapNode: Identifiable, Codable {
    let id: UUID = UUID()
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


```

### `CardGame/InteractableCardView.swift`

```

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

```

### `CardGame/GameViewModel.swift`

```

import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState: GameState

    // Helper to get the current node
    var currentNode: MapNode? {
        guard let map = gameState.dungeon, let currentNodeID = gameState.currentNodeID else { return nil }
        return map.nodes[currentNodeID]
    }

    init() {
        self.gameState = GameState()
        startNewRun()
    }

    // --- Core Logic Functions for the Sprint ---

    /// Calculates the projection before the roll.
    func calculateProjection(for action: ActionOption, with character: Character) -> String {
        var diceCount = character.actions[action.actionType] ?? 0
        var position = action.position
        var effect = action.effect
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
        diceCount = max(diceCount, 0) // Can't roll negative dice

        let notesString = notes.isEmpty ? "" : " " + notes.joined(separator: ", ")
        return "Roll \(diceCount)d6. Position: \(position.rawValue), Effect: \(effect.rawValue)\(notesString)"
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character, interactableID: String?) -> DiceRollResult {
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

        let consequencesDescription = processConsequences(consequencesToApply, forCharacter: character, interactableID: interactableID)

        return DiceRollResult(highestRoll: highestRoll, outcome: outcomeString, consequences: consequencesDescription)
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
                if let connIndex = gameState.dungeon?.nodes[fromNodeID]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID]?.connections[connIndex].isUnlocked = true
                    descriptions.append("A path has opened!")
                }
            case .removeInteractable(let id):
                if let nodeID = gameState.currentNodeID {
                    gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == id })
                    descriptions.append("The way is clear.")
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.currentNodeID, let interactableStrID = interactableID {
                    gameState.dungeon?.nodes[nodeID]?.interactables.removeAll(where: { $0.id == interactableStrID })
                    descriptions.append("The way is clear.")
                }
            case .addInteractable(let inNodeID, let interactable):
                gameState.dungeon?.nodes[inNodeID]?.interactables.append(interactable)
                descriptions.append("Something new appears.")
            case .addInteractableHere(let interactable):
                if let nodeID = gameState.currentNodeID {
                    gameState.dungeon?.nodes[nodeID]?.interactables.append(interactable)
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
                    return "Suffered FATAL Harm: \(fatalDescription)."
                }
            }
        }
    }

    /// Starts a brand new run, resetting the game state
    func startNewRun() {
        let generator = DungeonGenerator()
        let (newDungeon, generatedClocks) = generator.generate(level: 1)

        self.gameState = GameState(
            party: [
                Character(name: "Indy", characterClass: "Archaeologist", stress: 0, harm: HarmState(), actions: ["Study": 3, "Wreck": 1]),
                Character(name: "Sallah", characterClass: "Brawler", stress: 0, harm: HarmState(), actions: ["Finesse": 2, "Survey": 2]),
                Character(name: "Marion", characterClass: "Survivor", stress: 0, harm: HarmState(), actions: ["Tinker": 2, "Attune": 1])
            ],
            activeClocks: [
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0)
            ] + generatedClocks,
            dungeon: newDungeon,
            currentNodeID: newDungeon.startingNodeID,
            status: .playing
        )

        if let startingNode = newDungeon.nodes[newDungeon.startingNodeID] {
            AudioManager.shared.play(sound: "ambient_\(startingNode.soundProfile).wav", loop: true)
        }
    }


    /// Move the party to a connected node if possible.
    func move(to newConnection: NodeConnection) {
        if newConnection.isUnlocked {
            gameState.currentNodeID = newConnection.toNodeID
            if let node = gameState.dungeon?.nodes[newConnection.toNodeID] {
                gameState.dungeon?.nodes[newConnection.toNodeID]?.isDiscovered = true
                AudioManager.shared.play(sound: "ambient_\(node.soundProfile).wav", loop: true)
            }
        }
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
                                            pendingInteractableID = interactable.id
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

