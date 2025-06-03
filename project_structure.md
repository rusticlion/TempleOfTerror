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
|____SceneKitDiceView.swift
|____StatusSheetView.swift
|____TreasureTooltipView.swift
|____CardGameApp.swift
|____MapView.swift
|____HarmTooltipView.swift
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
| |____texture_dicetray_surface.imageset
| |____|____texture_dicetray_surface.png
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
|____DieNode.swift
|____HeaderView.swift
|____Models.swift
|____InteractableCardView.swift
|____AssetPlaceholders
| |____icon_harm_severe_full.png
| |____vfx_damage_vignette.png
| |____icon_harm_severe_empty.md
| |____icon_harm_lesser_full.png
| |____texture_dicetray_surface.png
| |____icon_harm_lesser_empty.md
| |____icon_stress_pip_unlit.png
| |____texture_dicetray_surface.md
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
|____3DAssets
| |____dice.usdz
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
|____S15_3DDiceRollVisualization
| |____3-PhysicsBasedDiceRoll.md
| |____7-CleanupAndPerformanceTesting.md
| |____5-FullIntegrationWithExistingSystems.md
| |____4-ReadDiceResultsFromScene.md
| |____1-SceneKitFoundationAndDiceTraySetup.md
| |____2-3DDiceModelAndManagement.md
| |____6-VisualPolishAndFeedback.md
|____S13_ExpressiveActionsAndTags
| |____1-ImplementFreeActions.md
| |____2-AddTagSystem.md
| |____3-DocumentationAndExamples.md
|____S14_DynamicConsequencesAndRolls
| |____4-UpdateContentSchemaAndCreateExampleContent.md
| |____1-CoreRollMechanicEnhancements.md
| |____3-ImplementConsequenceGatingAndPositionEffectModulation.md
| |____5-UIPolishForProjectionsAndResults.md
| |____2-ModelConditionalConsequences.md
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

    @StateObject private var diceController = SceneKitDiceController()

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
        if let rolled = rollResult.actualDiceRolled {
            self.diceValues = rolled
            if let idx = rolled.firstIndex(of: rollResult.highestRoll) {
                self.highlightIndex = idx
            } else {
                self.highlightIndex = nil
            }
        } else {
            let totalDice = diceValues.count
            highlightIndex = Int.random(in: 0..<totalDice)
            diceValues = (0..<totalDice).map { idx in
                if idx == highlightIndex { return rollResult.highestRoll }
                return Int.random(in: 1...max(1, min(rollResult.highestRoll, 5)))
            }
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
                    if result.isCritical == true {
                        Text("CRITICAL SUCCESS!")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    if let eff = result.finalEffect {
                        Text("Effect: \(eff.rawValue.capitalized)")
                            .font(.subheadline)
                    }
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
                            .foregroundColor(
                                note.contains("0 rating") ? .orange :
                                (note.contains("-") || note.contains("Cannot") ? .red : .blue)
                            )
                    }
                }
            }

            VStack(spacing: 20) {
                SceneKitDiceView(controller: diceController, diceCount: diceValues.count)
                    .frame(height: 200)

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
                    diceController.rollDice()
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

### `CardGame/SceneKitDiceView.swift`

```

import SwiftUI
import SceneKit

class SceneKitDiceController: ObservableObject {
    fileprivate var dice: [DieNode] = []

    func rollDice() {
        for (index, die) in dice.enumerated() {
            let spread = Float(index) - Float(dice.count - 1) / 2
            let pos = SCNVector3(spread * 1.2 + Float.random(in: -0.2...0.2), 1.0, Float.random(in: -0.2...0.2))
            die.prepareForRoll(at: pos)
            let force = SCNVector3(Float.random(in: -2...2), Float.random(in: 5...9), Float.random(in: -2...2))
            die.node.physicsBody?.applyForce(force, asImpulse: true)
            let torque = SCNVector4(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -3...3))
            die.node.physicsBody?.applyTorque(torque, asImpulse: true)
        }
    }
}

struct SceneKitDiceView: UIViewRepresentable {
    @ObservedObject var controller: SceneKitDiceController
    let diceCount: Int
    private let traySize: Float = 10

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene

        // Camera looking straight down into the tray
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 6, z: 0)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        // Ambient light
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 500
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        // Omnidirectional light
        let omni = SCNLight()
        omni.type = .omni
        omni.intensity = 1000
        let omniNode = SCNNode()
        omniNode.position = SCNVector3(0, 5, 5)
        omniNode.light = omni
        scene.rootNode.addChildNode(omniNode)

        // Tray floor
        let floor = SCNBox(width: CGFloat(traySize), height: 0.2, length: CGFloat(traySize), chamferRadius: 0)
        floor.firstMaterial?.diffuse.contents = UIImage(named: "texture_dicetray_surface")
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -0.1, 0)
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        // Tray walls to keep dice contained
        let wallThickness: Float = 0.2
        let wallHeight: Float = 2.0
        let wallChamferRadius: CGFloat = 0.05

        // Geometry for front/back walls (top/bottom edges from camera perspective)
        let frontBackWallGeometry = SCNBox(
            width: CGFloat(traySize),
            height: CGFloat(wallHeight),
            length: CGFloat(wallThickness),
            chamferRadius: wallChamferRadius
        )
        frontBackWallGeometry.firstMaterial?.diffuse.contents = floor.firstMaterial?.diffuse.contents

        let backWall = SCNNode(geometry: frontBackWallGeometry)
        backWall.position = SCNVector3(0, wallHeight/2 - 0.1, -traySize/2)
        backWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(backWall)

        let frontWall = SCNNode(geometry: frontBackWallGeometry)
        frontWall.position = SCNVector3(0, wallHeight/2 - 0.1, traySize/2)
        frontWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(frontWall)

        // Geometry for left/right walls
        let leftRightWallGeometry = SCNBox(
            width: CGFloat(wallThickness),
            height: CGFloat(wallHeight),
            length: CGFloat(traySize),
            chamferRadius: wallChamferRadius
        )
        leftRightWallGeometry.firstMaterial?.diffuse.contents = floor.firstMaterial?.diffuse.contents

        let leftWall = SCNNode(geometry: leftRightWallGeometry)
        leftWall.position = SCNVector3(-traySize/2, wallHeight/2 - 0.1, 0)
        leftWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(leftWall)

        let rightWall = SCNNode(geometry: leftRightWallGeometry)
        rightWall.position = SCNVector3(traySize/2, wallHeight/2 - 0.1, 0)
        rightWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(rightWall)

        scnView.isPlaying = true
        scnView.allowsCameraControl = false

        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)

        // Add dice nodes
        for _ in 0..<diceCount {
            let die = DieNode()
            die.node.position = SCNVector3(
                Float.random(in: -(traySize/2 - 1)...(traySize/2 - 1)),
                1.0,
                Float.random(in: -(traySize/2 - 1)...(traySize/2 - 1))
            )
            scene.rootNode.addChildNode(die.node)
            controller.dice.append(die)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }

        if controller.dice.count < diceCount {
            for _ in controller.dice.count..<diceCount {
                let die = DieNode()
                die.node.position = SCNVector3(
                    Float.random(in: -(traySize/2 - 1)...(traySize/2 - 1)),
                    1.0,
                    Float.random(in: -(traySize/2 - 1)...(traySize/2 - 1))
                )
                scene.rootNode.addChildNode(die.node)
                controller.dice.append(die)
            }
        } else if controller.dice.count > diceCount {
            while controller.dice.count > diceCount {
                let die = controller.dice.removeLast()
                die.node.removeFromParentNode()
            }
        }
    }
}


```

### `CardGame/StatusSheetView.swift`

```

import SwiftUI

struct StatusSheetView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PartyStatusView(viewModel: viewModel)
                Divider()
                ClocksView(viewModel: viewModel)
                Spacer()
            }
            .padding()
        }
    }
}

struct StatusSheetView_Previews: PreviewProvider {
    static var previews: some View {
        StatusSheetView(viewModel: GameViewModel())
    }
}

```

### `CardGame/TreasureTooltipView.swift`

```

import SwiftUI

struct TreasureTooltipView: View {
    let treasure: Treasure

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(treasure.name)
                .font(.headline)
            Text(treasure.description)
                .font(.body)
            Text(treasure.grantedModifier.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !treasure.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(treasure.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(2)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
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

### `CardGame/HarmTooltipView.swift`

```

import SwiftUI

struct HarmTooltipView: View {
    let familyId: String
    let level: HarmLevel

    private var tier: HarmTier? {
        guard let family = HarmLibrary.families[familyId] else { return nil }
        switch level {
        case .lesser: return family.lesser
        case .moderate: return family.moderate
        case .severe: return family.severe
        }
    }

    private func penaltyDescription(_ penalty: Penalty) -> String {
        switch penalty {
        case .reduceEffect:
            return "All actions suffer -1 Effect."
        case .increaseStressCost(let amount):
            return "Stress costs are increased by \(amount)."
        case .actionPenalty(let actionType):
            return "\(actionType) rolls -1 die."
        case .banAction(let actionType):
            return "Cannot perform \(actionType)."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let tier = tier {
                Text(tier.description)
                    .font(.headline)
                if let penalty = tier.penalty {
                    Text(penaltyDescription(penalty))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Unknown Harm")
            }
        }
        .padding()
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
                        requiresTest: false,
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
            // Explicitly use default keys so optional fields like `conditions`
            // in `Consequence` decode without additional configuration.
            decoder.keyDecodingStrategy = .useDefaultKeys
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

### `CardGame/DieNode.swift`

```

import SceneKit

class DieNode {
    var node: SCNNode
    var value: Int = 1
    private let defaultScale: Float = 0.01
    /// The final visual side length of the die after applying `defaultScale`.
    /// Adjust this value to match the actual size of your USDZ model once scaled.
    private let effectiveSideLength: CGFloat = 0.8

    init() {
        if let sceneURL = Bundle.main.url(forResource: "dice", withExtension: "usdz"),
           let diceScene = try? SCNScene(url: sceneURL, options: nil) {
            // Outer node will hold the physics body
            self.node = SCNNode()

            // Child node for the visual model
            let visualNode = SCNNode()
            for child in diceScene.rootNode.childNodes {
                visualNode.addChildNode(child.clone())
            }
            visualNode.scale = SCNVector3(defaultScale, defaultScale, defaultScale)
            self.node.addChildNode(visualNode)

            // Simple cube physics shape matching the final scaled size
            let cubeGeometry = SCNBox(
                width: effectiveSideLength,
                height: effectiveSideLength,
                length: effectiveSideLength,
                chamferRadius: effectiveSideLength * 0.1
            )
            let shape = SCNPhysicsShape(geometry: cubeGeometry, options: nil)

            let body = SCNPhysicsBody(type: .dynamic, shape: shape)
            body.continuousCollisionDetectionThreshold = 0.001
            body.mass = 0.5
            body.friction = 0.7
            body.restitution = 0.1
            body.rollingFriction = 0.6
            body.damping = 0.15
            body.angularDamping = 0.15

            self.node.physicsBody = body
        } else {
            // Fallback to an empty node if the model can't be loaded
            self.node = SCNNode()
            let fallbackBox = SCNBox(width: effectiveSideLength, height: effectiveSideLength, length: effectiveSideLength, chamferRadius: 0.05)
            self.node.geometry = fallbackBox
            print("Error: Could not load dice.usdz. Using fallback geometry.")
        }
    }

    func prepareForRoll(at position: SCNVector3) {
        node.position = position
        // Start each roll from a random orientation to avoid uniform results
        node.eulerAngles = SCNVector3(
            Float.random(in: 0...Float.pi * 2),
            Float.random(in: 0...Float.pi * 2),
            Float.random(in: 0...Float.pi * 2)
        )
        node.physicsBody?.clearAllForces()
        node.physicsBody?.velocity = SCNVector3Zero
        node.physicsBody?.angularVelocity = SCNVector4Zero
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
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, name, description, grantedModifier, tags
    }

    init(id: String,
         name: String,
         description: String,
         grantedModifier: Modifier,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.grantedModifier = grantedModifier
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        grantedModifier = try container.decode(Modifier.self, forKey: .grantedModifier)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(grantedModifier, forKey: .grantedModifier)
        if !tags.isEmpty {
            try container.encode(tags, forKey: .tags)
        }
    }
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
    var tags: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, title, description, availableActions, isThreat, tags
    }

    init(id: String,
         title: String,
         description: String,
         availableActions: [ActionOption],
         isThreat: Bool = false,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.availableActions = availableActions
        self.isThreat = isThreat
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        availableActions = try container.decode([ActionOption].self, forKey: .availableActions)
        isThreat = try container.decodeIfPresent(Bool.self, forKey: .isThreat) ?? false
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
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
        if !tags.isEmpty {
            try container.encode(tags, forKey: .tags)
        }
    }
}

struct ActionOption: Codable {
    var name: String
    var actionType: String // Corresponds to a key in Character.actions, e.g., "Tinker"
    var position: RollPosition
    var effect: RollEffect
    /// Whether this action requires a dice roll. If false, success consequences
    /// are applied immediately when tapped.
    var requiresTest: Bool = true
    var isGroupAction: Bool = false
    var requiredTag: String? = nil
    var outcomes: [RollOutcome: [Consequence]] = [:]

    enum CodingKeys: String, CodingKey {
        case name, actionType, position, effect, requiresTest, isGroupAction, requiredTag, outcomes
    }

    init(name: String,
         actionType: String,
         position: RollPosition,
         effect: RollEffect,
         isGroupAction: Bool = false,
         requiresTest: Bool = true,
         requiredTag: String? = nil,
         outcomes: [RollOutcome: [Consequence]] = [:]) {
        self.name = name
        self.actionType = actionType
        self.position = position
        self.effect = effect
        self.requiresTest = requiresTest
        self.isGroupAction = isGroupAction
        self.requiredTag = requiredTag
        self.outcomes = outcomes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actionType = try container.decode(String.self, forKey: .actionType)
        position = try container.decode(RollPosition.self, forKey: .position)
        effect = try container.decode(RollEffect.self, forKey: .effect)
        isGroupAction = try container.decodeIfPresent(Bool.self, forKey: .isGroupAction) ?? false
        requiresTest = try container.decodeIfPresent(Bool.self, forKey: .requiresTest) ?? true
        requiredTag = try container.decodeIfPresent(String.self, forKey: .requiredTag)
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
        if !requiresTest {
            try container.encode(requiresTest, forKey: .requiresTest)
        }
        if isGroupAction {
            try container.encode(isGroupAction, forKey: .isGroupAction)
        }
        try container.encodeIfPresent(requiredTag, forKey: .requiredTag)
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

// MARK: - Conditional Consequences Support

struct GameCondition: Codable {
    enum ConditionType: String, Codable {
        case requiresMinEffectLevel
        case requiresExactEffectLevel
        case requiresMinPositionLevel
        case requiresExactPositionLevel
        case characterHasTreasureId
        case partyHasTreasureWithTag
        case clockProgress
    }

    let type: ConditionType
    let stringParam: String?
    let intParam: Int?
    let intParamMax: Int?
    let effectParam: RollEffect?
    let positionParam: RollPosition?

    init(type: ConditionType,
         stringParam: String? = nil,
         intParam: Int? = nil,
         intParamMax: Int? = nil,
         effectParam: RollEffect? = nil,
         positionParam: RollPosition? = nil) {
        self.type = type
        self.stringParam = stringParam
        self.intParam = intParam
        self.intParamMax = intParamMax
        self.effectParam = effectParam
        self.positionParam = positionParam
    }
}

struct Consequence: Codable {
    enum ConsequenceKind: String, Codable {
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

    var kind: ConsequenceKind

    // Parameters for the consequence itself
    var amount: Int?
    var level: HarmLevel?
    var familyId: String?
    var clockName: String?
    var fromNodeID: UUID?
    var toNodeID: UUID?
    var interactableId: String?
    var inNodeID: UUID?
    var newInteractable: Interactable?
    var treasureId: String?

    // Gating Conditions
    var conditions: [GameCondition]?

    private enum CodingKeys: String, CodingKey {
        case type, amount, level, familyId, clockName
        case fromNodeID, toNodeID, id, inNodeID
        case interactable, treasure, treasureId
        case conditions
    }

    init(kind: ConsequenceKind) {
        self.kind = kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var resolvedKind = try container.decode(ConsequenceKind.self, forKey: .type)

        amount = try container.decodeIfPresent(Int.self, forKey: .amount)
        level = try container.decodeIfPresent(HarmLevel.self, forKey: .level)
        familyId = try container.decodeIfPresent(String.self, forKey: .familyId)
        clockName = try container.decodeIfPresent(String.self, forKey: .clockName)
        fromNodeID = try container.decodeIfPresent(UUID.self, forKey: .fromNodeID)
        toNodeID = try container.decodeIfPresent(UUID.self, forKey: .toNodeID)
        interactableId = try container.decodeIfPresent(String.self, forKey: .id)
        inNodeID = nil
        newInteractable = nil
        treasureId = nil

        if resolvedKind == .removeInteractable, interactableId == "self" {
            resolvedKind = .removeSelfInteractable
            interactableId = nil
        }

        if resolvedKind == .addInteractable {
            if let nodeString = try? container.decode(String.self, forKey: .inNodeID), nodeString == "current" {
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
                resolvedKind = .addInteractableHere
            } else {
                inNodeID = try container.decodeIfPresent(UUID.self, forKey: .inNodeID)
                newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
            }
        } else if resolvedKind == .addInteractableHere {
            newInteractable = try container.decodeIfPresent(Interactable.self, forKey: .interactable)
        }

        if resolvedKind == .gainTreasure {
            if let tid = try container.decodeIfPresent(String.self, forKey: .treasureId) {
                treasureId = tid
            } else if let treasure = try container.decodeIfPresent(Treasure.self, forKey: .treasure) {
                treasureId = treasure.id
            }
        }

        conditions = try container.decodeIfPresent([GameCondition].self, forKey: .conditions)
        kind = resolvedKind
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch kind {
        case .gainStress:
            try container.encode(ConsequenceKind.gainStress, forKey: .type)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .sufferHarm:
            try container.encode(ConsequenceKind.sufferHarm, forKey: .type)
            try container.encodeIfPresent(level, forKey: .level)
            try container.encodeIfPresent(familyId, forKey: .familyId)
        case .tickClock:
            try container.encode(ConsequenceKind.tickClock, forKey: .type)
            try container.encodeIfPresent(clockName, forKey: .clockName)
            try container.encodeIfPresent(amount, forKey: .amount)
        case .unlockConnection:
            try container.encode(ConsequenceKind.unlockConnection, forKey: .type)
            try container.encodeIfPresent(fromNodeID, forKey: .fromNodeID)
            try container.encodeIfPresent(toNodeID, forKey: .toNodeID)
        case .removeInteractable:
            try container.encode(ConsequenceKind.removeInteractable, forKey: .type)
            try container.encodeIfPresent(interactableId, forKey: .id)
        case .removeSelfInteractable:
            try container.encode(ConsequenceKind.removeInteractable, forKey: .type)
            try container.encode("self", forKey: .id)
        case .addInteractable:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encodeIfPresent(inNodeID, forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
        case .addInteractableHere:
            try container.encode(ConsequenceKind.addInteractable, forKey: .type)
            try container.encode("current", forKey: .inNodeID)
            try container.encodeIfPresent(newInteractable, forKey: .interactable)
        case .gainTreasure:
            try container.encode(ConsequenceKind.gainTreasure, forKey: .type)
            try container.encodeIfPresent(treasureId, forKey: .treasureId)
        }

        try container.encodeIfPresent(conditions, forKey: .conditions)
    }
}

extension Consequence {
    /// Convenience constructor for unlocking a connection between two nodes.
    static func unlockConnection(fromNodeID: UUID, toNodeID: UUID) -> Consequence {
        var consequence = Consequence(kind: .unlockConnection)
        consequence.fromNodeID = fromNodeID
        consequence.toNodeID = toNodeID
        return consequence
    }

    /// Convenience value used when an action removes the interactable that
    /// triggered it.
    static var removeSelfInteractable: Consequence {
        Consequence(kind: .removeSelfInteractable)
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

    /// Numeric ordering used for comparisons (desperate > risky > controlled).
    var orderValue: Int {
        switch self {
        case .controlled: return 0
        case .risky: return 1
        case .desperate: return 2
        }
    }

    /// Returns `true` if `self` is worse (>=) than the provided position.
    func isWorseThanOrEqualTo(_ other: RollPosition) -> Bool {
        return self.orderValue >= other.orderValue
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

    /// Numeric ordering used for comparisons (great > standard > limited).
    var orderValue: Int {
        switch self {
        case .limited: return 0
        case .standard: return 1
        case .great: return 2
        }
    }

    /// Returns `true` if `self` is better (>=) than the provided effect.
    func isBetterThanOrEqualTo(_ other: RollEffect) -> Bool {
        return self.orderValue >= other.orderValue
    }
}

/// Result information returned after performing a dice roll.
struct DiceRollResult {
    let highestRoll: Int
    let outcome: String
    let consequences: String
    let actualDiceRolled: [Int]?
    let isCritical: Bool?
    let finalEffect: RollEffect?
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
    @ObservedObject var viewModel: GameViewModel
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

    private func actionDisabled(_ action: ActionOption) -> Bool {
        if let tag = action.requiredTag {
            return !viewModel.partyHasTreasureTag(tag)
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(interactable.title)
                .font(.title2).bold()
            Text(interactable.description)
                .font(.body)
            if !interactable.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(interactable.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(2)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(4)
                    }
                }
            }
            Divider()
            ForEach(interactable.availableActions, id: \.name) { action in
                let title = action.requiresTest ? action.name : "\(action.name) (Auto)"
                Button(title) {
                    onActionTapped(action)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .disabled(actionDisabled(action))
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
    struct SelectedHarm: Identifiable {
        let familyId: String
        let level: HarmLevel
        var id: String { familyId + level.rawValue }
    }

    let character: Character
    var locationName: String? = nil
    @State private var selectedTreasure: Treasure? = nil
    @State private var selectedHarm: SelectedHarm? = nil

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
                            if index < character.harm.lesser.count {
                                let harm = character.harm.lesser[index]
                                Button {
                                    selectedHarm = SelectedHarm(familyId: harm.familyId, level: .lesser)
                                } label: {
                                    Text(harm.description)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .padding(4)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("None")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Moderate Harms
                    HStack(spacing: 4) {
                        ForEach(0..<HarmState.moderateSlots, id: \.self) { index in
                            if index < character.harm.moderate.count {
                                let harm = character.harm.moderate[index]
                                Button {
                                    selectedHarm = SelectedHarm(familyId: harm.familyId, level: .moderate)
                                } label: {
                                    Text(harm.description)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .padding(4)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .background(Color(UIColor.systemBackground))
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("None")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Severe Harm
                    if let harm = character.harm.severe.first {
                        Button {
                            selectedHarm = SelectedHarm(familyId: harm.familyId, level: .severe)
                        } label: {
                            Text(harm.description)
                                .font(.caption2)
                                .foregroundColor(.primary)
                                .padding(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("None")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(4)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(4)
                    }
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
                                Button {
                                    selectedTreasure = treasure
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(treasure.name)
                                        if !treasure.tags.isEmpty {
                                            HStack(spacing: 2) {
                                                ForEach(treasure.tags, id: \.self) { tag in
                                                    Text(tag)
                                                        .font(.caption2)
                                                        .padding(2)
                                                        .background(Color(UIColor.systemGray5))
                                                        .cornerRadius(4)
                                                }
                                            }
                                        }
                                    }
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color(UIColor.systemBackground).opacity(0.5))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
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
        .popover(item: $selectedTreasure) { treasure in
            TreasureTooltipView(treasure: treasure)
        }
        .popover(item: $selectedHarm) { harm in
            HarmTooltipView(familyId: harm.familyId, level: harm.level)
        }
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

        if baseDice == 0 {
            notes.append("\(character.name) has 0 rating in \(action.actionType): Rolling 2d6, taking lowest.")
        }

        let displayDice = (baseDice == 0) ? 2 : diceCount

        return RollProjectionDetails(
            baseDiceCount: baseDice,
            finalDiceCount: displayDice,
            basePosition: basePosition,
            finalPosition: position,
            baseEffect: baseEffect,
            finalEffect: effect,
            notes: notes
        )
    }

    /// Executes a free action that does not require a roll, applying its success
    /// consequences immediately.
    func performFreeAction(for action: ActionOption, with character: Character, interactableID: String?) -> String {
        let consequences = action.outcomes[.success] ?? []
        let description = processConsequences(consequences, forCharacter: character, interactableID: interactableID)
        saveGame()
        return description
    }

    /// The main dice roll function, now returns the result for the UI.
    func performAction(for action: ActionOption, with character: Character, interactableID: String?) -> DiceRollResult {
        if action.isGroupAction {
            return performGroupAction(for: action, leader: character, interactableID: interactableID)
        }
        guard gameState.party.contains(where: { $0.id == character.id }) else {
            return DiceRollResult(highestRoll: 0,
                                  outcome: "Error",
                                  consequences: "Character not found.",
                                  actualDiceRolled: nil,
                                  isCritical: nil,
                                  finalEffect: nil)
        }

        let projection = calculateProjection(for: action, with: character)
        var finalEffect = projection.finalEffect
        let finalPosition = projection.finalPosition
        var actualDiceRolled: [Int] = []
        var highestRoll: Int
        var isCritical = false

        if character.actions[action.actionType] ?? 0 == 0 {
            let d1 = Int.random(in: 1...6)
            let d2 = Int.random(in: 1...6)
            actualDiceRolled = [d1, d2]
            highestRoll = min(d1, d2)
            if d1 == 6 && d2 == 6 { isCritical = true }
        } else {
            let dicePool = max(projection.finalDiceCount, 1)
            for _ in 0..<dicePool {
                actualDiceRolled.append(Int.random(in: 1...6))
            }
            highestRoll = actualDiceRolled.max() ?? 0
            let sixes = actualDiceRolled.filter { $0 == 6 }.count
            if sixes > 1 { isCritical = true }
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
        var consequencesDescription = ""

        if isCritical && highestRoll >= 4 {
            finalEffect = finalEffect.increased()
        }

        let eligible = consequencesToApply.filter { cons in
            areConditionsMet(conditions: cons.conditions,
                             forCharacter: character,
                             finalEffect: finalEffect,
                             finalPosition: finalPosition)
        }

        consequencesDescription = processConsequences(eligible, forCharacter: character, interactableID: interactableID)

        if isCritical && highestRoll >= 4 {
            let critMsg = "Critical Success! Effect increased to \(finalEffect.rawValue.capitalized)."
            if consequencesDescription.isEmpty {
                consequencesDescription = critMsg
            } else {
                consequencesDescription += "\n" + critMsg
            }
        }

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

        return DiceRollResult(highestRoll: highestRoll,
                              outcome: outcomeString,
                              consequences: consequencesDescription,
                              actualDiceRolled: actualDiceRolled,
                              isCritical: isCritical,
                              finalEffect: finalEffect)
    }

    private func performGroupAction(for action: ActionOption, leader: Character, interactableID: String?) -> DiceRollResult {
        guard partyMovementMode == .grouped, !isPartyActuallySplit() else {
            return DiceRollResult(highestRoll: 0,
                                  outcome: "Cannot",
                                  consequences: "Party must be together for a group action.",
                                  actualDiceRolled: nil,
                                  isCritical: nil,
                                  finalEffect: nil)
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
        return DiceRollResult(highestRoll: bestRoll,
                              outcome: outcomeString,
                              consequences: description,
                              actualDiceRolled: nil,
                              isCritical: nil,
                              finalEffect: nil)
    }

    private func processConsequences(_ consequences: [Consequence], forCharacter character: Character, interactableID: String?) -> String {
        var descriptions: [String] = []
        let partyMemberId = character.id
        for consequence in consequences {
            switch consequence.kind {
            case .gainStress:
                if let amount = consequence.amount,
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].stress += amount
                    descriptions.append("Gained \(amount) Stress.")
                }
            case .sufferHarm:
                if let level = consequence.level,
                   let familyId = consequence.familyId {
                    let description = applyHarm(familyId: familyId, level: level, toCharacter: character.id)
                    descriptions.append(description)
                }
            case .tickClock:
                if let clockName = consequence.clockName,
                   let amount = consequence.amount,
                   let clockIndex = gameState.activeClocks.firstIndex(where: { $0.name == clockName }) {
                    updateClock(id: gameState.activeClocks[clockIndex].id, ticks: amount)
                    descriptions.append("The '\(clockName)' clock progresses by \(amount).")
                }
            case .unlockConnection:
                if let fromNodeID = consequence.fromNodeID,
                   let toNodeID = consequence.toNodeID,
                   let connIndex = gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections.firstIndex(where: { $0.toNodeID == toNodeID }) {
                    gameState.dungeon?.nodes[fromNodeID.uuidString]?.connections[connIndex].isUnlocked = true
                    descriptions.append("A path has opened!")
                }
            case .removeInteractable:
                if let id = consequence.interactableId,
                   let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == id })
                    descriptions.append("The way is clear.")
                }
            case .removeSelfInteractable:
                if let nodeID = gameState.characterLocations[partyMemberId.uuidString], let interactableStrID = interactableID {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.removeAll(where: { $0.id == interactableStrID })
                    descriptions.append("The way is clear.")
                }
            case .addInteractable:
                if let inNodeID = consequence.inNodeID, let interactable = consequence.newInteractable {
                    gameState.dungeon?.nodes[inNodeID.uuidString]?.interactables.append(interactable)
                    descriptions.append("Something new appears.")
                }
            case .addInteractableHere:
                if let interactable = consequence.newInteractable,
                   let nodeID = gameState.characterLocations[partyMemberId.uuidString] {
                    gameState.dungeon?.nodes[nodeID.uuidString]?.interactables.append(interactable)
                    descriptions.append("Something new appears.")
                }
            case .gainTreasure:
                if let treasureId = consequence.treasureId,
                   let treasure = ContentLoader.shared.treasureTemplates.first(where: { $0.id == treasureId }),
                   let charIndex = gameState.party.firstIndex(where: { $0.id == character.id }) {
                    gameState.party[charIndex].treasures.append(treasure)
                    gameState.party[charIndex].modifiers.append(treasure.grantedModifier)
                    descriptions.append("Gained Treasure: \(treasure.name)!")
                }
            }
        }
        return descriptions.joined(separator: "\n")
    }

    /// Check if a list of conditions are satisfied for the given character and roll results.
    private func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
    ) -> Bool {
        guard let conditions = conditions, !conditions.isEmpty else { return true }

        for condition in conditions {
            var conditionMet = false
            switch condition.type {
            case .requiresMinEffectLevel:
                if let req = condition.effectParam {
                    conditionMet = finalEffect.isBetterThanOrEqualTo(req)
                }
            case .requiresExactEffectLevel:
                conditionMet = (condition.effectParam == finalEffect)
            case .requiresMinPositionLevel:
                if let req = condition.positionParam {
                    conditionMet = finalPosition.isWorseThanOrEqualTo(req)
                }
            case .requiresExactPositionLevel:
                conditionMet = (condition.positionParam == finalPosition)
            case .characterHasTreasureId:
                if let tId = condition.stringParam {
                    conditionMet = character.treasures.contains(where: { $0.id == tId })
                }
            case .partyHasTreasureWithTag:
                // TODO: Implement party tag check when treasures support tags
                print("WARN: partyHasTreasureWithTag condition not fully implemented yet.")
            case .clockProgress:
                if let name = condition.stringParam,
                   let min = condition.intParam,
                   let clock = gameState.activeClocks.first(where: { $0.name == name }) {
                    var metMin = clock.progress >= min
                    if let max = condition.intParamMax {
                        metMin = metMin && clock.progress <= max
                    }
                    conditionMet = metMin
                }
            }
            if !conditionMet { return false }
        }
        return true
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
                GameClock(name: "The Guardian Wakes", segments: 6, progress: 0),
                GameClock(name: "Test Clock", segments: 4, progress: 0)
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

    /// Check if any party member possesses a treasure with the given tag.
    func partyHasTreasureTag(_ tag: String) -> Bool {
        for member in gameState.party {
            for treasure in member.treasures {
                if treasure.tags.contains(tag) { return true }
            }
        }
        return false
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

                                let vm = viewModel
                                ForEach(items, id: \.id) { interactable in
                                    InteractableCardView(viewModel: vm,
                                                        interactable: interactable,
                                                        selectedCharacter: selectedCharacter) { action in
                                        if let character = selectedCharacter {
                                            if action.requiresTest {
                                                pendingAction = action
                                                pendingInteractableID = interactable.id
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

### `CardGame/3DAssets/dice.usdz`

```

PK
     �>�Y!�a���  ��  	  dice.usdc�                      PXR-USDC       ��                                                                                {�G�z�?                       
@               
@               
@               
@               
@                      
@                                                            !   "   #   $   %   &          '          (   )          *   )          +          ,          -          .   /          /          1   2   3   4   5   6   7   8           :          .                   ��  ��  ��  �?  �?  �?         ��  ��  ��  �? �?  �?�              P      ��P    2              P      �rP    .      �       �   A@ � TDEUDEUE@AU 0E �TETTUTEEUEU   �UTUUTTUUUUTUETEeTDEU�j E U �UEUTUQ�RUQUUQUe*eU�VUUejUUU�fiUa	 �	�VUUU&VfiUei�RU�VVUa*UUV* `ajUeV� �U�VeeUUQU�0  E � �RV�fjeej�V��ic  Ur   U 	  :   K    �   �a*VeUVeUe PVUeiU  +UUD81@AU �U@AUDET@AT@Q(    A'  P& 2/2� a8BUUeU�     @aU�R DUUU�	 4�VY   _ 9 U�    ? ]   #Q	  ]   D�  � [UaTUUAQT� �  c 'TE � �   c  	  �V�U 0UU*  �   : Q �    i   1 �� pE@QUU6P� � $2TEP�  �  i � T     3 �   �  A� �0EUT�aQUEUQDY�  ��  � 
  $  �  pU@AQ�� Z � *  H �  f   �      - A 3UUQ � 0UUe@    � % �jUU � �������!�"�����%�&�&- P�)�*	   �������� �'����7�8�%�&������C�D����Y�Z�
���!�$�P  �A��i�j�]�^��
�B�K�L��"�d�A�B�-�.��W�X�5�6����g�h���w�x�� �#�$�� / �v�� |�� }��  ����������c�d��}�~�W�X�=�>�@������q�r�9E�F���
�D���b�c�)�:��L�K}�}|�� ��J�I��g�V��;�:	�	X�a˼z�6��b�ab��� a�� Җ� �/��e�dm���� �0��J��^�i�|�� ~�� ��L��[�a�~��� }�� Y�w+^�� ��S�R{���. ��+��7���d�>��� �� ��B�Y��K�e���� �� z�W)�� j�#ex�� ��W�Vq�q,c�� `�]D_�� ��C�=!J��� Y�� ��� �H��[�lV��� U�� �C�Y򷦔 �:d�޷ k�� ��P�,��a�Yd�� j�� ��S�%k��� �{�ֽ m�� ��X�8	H�!� ^�� 
��m�lU�c@]�� 	��� �N�ȝ �e{�=@�}���r�a��^�V�EAz�� ��
Z�d��O�Q���Z�F���b�a�V��� 5�� ΋bFX�� ��� �QB��� _�� >� ���� �RP� ��π�� f�� ��`�T0�%� 2�� �,�� U(�� ��3�-��.�-��2�.��A�/��B�0�1�K�2�8��
2�<��3�2��0�.��F�3��S�Q��E�6��7�6��X�7��.��8�<���8�7��8�7�8�F���V�8��8�0	��1���9�8��8�1��.�&��/�)
��9�8��9�0	��3�)��8�*��9�0	��9�8��9�,�39�l	�E ���8�-�:9�s�	9�B��9�G�?;�z�:�Yٽ2<�n��=�<��9�*��7�"��7�%��9�1
�19�j��4�.
��=�<�=�?��8>�vz��� y�� z��{�z{��{�z|��u�t}��L�K��� �٪�R�Q0��x�w���� �~���w�vr�o��&��|�{˻�� �v�� �v��y�}���}�v�� �qԹ=�@9��y�v�E� X�� �M���1�2�������?�@����)�*�������;�<� �	��	�
�'�(�%�&�:���_�`�>"�#��
 `I��; �	�5�6�J����K�L����" �����[�\��� �����%��'Jv 	 ����9�N�O�n �O�P�<�+�,�3�4�C�C��E�J�>���'��_�z�c���1��a�5E�z~��*	�����w�v������q�p�ᤃ �'��m�l�����h�g�]�v��^�]� �
�Z�a��O�k�-�?��V�Ur[ �Xl�� k�� ��f�T��r�q��w�Z��N�Mڳ�K�J*m�_5l�� �V�^���y�g���^�2�_�})�h�}�o��� [�� �D�[��t�\^���b ������\�[d��� R �	n�;B�}�� ��&��^�Tp�� q�� r�%dw�� ��o�n��"-�O�Σ �q��m�!��� �g�ߨ� �7�֑ �g���h�O��v�`��V�[���!���������1������8�����3��&�E��J� ��!� �� ����3�J��M�$�%�:��%�#��&�%��!������R�J��&�#��!���("��S�;���(�&��(�&�&�B
�+�J��O�6���&�!��O�;��"&�H����6*�`��O�H��/-�\�*�7��f�e �޸�g�f��F�E�����a�`�^���Z�Y���h�_�$  � �ӹk�n��J�W��b�\��L�K��f�X��F �* ���Y�X���m�N��0�3� �T��   ����� �'�(�(��3�4�3s��	�
���a��	�	5�q���7����9�:�#�$�)�*�*2 ��G�H�-�.�:��S�T�9�:�:����*�+� �G�H�P��H�3 `�A�B�<	�A���[�G��A��'-�T�U���Z���<�2���>�=���&���.���Y�9��6�5�S�h�N�\��l�8�	4�=��A�T�)(�Q��:�4�2�:���n�m�-$�Q��:�/��o�5���d�c��9(�a�#5�X��6���H�.#��9��S0}�� �Յ �Z���?�>����~�G9�� ��-,�Y���a�;��]�h�
1�;���
���)��b�a��U�T��Q�'�� �A �Q ����p�H��)���������!�$�/�"�-��<�; �
��;�?���0�/�:�?��:�;��eq��<�.	 ���9�3��"�!��8�7�8�?���:�* ����7�6�7�=��9�K���9�(��9�)��%�
8�B��6�Q���7�1���9�'��<����8�-	��5�3�4�P��7�;��4�F��4�5��+�3	�	�)��8�!��1�D���4�3��<���7�(�&� �������]��
�w
 , q�����1��!D��#�
 ���7�8�"�#�b Q�	�
� �����'����S�S�%�'�"�/��?�3��/�� ����A�@��R��4�M��)�#��(��0�2
��A���1��� ���H���8�2���X�W��2������
�N�]��Hp�9�Xýe����X�*
�_����4�0�0�G��'���$�"�(�9��7�-��b�P��	<�E��>�,�������!�#��p�	���,���*�"���#�+����������"�.	�H ���$�#��#�"��$���$��"�'��O �9�"���#��"�/��#�%���B�'��"�>�����G�?��"�$���#��"�A��#��Ы���G�F��#�7���B�A��d���=������!�1������E-   = 6	�hP��� p����?����%�#�+�2��$����%�4��������$���8�6������!���5�4�#�5�����)�,��� �c���3�2��	��&�%���%�$�	�	��4�,���B�"������������
�� ���������������������f �� ���� �����#����&�� �+������� ����l oi ���������f�� ��	��������� ������
����������� ���#� �	��� ��
����� � p���� �������������	����<�� ��( ��)�� ��� �&��#��"� !��
/ ��0�/ �*�� ����@�� ��� 
� �'�� ������  �,�� �� ���� 
�
����� 9��7� 6��#� ��� ������ �
� ��� ��%�& ��� 3���4� �0�� �� ��+�, ������
�% � ���7�/� .��(� ������� �� ��� �"�� ��$��  �# ��3��4�' �,�� ���'�� � ����� ��� ��� ����� ��� *��� �� ������� 
 ����� � ������� ��� ��� ��� 
���� �$� ��� � ��� ���� � ����� �� ����	��� � ����! �h P
�	�� �� ��� �@��� �\���� �� ��� ��� �����
� �	 �� ���� �A���� �� �� 	� ����      �       �   AUU UUU   @E @U �@ UUEU@U �EQ@UUQ   T BUUUE �PUUUTUQ  @QTTQU�VUQTEUTEQUAQTUU Q? 	 �ETUETAQPUTA< 'U< Q` A �UEUAQT�VUUU�Y l  @H l  	� A� q !TUi   "�V� � $Q� l � ����Fj����fjR�l &9 D�f ��j�FjEUTD&� q�j�FjB�U� DQ� S�����0 D� S����j< � b����&*� l �l DB�l # D�D�	��EUU@��@@PQQUUQ� "Ql  u�U��V�V�U�V�R�
@A���&j�Vj�Z @���q���&jjU��Z��fjUUj �VU����j�Vej@Q�RTE-�PU@AUAU�Z��f�VQAiUUA Q!"U� �����i���������&V	UAQjVUjV`j? ��&YUj�V��j��j�j��j�����iZ��j ��� � � ���������������������	��������������������� ��� ��� �� 	�
������ ���	 �� � ������� � ����� � � �������� ����������������u�� �{�� 
��������� 
�� 
�� �	�
�����������Q �	�	���	������� � �1� 	�
���������������������� �������n ��������
���
�d  �� ��	�����������	��` � �8�9�2��1�%�;�1��� `���	% @��[� ��� ���X�Y ��[�\
�� e�� �]�^? 
c������cq�	��d�s �p�q��b�c��f�e� ]��
h����	��	���	������ � �� ����% ��	���
�����5��T�>�)���� ����������!�$I�	�^�g��i�k�I��g��o�W��[��X�Y��W�����c�] ��� ���nr0�<�������kL�U'�� &�� +�� 7*�� (��� '�� ��R�� *��� �6�� 7� � �8�� =�� 
*�� 4�� 0�� >��� �D�F��B�����F�K���?�I����V���M�p�	��X���e�b��d���d�i��eF�+M�� 0�� 1� � �b�� g�� ,1�� ]�� T�� e�� 7�� 7�� 8��� ��+��A�� :��id�e� d�e�K�^�fY�Dc�b�D�E ��G�HV�WQX���I�J� ���>���5�p�b��_��a��b��� ��a��d��������	������	����� �1��I�Kh����K�P��m�=��>���<���;��� �����9����� �d���j���q�{��i��j� 	 �n���s��j��m��o���� �������
���������� �.�/�(��'� �1��� P�!��c���=��J�� I���G���������cD��F���� ���t���k�s	����p��q� 	 �u���z��q��t��v���� �+1P�ȑ�8� � �i�� n�� ,8�� d�� V�� l�1� >1�� ?��� =�� ��H�� A��� �@��LA	�!9����w�6��C�� B���@����u����?=��?���� �,���2�άq���P�_ �\�]��N�O��R�Q{���P|��}�� ��|������ �+�B�� A�� F�� -E�� C��� B�� ��c�� E��� �Q�� R� � �S�� X�� 
E�� O�� K�� Y��^�:�3� �S��U�W�:��S����6��7���5���4���6��7��)��2����O���� ��@������n���m��		  �a������������
���� �!���	�������!�����
�� ��%���!��� ��#��1�,���
�����	�4�0�������� �����������  �/������Z����$������� �� � ��$��I���
�h��9��!��4���3��� �Y�
����)��)��*���*��+���'��(��������������(���)���+��)���4���*��%���&���( @&��OJ  ���<��;��
���� ����(�� ������������� ��
��	������ ������� ����������� ���
���	�� ��� ��	������&�����������,�+	��6��.��������aq����Z������� � �����$���$��#����"����������������(	��������
�	�����
���������������!��i  ��� � ������������ ����� �������������� ���� ����� 
������$��#���	�������������������	��!��"���������	�������������
��
�� �m��������
������������	������������������Z�������a�������6���5����[�������V��C��A�����4�����<B�����8�� _���W�� �D��h��H� �,��������d� }����|���� ���L?��L?��L?                      �            ��          ��    B���0E��a?    *0E��A#?      ��          ��    �A#?*0E�    �a?�0E�B��      ��          ��    �a?�0E�B�>�A#?*0E�          ��          ��    B���0E��a?    *0E��A#?      ��          ��    �a?�0E�B��B�>�0E��a�      ��          ��        *0E��A#�B���0E��a�      ��          ��    �A#�*0E�    �a��0E�B�>      ��          ��        *0E��A#�B���0E��a�      ��    B�>�0E��a?      ��          ��    �a?�0E�B�>�A#?*0E�          ��    �a?�0E�B�>      ��    B�>�0E��a�      ��    �A#?*0E�          ��    �a��0E�B��      ��    B�>�0E��a?      ��          ��        *0E��A#�B���0E��a�      ��          ��    �a?�0E�B��B�>�0E��a�      ��    B�>�0E��a?      ��          ��    �a��0E�B�>B���0E��a?      ��          ��    �a?�0E�B��B�>�0E��a�      ��          ��    �a��0E�B���A#�*0E�          ��          ��    �a��0E�B���A#�*0E�          ��    �A#?*0E�          ��          ��        *0E��A#?B�>�0E��a?      ��    �a?�0E�B�>      ��          ��    B���0E��a?    *0E��A#?      ��          ��    B�>�0E��a�    *0E��A#�      ��          ��    �A#�*0E�    �a��0E�B�>      ��    B���0E��a�      ��        *0E��A#�      ��        *0E��A#?      ��    �a��0E�B�>      ��    �a��0E�B��      ��    �a?�0E�B��      ��    B�>�0E��a?      ��        *0E��A#�      ��    �A#�*0E�          ��          ��    B���0E��a��a��0E�B��      ��    �a?�0E�B��      ��    �a��0E�B��      ��    �A#�*0E�          ��    �a?�0E�B�>      ��    �a?�0E�B�>      ��    �a��0E�B�>      ��        *0E��A#?      ��    B���0E��a?      ��    �a��0E�B�>      ��    B�>�0E��a?      ��    B�>�0E��a�      ��    B���0E��a?      ��    B���0E��a�      ��    �A#?*0E�          ��        *0E��A#?@�]?    �������>    @�]�@�]�    ����  ��          �?        @�]?    ����          �?���>    @�]?����    @�]�@�]�    ����          ��  ��        @�]�    ���>  �?        @�]?    ��������    @�]?����    @�]?          �?  �?        @�]?    �������>    @�]����>    @�]�@�]?    ���>  �?        ���>    @�]?@�]�    ���>@�]?    ���>@�]?    ���>  �?          ��        @�]�    ���>  �?        ���>    @�]�          �?          ��@�]�    �������>    @�]?@�]?    �������>    @�]�          ������    @�]?@�]�    ����  ��        ����    @�]�@�]?    ��������    @�]�@�]�    ���>����    @�]?          ������    @�]�          �?          �����>    @�]����>    @�]?@�]�    ����  ��        @�]�    ��������    @�]?          �?���>    @�]?����    @�]�          �?@�]?    ���>@�]�    ���>����    @�]?          ������    @�]�@�]?    ���>@�]?    ���>          �?���>    @�]?  ��        @�]�    ���>�'?:'�d��>��A?y:'�    ��A�y:'�    �'�:'�d��>�'?:'�d��>��A?y:'�    �'?:'�d���c��>:'��'�c���:'��'?    y:'���A?    y:'���A�c���:'��'��'�:'�d���c��>:'��'?�'?:'�d��>�'?:'�d���c��>:'��'�c��>:'��'�    y:'���A��'�:'�d�����A�y:'�    �'�:'�d��>c���:'��'?�'�:'�d�����A�y:'�        y:'���A�c���:'��'��'?:'�d���c���:'��'��'�:'�d��>c���:'��'?    y:'���A�c���:'��'�    y:'���A?c��>:'��'�    y:'���A�c��>:'��'�c��>:'��'?�'�:'�d�����A�y:'�    �'�:'�d���c���:'��'?    y:'���A?c��>:'��'?c���:'��'�    y:'���A?�'?:'�d��>�'�:'�d��>c���:'��'?    y:'���A�    y:'���A?c���:'��'��'�:'�d����'?:'�d��>��A?y:'�    �'?:'�d��>��A?y:'�        y:'���A?c��>:'��'?��A�y:'�    ��A?y:'�    �'�:'�d��>c���:'��'?�'?:'�d���c��>:'��'���A�y:'�    �'?:'�d���c��>:'��'?�'�:'�d��>    y:'���A?�'?:'�d�����A?y:'�    c��>:'��'?          ��          ��    �A#�*0E�B�>�a��0E�          ��          ��B�>�a?�0E�    �A#?*0E�          ��          ��B���a?�0E��a�B�>�0E�          ��          ���A#?    *0E��a?B�>�0E�          ��          ��B�>�a?�0E�    �A#?*0E�          ��          ���a�B�>�0E��A#�    *0E�          ��          ��B�>�a?�0E�    �A#?*0E�          ��          ���A#?    *0E��a?B�>�0E�          ��B���a?�0E�          ��          ���a?B���0E��A#?    *0E�          ��          ��B�>�a��0E��a?B���0E�          ��          ���A#�    *0E�:c�jA���/E�          ��          ��B���a��0E�    �A#�*0E�          ��          ���a�B���0E�B���a��0E�          ��          ��:c?jA���/E��A#?    *0E�          ���A#?    *0E�          ���A#�    *0E�          ��B�>�a��0E�          ���a�B�>�0E�          ���a?B���0E�          ��          ��B���a��0E�    �A#�*0E�          ��B�>�a��0E�          ���a�B�>�0E�          ���a?B�>�0E�          ��          ��    �A#?*0E�B���a?�0E�          ���a�B���0E�          ��          ���A#�    *0E��a�B���0E�          ���a?B���0E�          ���a�B�>�0E�          ��    �A#�*0E�          ���A#�    *0E�          ��B���a��0E�          ��B���a?�0E�          ���a?B�>�0E�          ��B�>�a?�0E�          ��B���a��0E�          ��B�>�a��0E�          ��          ��B�>�a?�0E�    �A#?*0E�          ���a?B�>�0E�          ��B���a?�0E�          ���a�B���0E�          ��    �A#�*0E�����@�]�          ��    @�]�����    ����@�]�    @�]����>      ��        @�]�����    ����@�]�    @�]?���>    ���>@�]?    @�]?���>    ���>@�]?    @�]�����    ����@�]�    @�]?���>    ���>@�]?    @�]?����      �?              �?          �?    ����@�]?    @�]����>      ��          �?        ����@�]?    @�]?����      �?              ��      ��        @�]�����    @�]?����      �?        ���>@�]�    ���>@�]�    ���>@�]�    @�]?����    ����@�]�          ��    @�]?���>          �?    ����@�]?      �?        @�]?����    @�]�����      ��              ��    @�]?���>    ���>@�]?          ��    @�]����>    ���>@�]�    ���>@�]?          �?    ���>@�]�    @�]����>    ����@�]?          �?    @�]����>    ����@�]?      ��            ��A�y:'�c��>�'�:'�c��>�'�:'��'?c���:'�c����'�:'�    ��A�y:'���A?    y:'��'?c��>:'�    ��A?y:'�c����'?:'���A?    y:'��'?c��>:'��'?c���:'���A�    y:'��'�c���:'���A�    y:'��'�c���:'�c����'�:'�    ��A�y:'��'?c��>:'�c��>�'?:'�c��>�'�:'���A?    y:'��'?c��>:'�c����'�:'�    ��A�y:'��'�c��>:'���A�    y:'�c��>�'�:'�c��>�'?:'�    ��A?y:'�c��>�'�:'��'�c��>:'�c��>�'?:'�    ��A?y:'�c����'?:'�    ��A?y:'���A?    y:'�c��>�'?:'��'�c��>:'�c����'?:'��'?c���:'�c����'�:'�c����'?:'���A�    y:'���A?    y:'��'?c���:'��'�c��>:'��'�c���:'��'�c���:'�    ��A�y:'��'�c���:'���A�    y:'�c��>�'?:'��'?c��>:'�c����'�:'�    ��A?y:'�c����'?:'��'�c��>:'��'?c���:'�  ��          ��        �0E�B�>�a��0E��a?B��  ��          ��        �0E�B���a?�0E��a�B�>  ��          ��        �0E��a?B��*0E��A#?      ��          ��        *0E��A#?    �0E��a?B�>  ��          ��        *0E�    �A#?�0E�B���a?  ��          ��        *0E�    �A#?�0E�B���a?  ��        �0E��a?B��  ��        *0E��A#�      ��          ��        *0E��A#?    �0E��a?B�>  ��          ��        *0E�    �A#?�0E�B���a?  ��          ��        *0E�    �A#��0E�B�>�a�  ��          ��        �0E�B���a�*0E�    �A#�  ��          ��        *0E��A#?    �0E��a?B�>  ��          ��        *0E�    �A#��0E�B�>�a�  ��        �0E��a�B��  ��        �0E��a�B�>  ��        �0E�B�>�a?  ��          ��        �0E��a�B���0E�B���a�  ��        �0E��a?B�>  ��          ��        *0E��A#�    �0E��a�B��  ��        *0E��A#�      ��        �0E�B�>�a?  ��        �0E�B���a�  ��        �0E��a?B��  ��        �0E��a�B�>  ��        �0E��a�B�>  ��        �0E�B�>�a�  ��        �0E��a�B��  ��        *0E�    �A#�  ��        �0E�B�>�a?  ��        *0E�    �A#?  ��        �0E�B�>�a?  ��        *0E��A#�      ��        �0E�B���a�          ��    ���>@�]�    @�]����>      ��        ����@�]?    @�]����>    ���>@�]?          �?          �?    @�]?���>    ���>@�]?    @�]?���>      �?        ���>@�]?          �?    @�]?����    ����@�]?    @�]����>    @�]�����    ����@�]�    ����@�]?    ���>@�]�    @�]?����      �?        @�]?���>      ��              �?    @�]�����    ����@�]�    @�]�����    ����@�]�    @�]����>      �?          ��        ����@�]?    ���>@�]?          ��          ��    @�]�����    ���>@�]�    @�]?����    @�]?����    ���>@�]�    ����@�]�          ��      �?          ��        @�]?���>y:'�    ��A?:'�c����'?:'��'�d���:'�c����'�:'�c����'�y:'�    ��A�y:'�    ��A�:'�c��>�'�y:'���A?    :'��'?d��>:'��'?d��>:'�c��>�'?y:'�    ��A�:'�c��>�'�:'��'�d��>y:'���A�    :'�c����'?:'��'�d��>:'�c��>�'?y:'�    ��A?:'�c��>�'?:'��'?d��>y:'���A?    y:'�    ��A?:'��'?d���:'�c����'?:'��'�d��>:'��'�d���:'�c����'�:'�c����'?:'��'?d���y:'���A?    :'��'?d��>y:'���A�    y:'�    ��A?:'��'�d���:'��'�d���:'�c����'�:'��'�d��>y:'���A?    y:'���A�    :'�c��>�'?y:'�    ��A�:'�c��>�'�:'��'?d���:'��'?d���:'�c��>�'�y:'���A�      �?          �?        �0E?B�>�a?�0E?�a?B�>  �?          �?        *0E?    �A#��0E?B���a�  �?          �?        *0E?�A#�    �0E?�a�B�>  �?          �?        �0E?�a�B�>�0E?B���a?  �?          �?        *0E?    �A#��0E?B���a�  �?          �?        �0E?B�>�a?�0E?�a?B�>  �?        �0E?�a�B��  �?        *0E?    �A#?  �?        �0E?B�>�a�  �?        *0E?    �A#?  �?        �0E?B���a?  �?        �0E?B�>�a�  �?        �0E?�a?B��  �?          �?        *0E?�A#?    �0E?�a?B��  �?          �?        �0E?�a?B�>*0E?�A#?      �?        �0E?B�>�a�  �?          �?        *0E?�A#�    �0E?�a�B�>  �?        *0E?    �A#�  �?        �0E?B���a�  �?        �0E?B���a?  �?        *0E?�A#?      �?        *0E?    �A#?  �?        �0E?�a?B��  �?        �0E?�a�B��  �?        *0E?�A#?      �?        �0E?�a�B��  �?        *0E?�A#�      �?        �0E?B�>�a?    @�]?����    ���>@�]�    @�]?����    ���>@�]�    ����@�]?          �?    @�]����>    ����@�]?      ��              ��    ����@�]�    @�]?���>      �?        ���>@�]?    ���>@�]�          ��    @�]�����          �?    @�]�����          �?    ���>@�]?    @�]?���>      �?        @�]?����      ��        @�]����>    @�]?���>      �?          ��        @�]�����          ��    ����@�]�    @�]����>      �?        ���>@�]?    ����@�]?    ����@�]�:'?�'�d��>:'?c����'?:'?c��>�'�y:'?    ��A�y:'?��A�    y:'?    ��A�:'?c����'�:'?�'?d���:'?�'?d��>y:'?��A?    y:'?    ��A?:'?c��>�'?:'?c����'?y:'?    ��A?:'?�'�d���y:'?    ��A?y:'?��A?    :'?�'�d���:'?�'?d���:'?c��>�'?:'?�'?d��>y:'?��A?    y:'?��A�    :'?�'�d��>:'?�'?d��>y:'?��A�    :'?�'�d���y:'?    ��A�:'?c����'�:'?�'�d��>y:'?��A?    :'?c��>�'?:'?c��>�'�:'?c����'?:'?c����'�:'?c��>�'�:'?�'?d���          �?          �?B�>�a?�0E?�a?B�>�0E?          �?          �?�a�B�>�0E?B���a?�0E?          �?    �A#?*0E?          �?          �?�a?B���0E?B�>�a��0E?          �?    �A#�*0E?          �?          �?�a?B���0E?B�>�a��0E?          �?�A#�    *0E?          �?          �?B���a��0E?�a�B���0E?          �?    �A#�*0E?          �?B���a��0E?          �?          �?B�>�a?�0E?�a?B�>�0E?          �?�A#?    *0E?          �?          �?�a�B�>�0E?B���a?�0E?          �?    �A#?*0E?          �?�a�B���0E?          �?�A#�    *0E?          �?�A#?    *0E?����@�]�    @�]�����    ���>@�]�          ��          �?    ���>@�]?      �?        @�]?����    @�]����>    ����@�]?      ��        @�]����>      ��              �?    ����@�]�    ����@�]?    @�]?���>      �?        @�]�����    @�]?����          ��    @�]?���>    ���>@�]?    ���>@�]�    ��A?    y:'?�'?c���:'?�'�c���:'?��A�    y:'?    ��A�y:'?c����'�:'?c��>�'�:'?c��>�'?:'?�'?c��>:'?�'�c���:'?��A�    y:'?c��>�'?:'?�'?c��>:'?�'?c���:'?c��>�'�:'?    ��A?y:'?��A?    y:'?    ��A�y:'?    ��A?y:'?�'�c��>:'?c����'?:'?�'�c��>:'?c����'�:'?c����'?:'?      �?          �?    B���0E?�a�    *0E?�A#�      �?    B�>�0E?�a�      �?    �a?�0E?B��      �?          �?    B�>�0E?�a?    *0E?�A#?      �?          �?    �a��0E?B�>�A#�*0E?          �?    B���0E?�a?      �?          �?    �A#�*0E?    �a��0E?B��      �?    �A#?*0E?          �?    �a?�0E?B�>          �����>    @�]�@�]?    ���>���>    @�]?����    @�]�          �?����    @�]?@�]�    ���>@�]?    ����  �?          ��        @�]�    ����  ��        �'�:'?d���c���:'?�'�    y:'?��A�c��>:'?�'��'?:'?d��>c��>:'?�'?    y:'?��A?c���:'?�'?�'�:'?d��>�'?:'?d�����A?y:'?    ��A�y:'?    ��A�y:'?    w      �T�P���T�      ��          ��          ��          ��          ��    �T;P���T�      ��          ��          ��    �T;P���T;      ��          ��          ��    �T�P���T;      ��          ��          ��          ��          ��    �T;�T�R��          ��          ��          ��          ��          ���T��T�R��          ��          ��          ���T��T;R��          ��          ��          ���T;�T;R��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��  ��        P���T;�T;  ��          ��          ��        P���T;�T�  ��          ��          ��        P���T��T�  ��          ��          ��          ��          ��        P���T��T;  ��          ��          ��          ��          �?        P�?�T;�T;  �?          �?        ��?T�      �?          �?        ��?    T;P�?�T��T�  �?          �?          �?          �?          �?        ��?    T�  �?          �?          �?          �?          �?        ��?T;      �?          �?        P�?�T;�T�  �?          �?        P�?�T��T;  �?                  �?    T;��?          �?          �?�T;�T;R�?          �?    T���?          �?          �?          �?�T��T�R�?          �?          �?          �?          �?T�    ��?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?T;    ��?          �?          �?          �?          �?      �?    �T;P�?�T;      �?          �?    �T�P�?�T;      �?          �?    �T;P�?�T�      �?          �?    �T�P�?�T�      �?    ���c����=ѡ���}���	>���e{��>��	���}�ѡ=���ݘm�J�>#Z���k��b�>�b����k�#Z>J꽾ݘm���=�F����^��F�>UR����|�=|�����UR;	N���}�_a
>$L�~�m���> P��5��5?�����4���4?1B��n3��n3?�A����*���*?:��:��:�?��*���*��A�>�n3��n3�1B>��4���4���=���~�m�$L;�5��5� P;_a
���}�	N;������a�?��	�ѡ���}?�����e{?ѡ���	���}?J꽾���ݘm?�b��#Z���k?#Z��b����k?���J꽾ݘm?�F���F����^?�T��T�R�?|��UR���?UR�|����?_a
�	N���}?���$L�~�m?�5� P��5?��4������4?�n3�1B��n3?��*��A����*?:��:��:�?�A����*���*?1B��n3��n3?�����4���4?$L����~�m? P��5��5?	N�_a
���}?	N�_a
���}?    @q
�J�}?    ����?    �5��5?    ���"�m?$L����~�m?    T���?�T��T�R�?"�m����    ~�m����$L;��}�_a
�	N;J�}�@q
�    ���|��UR;�����    �5��5�    �5��5� P;P���T��T;���T�    ݘm�J꽾��=��k��b��#Z>�e{����>��}���	�ѡ=��^��F���F�>��k�#Z��b�>��}�ѡ���	>c�������=ݘm����J�>��4���4���=�n3��n3�1B>��*���*��A�>:��:��:�?��*��A����*?�n3�1B��n3?��4������4?�5� P��5?~�m�$L���>��}�	N�_a
>���UR�|�=���    "�m?���$L�~�m?_a
�	N���}?@q
�    J�}?���    �?�5�    �5?T�    ��?"�m�    ��>J�}�    @q
>��}�	N�_a
>~�m�$L���>P���T��T;���UR�|�=��    ��=���    T;�5�    �5?    "�m���>$L�~�m���>	N���}�_a
>    J�}�@q
>UR����|�=    ����=    �5��5?    ���T;�����    @q
�J�}�    ���"�m�    T����    �5��5�    ��=c����=��	>��}�ѡ=�>�e{��>ѡ=��}���	>J�>ݘm���=�b�>��k�#Z>#Z>��k��b�>��=ݘm�J�>�F�>��^��F�>|�=���UR;UR;���|�=_a
>��}�	N;��>~�m�$L;�5?�5� P;��4?��4���=�n3?�n3�1B>��*?��*��A�>:�?:��:�?�A�>��*���*?1B>�n3��n3?��=��4���4?$L;~�m���> P;�5��5?	N;��}�_a
>��=���a�?ѡ=��	���}?�>���e{?��	>ѡ���}?��=J꽾ݘm?#Z>�b����k?�b�>#Z���k?J�>���ݘm?�F�>�F����^?�T;�T�R�?UR;|����?|�=UR���?	N;_a
���}?$L;���~�m? P;�5��5?��=��4���4?1B>�n3��n3?�A�>��*���*?:�?:��:�?��*?�A����*?�n3?1B��n3?��4?�����4?��>$L�~�m?�5? P��5?_a
>	N���}?	N;_a
���}?$L;���~�m?"�m?���    J�}?@q
�    ��}?_a
�	N;~�m?���$L;P�?�T��T;��?�a�dR;.�?���    ��?T�    �5?�5� P;�5?�5�    ݘm?J꽾��=��}?��	�ѡ=�e{?���>��k?�b��#Z>c�?�����=��}?ѡ���	>��k?#Z��b�>��^?�F���F�>ݘm?���J�>��4?��4���=��?dR��a=��}?	N�_a
>~�m?$L���>�5? P��5?��4?�����4?�n3?1B��n3?��*?�A����*?��*?��*��A�>:�?:��:�?�n3?�n3�1B>��>    "�m?@q
>    J�}?_a
>	N���}?��>$L�~�m?T;    ��?|�=UR���?��=    �?�5?    �5?"�m?    ��>~�m?$L���>J�}?    @q
>�?    ��=�5?    �5?P�?�T��T;��?    T;$L;~�m���>UR;���|�=��=��    @q
>J�}�    �5?�5�    ��>"�m�    T;���    ���c�?��=��	���}?ѡ=���e{?�>ѡ���}?��	>J꽾ݘm?��=�b����k?#Z>#Z���k?�b�>���ݘm?J�>�F����^?�F�>|����?UR;UR���?|�=_a
���}?	N;���~�m?$L;�5��5? P;��4���4?��=�n3��n3?1B>��*���*?�A�>:��:�?:�?�A����*?��*?1B��n3?�n3?�����4?��4?$L�~�m?��> P��5?�5?	N���}?_a
>�����=a�?ѡ���	>��}?���>�e{?��	�ѡ=��}?���J�>ݘm?#Z��b�>��k?�b��#Z>��k?J꽾��=ݘm?�F���F�>��^?�T��T;R�?UR�|�=��?|��UR;��?	N�_a
>��}?$L���>~�m? P��5?�5?�����4?��4?1B��n3?�n3?�A����*?��*?:��:�?:�?��*��A�>��*?�n3�1B>�n3?��4���=��4?���$L;~�m?�5� P;�5?_a
�	N;��}?    ��=�?    @q
>J�}?	N�_a
>��}?    ��>"�m?$L���>~�m?    T;��?    �5?�5?"�m���>    J�}�@q
>    ��}�_a
>	N;~�m���>$L;P���T;�T;���|�=UR;����=    ���T;    �5��5? P;�5��5?    ݘm�J�>��=��}���	>ѡ=�e{��>�>��k��b�>#Z>c����=��=��}�ѡ=��	>��k�#Z>�b�>��^��F�>�F�>ݘm���=J�>��4���4?��=���UR;|�=��}�	N;_a
>~�m�$L;��>�5� P;�5?��4���=��4?�n3�1B>�n3?��*��A�>��*?��*���*?�A�>:��:�?:�?�n3��n3?1B>_a
�	N;��}?���$L;~�m?|��UR;��?~�m�$L;��>P���T;�T;    "�m?��>    J�}?@q
>$L�~�m?��>    ��?T;UR���?|�=    �?��=    �5?�5?����?    @q
�J�}?    �5��5?    ���"�m?    T���?    ��=c�?��=ѡ=��}?��	>�>�e{?�>��	>��}?ѡ=��=ݘm?J�>#Z>��k?�b�>�b�>��k?#Z>J�>ݘm?��=�F�>��^?�F�>UR;��?|�=|�=��?UR;	N;��}?_a
>$L;~�m?��> P;�5?�5?��=��4?��4?1B>�n3?�n3?�A�>��*?��*?:�?:�?:�?��*?��*?�A�>�n3?�n3?1B>��4?��4?��=��>~�m?$L;�5?�5? P;_a
>��}?	N;��=��=a�?��	>ѡ=��}?�>�>�e{?ѡ=��	>��}?J�>��=ݘm?�b�>#Z>��k?#Z>�b�>��k?��=J�>ݘm?�F�>�F�>��^?�T;�T;R�?|�=UR;��?UR;|�=��?_a
>	N;��}?��>$L;~�m?�5? P;�5?��4?��=��4?�n3?1B>�n3?��*?�A�>��*?:�?:�?:�?�A�>��*?��*?1B>�n3?�n3?��=��4?��4?$L;��>~�m? P;�5?�5?	N;_a
>��}?	N;_a
>��}?$L;��>~�m?�T;�T;R�?"�m?��>    ~�m?��>$L;��}?_a
>	N;J�}?@q
>    ��?|�=UR;�?��=    �5?�5?    �5?�5? P;P�?�T;�T;��?T;    ݘm?J�>��=��k?�b�>#Z>�e{?�>�>��}?��	>ѡ=��^?�F�>�F�>��k?#Z>�b�>��}?ѡ=��	>c�?��=��=ݘm?��=J�>��4?��4?��=�n3?�n3?1B>��*?��*?�A�>:�?:�?:�?��*?�A�>��*?�n3?1B>�n3?��4?��=��4?�5? P;�5?~�m?$L;��>��}?	N;_a
>��?UR;|�=��>$L;~�m?_a
>	N;��}?��}?	N;_a
>~�m?$L;��>P�?�T;�T;��?UR;|�=$L;~�m?��>	N;��}?_a
>UR;��?|�=��=�?    @q
>J�}?    ��>"�m?    T;��?    �5?�5?    ���c�������	���}�ѡ����e{���ѡ���}���	�J꽾ݘm�����b����k�#Z�#Z���k��b�����ݘm�J꽾�F����^��F��|�����UR�UR����|��_a
���}�	N����~�m�$L��5��5� P���4���4�����n3��n3�1B���*���*��A��:��:��:���A����*���*�1B��n3��n3������4���4�$L�~�m���� P��5��5�	N���}�_a
�������a��ѡ���	���}������e{���	�ѡ���}����J꽾ݘm�#Z��b����k��b��#Z���k�J꽾���ݘm��F���F����^��T��T�R��UR�|�����|��UR����	N�_a
���}�$L����~�m� P��5��5������4���4�1B��n3��n3��A����*���*�:��:��:����*��A����*��n3�1B��n3���4������4����$L�~�m��5� P��5�_a
�	N���}�    �����    @q
�J�}�	N�_a
���}�    ���"�m�$L����~�m�    T����    �5��5���}�_a
�	N�~�m����$L�P���T��T����|��UR��5��5� P�ݘm�J꽾�����}���	�ѡ��e{�������k��b��#Z�c����������}�ѡ���	���k�#Z��b����^��F���F��ݘm����J꽾��4���4�������UR�|����}�	N�_a
�~�m�$L�����5� P��5���4������4��n3�1B��n3���*��A����*���*���*��A��:��:��:���n3��n3�1B����    "�m�@q
�    J�}�_a
�	N���}����$L�~�m�T�    ���|��UR�������    ���5�    �5�"�m�    ���~�m�$L����J�}�    @q
���    ����5�    �5�P���T��T����    T�    "�m����    J�}�@q
�$L�~�m����    ���T�UR����|��    �����    �5��5���=c�����ѡ=��}���	��>�e{�����	>��}�ѡ���=ݘm�J꽾#Z>��k��b���b�>��k�#Z�J�>ݘm�����F�>��^��F��UR;���|��|�=���UR�	N;��}�_a
�$L;~�m���� P;�5��5���=��4���4�1B>�n3��n3��A�>��*���*�:�?:��:����*?��*��A���n3?�n3�1B���4?��4������>~�m�$L��5?�5� P�_a
>��}�	N���=���a����	>ѡ���}��>���e{�ѡ=��	���}�J�>���ݘm��b�>#Z���k�#Z>�b����k���=J꽾ݘm��F�>�F����^��T;�T�R��|�=UR����UR;|�����_a
>	N���}���>$L�~�m��5? P��5���4?�����4��n3?1B��n3���*?�A����*�:�?:��:���A�>��*���*�1B>�n3��n3���=��4���4�$L;���~�m� P;�5��5�	N;_a
���}�	N;_a
���}�$L;���~�m��T;�T�R��~�m?���$L���}?_a
�	N���?�a�dR��5?�5� P�P�?�T��T�ݘm?J꽾�����k?�b��#Z��e{?������}?��	�ѡ���^?�F���F����k?#Z��b����}?ѡ���	�c�?������ݘm?���J꽾��4?��4�����n3?�n3�1B���*?��*��A��:�?:��:����*?�A����*��n3?1B��n3���4?�����4��5? P��5�~�m?$L������}?	N�_a
���?dR��a���>    "�m���>$L�~�m�_a
>	N���}�@q
>    J�}���=    ���5?    �5�T;    ���"�m?    ���J�}?    @q
���}?	N�_a
�~�m?$L����P�?�T��T���?dR��a��?    �����?    T��5?    �5�$L;~�m����	N;��}�_a
�UR;���|�����c�?���ѡ���}?��	����e{?����	���}?ѡ����ݘm?J꽾#Z���k?�b���b����k?#Z�J꽾ݘm?����F����^?�F��UR���?|��|����?UR�	N���}?_a
�$L�~�m?��� P��5?�5������4?��4�1B��n3?�n3��A����*?��*�:��:�?:����*���*?�A���n3��n3?1B���4���4?������~�m?$L��5��5? P�_a
���}?	N������=a����	�ѡ=��}����>�e{�ѡ���	>��}�J꽾��=ݘm��b��#Z>��k�#Z��b�>��k����J�>ݘm��F���F�>��^��T��T;R��|��UR;���UR�|�=���_a
�	N;��}����$L;~�m��5� P;�5���4���=��4��n3�1B>�n3���*��A�>��*�:��:�?:���A����*?��*�1B��n3?�n3������4?��4�$L���>~�m� P��5?�5�	N�_a
>��}�	N�_a
>��}�    @q
>J�}�    ��=��    �5?�5�    ��>"�m�$L���>~�m�    T;����T��T;R��~�m���>$L���}�_a
>	N����|�=UR��5��5? P�P���T;�T�ݘm�J�>�����k��b�>#Z��e{��>����}���	>ѡ���^��F�>�F����k�#Z>�b����}�ѡ=��	�c����=���ݘm���=J꽾��4���4?����n3��n3?1B���*���*?�A��:��:�?:����*��A�>��*��n3�1B>�n3���4���=��4��5� P;�5�~�m�$L;�����}�	N;_a
����UR;|�����$L;~�m�_a
�	N;��}���}�	N;_a
�~�m�$L;���P���T;�T����UR;|��    "�m?���$L�~�m?���	N���}?_a
�    J�}?@q
�UR���?|��    �?���    �5?�5�    ��?T���=c�?�����	>��}?ѡ��>�e{?��ѡ=��}?��	�J�>ݘm?����b�>��k?#Z�#Z>��k?�b����=ݘm?J꽾�F�>��^?�F��|�=��?UR�UR;��?|��_a
>��}?	N���>~�m?$L��5?�5? P���4?��4?����n3?�n3?1B���*?��*?�A��:�?:�?:���A�>��*?��*�1B>�n3?�n3���=��4?��4�$L;~�m?��� P;�5?�5�	N;��}?_a
���=��=a��ѡ=��	>��}��>�>�e{���	>ѡ=��}���=J�>ݘm�#Z>�b�>��k��b�>#Z>��k�J�>��=ݘm��F�>�F�>��^��T;�T;R��UR;|�=���|�=UR;���	N;_a
>��}�$L;��>~�m� P;�5?�5���=��4?��4�1B>�n3?�n3��A�>��*?��*�:�?:�?:����*?�A�>��*��n3?1B>�n3���4?��=��4���>$L;~�m��5? P;�5�_a
>	N;��}�	N;_a
>��}�$L;��>~�m���}?_a
>	N�~�m?��>$L�P�?�T;�T���?|�=UR��5?�5? P�ݘm?J�>�����}?��	>ѡ��e{?�>����k?�b�>#Z�c�?��=�����}?ѡ=��	���k?#Z>�b����^?�F�>�F��ݘm?��=J꽾��4?��4?�����?UR;|����}?	N;_a
�~�m?$L;����5? P;�5���4?��=��4��n3?1B>�n3���*?�A�>��*���*?��*?�A��:�?:�?:���n3?�n3?1B�_a
>	N;��}���>$L;~�m�|�=UR;���~�m?$L;���P�?�T;�T�$L;~�m?���UR;��?|��      ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��              ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��T;    ���          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��    T;���          ��    T����          ��T�    ���          ��          ��          ��          ��          ��          ��          ��  ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��        ���    T�  ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��          ��        ���T�    ���T;    ���    T;  �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?          �?        �T��T;R�?�T;�T�R�?      �?          �?          �?          �?          �?           *          ,     �      �Ͼ  ��3�s��  ������)��  ��R���Ͼ  �������>  �����>��x>  ���4�>lZ}>  ���4�>Z��>  ��c��>G^&�  ���4�>D�  ��a��>z?�  ���>��!�  ��d	�>���  ��3�H^�=  �������=  �����|H
�  ���K^��  ���,��D�  ��U���z?�  ��玬���  ���뎾s��  ���,���Ͼ  ������Ͼ  ��>���)��  ��*��㛇�  ��a��>��x�  ���4�>GZ}�  ���4�>H���  �����>s��  ����?�Ͼ  ��2?�Ͼ  ���?�)��  ��X�?�=��  �����u"��  ��R����x>  ���6վ���>  ��y���Z��>  ��X���lZ}>  ���6վ��  ��y�����
�  ��X�����>  ����?�)�>  ��X�?�j�  ���6վsO�  ���6վ㛇�  ��U���H���  ��v���G^��  ���*�>��  ����>�=�>  ���,����>  �������>  ��>���"�>  ��*���=��  ���,����  ��U�����
�  ��v���w"��  ��+��G^��  �������  ������=�>  ������?  ��y�����
?  ��X����"�>  ��R���=��  ����?��  �����>��
�  ��c��>w"��  ��X�?�j?  ���6վ�?  ��U�����
?  ��v���|O?  ���6վG^&>  ���6վD>  ��U���z?>  ��玬���!>  ��Xվ�j�  ���4�>sO�  ���4�>��>  ���*�>��>  ����>��>  ��<�>�)�>  ��6�>��  ��a��>��
�  �����>���  ����>H^�=  ���*�>��=  ����>,��  ����>Y��  ��2?K^��  ����?��  ����?P#��  ��"?�?  ��a��>�j?  ���4�>|O?  ���4�>��
?  �����>G^�=  ����?��=  ����?��>  ��2?��>  ���?��>  ��3���>  ����C>  ��a��>y?>  ���>D>  �����>z?>  ��ԅ�>���>  ��U���Z��>  ��v����=��  ���*�>u"��  ��6�>�ᶰ  ������q��  ��v��G^&>  ���4�>��!>  ��d	�>�?  �����>�=�>  ����?�"�>  ��X�?��
?  ��c��>D�  �����>z?�  ��ԅ�>㛇�  �����>H���  ��c��>��x�  ���6վGZ}�  ���6վD�  ��y���z?�  ��ɇ�����>  ��a��>Z��>  �����>C>  ��y���y?>  ��ɇ���Ͼ  ����>�Ͼ  ��<�>s��  ���*�>�)��  ��6�>㛇�  ��y���H���  ��X�����>  ������)�>  ��R����>  ���,���)�>  ��+���=�>  ���*�>�"�>  ��6�>G^�=  ���,����=  ���뎾G^&�  ���6վ��!�  ��Xվ���  ����>,��  ����>z?�~�~�ԅ�>��~�~���?z?>~�~�玬���!>~�~�Xվ��!�~�~�Xվz?�~�~�玬���>~�~�<�>�)�>~�~�6�>�"�>~�~�*����
?~�~�v���P#��~�~�"?|O?~�~��6վ��
?~�~�X���lZ}>~�~��6վZ��>~�~�v����"�>~�~�R���)��~�~�R���Ͼ~�~�����!�~�~�d	�>��
�~�~�c��>w"��~�~�X�?��~�~��뎾Z��>~�~����>sO�~�~��4�>u"��~�~�R��y?>~�~�ɇ����
�~�~����>��
�~�~�X���lZ}>~�~��4�>|O?~�~��4�>��
?~�~����>sO�~�~��6վ�)�>~�~�+����>~�~�����>~�~�>����
?~�~�c��>u"��~�~�6�>��
�~�~�v���w"��~�~�+���Ͼ~�~��?��=~�~����H���~�~�c��>GZ}�~�~��4�>��=~�~���?Z��>~�~�c��>�)��~�~�X�?y?>~�~��>��=~�~���>�Ͼ~�~�>���)��~�~�*���Ͼ~�~�<�>�q��~�~�v���)�>~�~�X�?�)�>~�~�R��z?>~�~�ԅ�>��!>~�~�d	�>H���~�~�v����"�>~�~�6�>|H
�~�~����~�~������=~�~��뎾,��~�~���>Z��>~�~�X���H���~�~����>�)��~�~�6�>��>~�~��?�"�>~�~�X�?z?�~�~�ɇ��z?�~�~��>,��~�~���>��~�~���>GZ}�~�~��6վH���~�~�X���Z��>�r����>lZ}>�r��4�>|O?�r��4�>��
?�r����>��
��r�X���sO��r��6վZ��>�r�v����)�>�r�+���"�>�r�R����>�r�����>�r�>���"�>�r�*����
?�r�c��>u"���r�6�>��
��r����>��
��r�v���w"���r�+��w"���r�X�?�Ͼ�r��?��
?�r�v���|O?�r��6վy?>�r�ɇ����=�r����H����r�c��>GZ}��r��4�>P#���r�"?��=�r���?Z��>�r�c��>�)���r�X�?y?>�r��>��=�r���>�Ͼ�r�>���)���r�*���Ͼ�r�<�>���r��뎾�q���r�v���)�>�r�X�?�)�>�r�R��z?>�r�ԅ�>��!>�r�d	�>H����r�v����"�>�r�6�>|H
��r�����r������=�r��뎾,���r���>Z��>�r�X���H����r����>�)���r�6�>��>�r��?��>�r�<�>�"�>�r�X�?z?>�r�玬�z?��r�ɇ����!��r�Xվz?��r��>��!��r�d	�>,���r���>���r���>GZ}��r��6վlZ}>�r��6վH����r�X����)���r�R��z?��r�ԅ�>���r���?��!>�r�Xվz?��r�玬��)�>�r�6�>��
?�r�X����Ͼ�r�����
��r�c��>sO��r��4�>u"���r�R����>�*��  ����>���  ����><��  ���)�>8��  ��  �3G^&�  ��D^��C�  ����y?�  ���n3��!�  ���?U��>  ���=�>�,�>  ���"�>*�>  ����
?v��>  �����>����  ����x>�4վ  ��sZ}>�4վ  ��]��>d���  ���Ͼ2�  ���=�����  ��w"��Y��  ���Ͼ��  ����x��6�>  ��䛇�U��>  ��I���v��>  ��IZ}��6�>  ����>��>  ��}�>�,�>  ���)�>+�>  ����>>�>  ����U��>  ���j��6�>  ��tO��6�>  ����
�v��>  ��t�����  ���)��Y��  ���j��4վ  ����c���  ����
�����  ��tO��4վ  ��>x��>  ��~�>��?  ���)�>Q�?  ��S��>W��>  ��H>F^�=  ��K^&>  @�  ����!> �=�  ��~?>��=  ���Ͼ���  ��t���*��  ���)��8��  ���Ͼ<��  ��t����?  ��䛇�y��>  ��I���X��>  ���)��Q�?  ��D^&�  @�  ��@�F^�=  ��v?���=  ����!� �=�  ����x>�6�>  ��^Z}>�6�>  ���j?�6�>  ��yO?�6�>  ��@^��C>  ����y?>  ��H>J^��  ��~?>��  �����>c���  ��]��>����  ��  �3G^&>  ��P^�=C>  ����=y?>  ���n3��!>  ���=���*��  ��w"��8��  ��䛇�����  ��I���d���  ��>V��>  ��S��>w��>  ���=�>���  ����>2�  ����>��  ���"�>Y��  ���?y��>  ����
?X��>  ���?c���  ���j?�4վ  ��~O?�4վ  ����
?����  ����x��>  ����
�W��>  ���?����  ����
?d���  ���Ͼ3?  ���Ͼ�?  ����x��4վ  ��IZ}��4վ  ���=�>�*��  ���"�>8��  ��P^�=C�  ����=y?�  ��@�J^��  ��v?���  ����>���  ���)�>Y��  ���=�>��?  ���"�>Q�?  ���=����?  ��w"��Q�?  ���Ͼ��>  ���=���,�>  ��w"��+�>  ���Ͼ>�>  ��������  ����
�d���  ��t���,�>  ���)��*�>  ��䛇�c���  ��I�������  ����>3?  ����>�?  ���)��Q�?~�~��Ͼ�?~�~�I�������~�~��)��8��~�~�I���d���~�~�IZ}��4վ~�~���
?����~�~��"�>8��~�~�v?���~�~���y?�~�~���
�v��>~�~�w"��+�>~�~���
?X��>~�~��"�>Q�?~�~�S��>w��>~�~��)�>+�>~�~�]��>����~�~�sZ}>�4վ~�~��n3��!�~�~��Ͼ>�>~�~��)��*�>~�~�I���v��>~�~�IZ}��6�>~�~�tO��6�>~�~���=y?�~�~���
�����~�~�tO��4վ~�~���>�?~�~���!>1B�~�~�~?>��=~�~�v?���=~�~���!�1B�~�~�w"��Q�?~�~���y?>~�~��)�>Q�?~�~���
�W��>~�~���=y?>~�~��n3��!>~�~�]��>d���~�~���>>�>~�~��"�>*�>~�~�^Z}>�6�>~�~�S��>W��>~�~�I���X��>~�~�~O?�4վ~�~��Ͼ<��~�~���
�d���~�~�w"��Y��~�~���><��~�~�~?>��~�~��)�>8��~�~��)�>Y��~�~���>��~�~�w"��8��~�~���
?v��>~�~��"�>Y��~�~��Ͼ��~�~���
?d���~�~��)��Y��~�~�yO?�6�>~�~���>�?�r��)�>Q�?�r�w"��Q�?�r���
�W��>�r���=y?>�r��n3��!>�r�sZ}>�4վ�r�]��>d����r���>>�>�r��"�>*�>�r�^Z}>�6�>�r�S��>w��>�r�S��>W��>�r�IZ}��6�>�r�I���X��>�r�~O?�4վ�r���
?�����r��)��8���r��Ͼ<���r���
�d����r�w"��Y���r���y?>�r���!�H�f��r�v?����r��"�>8���r���><���r�~?>���r���!>H�f��r��)�>8���r��)�>Y���r���>���r�w"��8���r���
?v��>�r�w"��+�>�r��Ͼ>�>�r��"�>Y���r��Ͼ���r�tO��6�>�r��)�>+�>�r���
?d����r��)��Y���r���
������r��)��Q�?�r���=y?��r�yO?�6�>�r�tO��4վ�r�]��>�����r�I���d����r�~?>��=�r���
?X��>�r��Ͼ�?�r�I��������r�IZ}��4վ�r���y?��r���
�v��>�r��"�>Q�?�r��n3��!��r��)��*�>�r�I���v��>�r�v?���=�r�  ��ꛇ>���>  ��z�>��?  ���)�>b�?  ��O��>x��>  ��䛇�b���  ��t��y��  ���)��F��  ��I���A���  ���j�5�>  �������>  ����
�w��>  ��yO�5�>  ��ꛇ>b���  ����x>�6վ  ��UZ}>�6վ  ��O��>A���  ���=�>�*�>  ����>��>  ����>&<�>  ��}"�>K�>  ���=�>y��  ����>�2�  ����>��  ��}"�>F��  ��ꛇ>>���  ��O��>_���  ����x��6վ  ��IZ}��6վ  ����b���  ���j��6վ  ��sO��6վ  ����
�A���  ��~���*�>  ���Ͼ��>  ���Ͼ$<�>  ���)��I�>  ��z�>�,��  ����>���  ����>�=��  ���)�>��  ���Ͼ2?  ��}����?  ���)��b�?  ���Ͼ�?  ��ꛇ>v��>  ����x>5�>  ��UZ}>5�>  ��O��>���>  ���=���,��  ���Ͼ���  ���Ͼ�=��  ��v"����  ��䛇�>���  ��I���_���  ���?b���  ����
?A���  ��z�>�*�>  ���)�>K�>  ���=�>��?  ���?���>  ����
?x��>  ��}"�>b�?  ����t��>  ����
����>  ���?>���  ���j?�6վ  ��wO?�6վ  ����
?_���  ���j?5�>  ��wO?5�>  ���=��y��  ��w"��F��  ���=�>�,��  ��}"�>��  ����>���  ����
�_���  ���?v��>  ����
?���>  ���u��>  ��S������>  ���=����?  ���"��b�?  ������>  ��S���v��>  ����>2?  ����>�?  ��z�>y��  ���)�>F��  ���Ͼ�2�  ���Ͼ��  ���=���*�>  ���"��I�>  ����x�5�>  ��^Z}�5�>  ��s���,��  ���)����~�~��Ͼ�=��~�~�v"����~�~�I���A���~�~�IZ}��6վ~�~��)��I�>~�~�S������>~�~��)�>K�>~�~���>&<�>~�~��Ͼ$<�>~�~�O��>A���~�~��)�>F��~�~�O��>���>~�~�UZ}>5�>~�~�w"��F��~�~��Ͼ��~�~���
�_���~�~�}"�>F��~�~���
?A���~�~���
?x��>~�~�}"�>b�?~�~��)��F��~�~��)�>��~�~�O��>_���~�~�yO�5�>~�~���
����>~�~�wO?5�>~�~���>��~�~�S���v��>~�~��)��b�?~�~���
?_���~�~�}"�>��~�~���
?���>~�~�sO��6վ~�~�wO?�6վ~�~�}"�>K�>~�~��"��I�>~�~���>�=��~�~���>�?~�~�I���_���~�~��)�>b�?~�~�O��>x��>~�~���
�w��>~�~��"��b�?~�~��)����~�~��Ͼ�?~�~�UZ}>�6վ~�~�^Z}�5�>~�~���
�A����r���>&<�>�r�}"�>K�>�r�I���_����r��)�����r��)��b�?�r��Ͼ�?�r���>�=���r��)�>���r�UZ}>�6վ�r�O��>A����r���
�A����r�w"��F���r��Ͼ�=���r�v"�����r�I���A����r�IZ}��6վ�r��)��I�>�r�S������>�r��)�>K�>�r��Ͼ$<�>�r��)�>F���r�O��>���>�r�UZ}>5�>�r��Ͼ���r���
�_����r�}"�>F���r���
?A����r���
?x��>�r�}"�>b�?�r��)��F���r�O��>_����r�yO�5�>�r���
����>�r�wO?5�>�r���>���r�S���v��>�r���
?_����r�}"�>���r���
?���>�r�sO��6վ�r�wO?�6վ�r��"��I�>�r���>�?�r��)�>b�?�r�O��>x��>�r���
�w��>�r��"��b�?�r�^Z}�5�>  �?0��y���  �?������  �?����R��  �?��
�X���  �?Pc�>��?  �?���>2?  �?���>�?  �?/H�>X�?  �?��?a��>  �?q}?�4�>  �?Pb?�4�>  �?��
?���>  �?�襾���  �?v��y���  �?�`��X���  �?���R��  �?�襾�,��  �?>�Ͼ���  �?>�Ͼ>��  �?���*��  �?���E^��  �?Gǥ�C�  �?��y?�  �?z?���  �?��?���>  �?��
?c��>  �?>�Ͼ3�  �?>�Ͼ��  �?+4�>��?  �?LO�>X�?  �?���9G^&�  �?  `���!�  �?H��=C�  �?��=y?�  �?����,��  �?����+��  �?0��U���  �?��
�v���  �?���E^�=  �?�&�j1  �?��!�AQf1  �?z?���=  �?59y>�4�>  �?���>a��>  �?��>���>  �?��}>�4�>  �?Kǥ�B>  �?��x?>  �?�_>H^��  �?ǩ&>���  �?��!>槟�  �?y?>��  �?���9G^&>  �?  б��!>  �?G��=C>  �?��=y?>  �?Pc�>�*�>  �?/H�>6�>  �?�W��6վ  �?�<��6վ  �?���>��>  �?���><�>  �?���>���>  �?��>c��>  �?�_>F^�=  �?z?>��=  �?�&�j1  �?��!�AQf1  �?v��U���  �?�`��v���  �?5�x��6վ  �?�}��6վ  �?,4�>�*�>  �?MO�>6�>~�~?��
�v���~�~?����+��~�~?��>c��>~�~?LO�>X�?~�~?���R��~�~?>�Ͼ��~�~?y?>��~�~?��=y?�~�~?��!>槟�~�~?>�Ͼ>��~�~?���*��~�~?��
�X���~�~?�<��6վ~�~?����R��~�~?��x?>~�~?b�ر��!>~�~?z?>��=~�~?0\d���!�~�~?�`��v���~�~?���><�>~�~?MO�>6�>~�~?z?���~�~?��!�AQf1~�~?z?���=~�~?Pb?�4�>~�~?��
?���>~�~?��>���>~�~?��!�AQf1~�~?�}��6վ~�~?��
?c��>~�~?���>�?~�~?/H�>X�?~�~?�`��X���~�~?��}>�4�>~�~?��y?�~�~?/H�>6�>~�~?��=y?>�r?y?>���r?��=y?��r?��x?>�r?H���!>�r?��!>槟��r?>�Ͼ>���r?���*���r?z?���=�r?��
�X����r?�<��6վ�r?>�Ͼ���r?����R���r?/H�>6�>�r?���><�>�r?z?>��=�r?$�����!��r?��!�AQf1�r?�`��v����r?��
�v����r?MO�>6�>�r?z?����r?��!�AQf1�r?Pb?�4�>�r?��
?���>�r?��>���>�r?�}��6վ�r?��
?c��>�r?���>�?�r?/H�>X�?�r?�`��X����r?��}>�4�>�r?��y?��r?LO�>X�?�r?���R���r?��=y?>�r?����+���r?��>c��>ޛ�>u��>  �?n�>�*�>  �?�)�>I�>  �?C��>���>  �?�=�>�*�>  �?�?t��>  �?��
?���>  �?q"�>I�>  �? ��>��>  �? ��>$<�>  �?�=���,��  �?��>���  �?��
�_���  �?�"����  �?�Ͼ���  �?�Ͼ�=��  �?m�>��?  �?ޛ�>���>  �?C��>v��>  �?�)�>b�?  �?�j?5�>  �?qO?5�>  �?�?���>  �?�=�>��?  �?q"�>b�?  �?��
?w��>  �? ��>2?  �? ��>�?  �?����,��  �?�)����  �?��b���  �?�=��y��  �?�"��F��  �?��
�A���  �?��x>5�>  �?>Z}>5�>  �?���y��  �?𛇾b���  �?U���A���  �?�)��F��  �?�Ͼ�2�  �?�Ͼ��  �?𛇾>���  �?U���_���  �?��x��6վ  �?aZ}��6վ  �?�j��6վ  �?yO��6վ  �?q"�>b�?~�~?��
?w��>~�~?�"����~�~?�Ͼ�=��~�~? ��>$<�>~�~?�)�>I�>~�~?>Z}>5�>~�~?C��>v��>~�~?U���A���~�~?�)��F��~�~?qO?5�>~�~?��
?���>~�~?aZ}��6վ~�~?�Ͼ��~�~?�)����~�~?q"�>I�>~�~?��
�A���~�~?yO��6վ~�~?U���_���~�~?��
�_���~�~? ��>�?~�~?C��>���>~�~?�"��F��~�~?�)�>b�?~�~?yO��6վ�r?��
�_����r?U���_����r?aZ}��6վ�r? ��>�?�r?q"�>b�?�r?�"�����r?�)�>I�>�r?C��>���>�r?��
?w��>�r?qO?5�>�r?�"��F���r?��
�A����r?C��>v��>�r?�)�>b�?�r?�Ͼ���r?>Z}>5�>�r?�Ͼ�=���r? ��>$<�>�r?U���A����r?�)��F���r?��
?���>�r?�)�����r?q"�>I�>�r?      �?G^&>K^�=  �?B>��=  �?x?>�8/  �?��!>G^��  �?C>��  �?y?>D���?F^�=z?���?��=�t2  �?G^&�H^��  �?C���  �?y?�p�o2  �?��!�G^&>  �?�x*1D>  �?E^��z?>  �?����!>  �?�1G^�=  �?C���=  �?y?�D>  �?E^�=G^&>  �?�x*1��!>  �?�1z?>  �?��=G^&���?�X���!���?���C���?H^��y?���?�񡽓1~�~?��!>��~�~?y?>y?�}�~?����~�~?y?���=~�~?x?>�%�2~�~?��!���=~�~?y?�z?>�~?��z?�}�~?��=��!�}�~?�����!>�~?�1z?>�~?��=��!>�~?�1{?>�r?��=��=�r?x?>r
�2�r?��!>���r?y?>x?��r?�����r?y?��f3�r?��!���=�r?y?�{?>�r?��y?��r?��=��!��r?�����!>�r?�1��!>�r?�1w      �%�  ���%���  ��y����j�  ���6վ�=��  ������Ͼ  ��3���>  ��3��%?  ���%��=�>  ������?  ��y����j?  ���6վ�%?  ���%?�?  �����>�j?  ���4�>�Ͼ  ��2?�%�  ���%?�=��  ����?��  �����>�=�>  ����?��>  ��2?�j�  ���4�>�%?�%�  ���=�>���  ���?����  ����>��>  ����> ��6  ��K^&>  @�  ���%��%�  ��������  ���=�����  ���=����?  ���%��%?  ���Ͼ3?  ���?y��>  ���=�>��?  ���%?�%?  ����>2�  ����x��>  ����x>�4վ  ��  �4�4վ  ��  �3G^&�  ����x��6�>  ��   4�6�>  ��  �3G^&>  ���Ͼ��>  ��D^&�  @�  ���Ͼ ��6  ���j��6�>  ���j?�6�>  ����>3?  ���j?�4վ  ���j��4վ  ���Ͼ2�  ����>���  ���Ͼ���  ����x>�6�>  ����x��4վ  ��  ���?���>  ���%?�%?  ���j?5�>  ���=�>��?  ���j?�6վ  ���%?�%�  ���?b���  ����b���  ���=��y��  ���%��%�  ���=�>y��  ����>�2�  ���Ͼ�2�  ���j��6վ  ���j�5�>  ���%��%?  �������>  ���=����?  ���Ͼ2?  ����>2?  �?Pc�>��?  �?��%?�%?  �?���>2?  �?����,��  �?��%�  �0  �?0��U���  �?��?���>  �?��9�%?  �?��%��%�  �?������  �?0��y���  �?q}?�4�>  �?�W��6վ  �?>�Ͼ3�  �?��9�%�  �?�襾���  �?v��y���  �?+4�>��?  �?���>���>  �?Pc�>�*�>  �?��%?      �?��?a��>  �?H��=C�  �?��%?�%�  �?�_>H^��  �?Kǥ�B>  �?��%��%?  �?���E^�=ޛ�>���>  �?  0��%?  �?��x>5�>  �?�=�>��?  �?�%?�%?  �? ��>2?  �?  ��%�  �?  P�      �?��x��6վ  �?ޛ�>u��>  �?�%��%�  �?�=��y��  �?��b���  �?����,��  �?�Ͼ���  �?�%�  �  �?𛇾>���  �?�=���,��  �?��>���  �?�j��6վ  �?�?���>  �?�Ͼ�2�  �?���y��  �?𛇾b���  �?n�>�*�>  �? ��>��>  �?�%?  �  �?�j?5�>  �?�=�>�*�>  �?�?t��>  �?m�>��?  �?K^�=  �?B>�%? �?�%?D>  �?E^�=D���?F^�=�%���?�%?G^��  �?C>D>  �?E^���%? �?�%�G^�=  �?C�H^��  �?C��%���?�%�C���?H^��<B���<B?�6B��T~��`X?m5X�]}�m5X?�`X��T~��6B?+B�=�z�(�h?��W��y��6h?�6h��y���W?)�h�;�z�+B?�g�b�v��g?�%�U���<B?�<B�U���%?�%���~��fX?�%���z���h?�%��t��t?)$B�H�s�H�s?�W��s��s?eFf���p���p?jn�hn�hn?��p���p�eFf?�s��s��W?G�s�G�s�)$B?��h���z��%?�t��t��%?�fX���~��%?<B�<B��?�`X��6B��T~?m5X�m5X�]}?�6B��`X��T~?*�h�+B�=�z?�6h���W��y?��W��6h��y?+B�)�h�;�z?�g��g�b�v?�%��%�  �?�<B��%�U�?�%��<B�U�?�fX��%���~?��h��%���z?�t��%��t?H�s�)$B�H�s?�s��W��s?��p�dFf���p?jn�hn�hn?eFf���p���p?�W��s��s?)$B�H�s�H�s?�%���h���z?�%��t��t?�%��fX���~?�%��fX���~?  ���fX���~?   1�<B�U�?   ��t��t?  1��h���z?�%���h���z?  ��%�  �?�%��%�  �?��z���h�   ���z���h��%?��~��fX��%?��~��fX�  @1U���<B��%?U���<B�  @0�t��t�    �t��t��%?  ���%��%?  ���%�   �;�z�)�h�+B?�y��6h���W?_}�k5X�l5X?�T~��`X��6B?c�v��g��g?�y���W��6h?�T~��6B��`X?��<B�<B?<�z�+B�)�h?G�s�G�s�)$B?�s��s��W?��p���p�eFf?jn�hn�hn?��p�dFf���p?�s��W��s?H�s�)$B�H�s?�t��%��t?��z��%���h?��~��%��fX?U���%��<B?��h�   1��z?��h��%���z?�fX��%���~?�fX�   ���~?�<B�  �0U�?�t�    �t?�%�  �  �?��z�   ���h?��~�  ���fX?��~��%��fX?��z��%���h?  ���%��%?U���%��<B?T��   ��<B?  ��  1�%?�t�    �t?    ��z���h?�%���z���h?�%���~��fX?   0��~��fX?�%�U���<B?  �U���<B?   ��t��t?  p�  ���%?�<B�U��  �1�fX���~�    ��h���z�   ��%�  ��  �/�t��t�    <B?��<B?�`X?�T~��6B?m5X?]}�m5X?�6B?�T~��`X?*�h?=�z�+B?�6h?�y���W?��W?�y��6h?+B?;�z�'�h?�g?b�v��g?�<B?U���%?�%?U���<B?�fX?��~��%?��h?��z��%?�t?�t��%?H�s?H�s�)$B?�s?�s��W?��p?��p�cFf?in?in�jn?fFf?��p���p?�W?�s��s?)$B?G�s�G�s?�%?��z���h?�%?�t��t?�%?��~��fX?<B?<B��?�6B?�`X��T~?m5X?m5X�]}?�`X?�6B��T~?+B?*�h�=�z?��W?�6h��y?�6h?��W��y?)�h?+B�;�z?�g?�g�b�v?�%?�%�  �?�%?�<B�U�?�<B?�%�U�?�%?�fX���~?�%?��h���z?�%?�t��t?)$B?G�s�G�s?�W?�s��s?fFf?��p���p?in?in�jn?��p?dFf���p?�s?�W��s?G�s?($B�G�s?��h?�%���z?�t?�%��t?�fX?�%���~?�%?�fX���~?�%?��h���z?��z?��h�   /��~?�fX�  `1��~?�fX��%?��z?��h��%?  �?��%��%?U�?�<B��%?T�?�<B�  ��  �?��%�  �0�t?�t��%?�t?�t�  �0<�z?)�h�+B?�T~?�`X��6B?^}?l5X�m5X?�y?�6h���W?�?<B�<B?�T~?�6B��`X?�y?��W��6h?b�v?�g��g?<�z?+B�)�h?H�s?H�s�)$B?U�?�%��<B?��~?�%��fX?��z?�%���h?�t?�%��t?G�s?($B�G�s?�s?�W��s?��p?dFf���p?��p?��p�cFf?in?in�jn?�s?�s��W?��h?  ����z?�fX?  `���~?�fX?�%���~?��h?�%���z?�%?  �  �?�<B?�%�U�?�<B?  �1T�?�t?  @1�t?��z?   1��h?��z?�%���h?��~?   ��fX?U�?   0�<B?�t?  @1�t?  �?��%��%?  �?��9�%?�%?��z���h?�%?U���<B?�<B?U��   0�fX?��~�  ���t?�t�  �0��h?��z�   /�%?  ��  @�<B��?<B?�`X��T~?�6B?m5X�]}?m5X?�6B��T~?�`X?*�h�=�z?+B?�6h��y?��W?��W��y?�6h?+B�;�z?'�h?�g�b�v?�g?�<B�U�?�%?�%�U�?�<B?�fX���~?�%?��h���z?�%?�t��t?�%?H�s�H�s?)$B?�s��s?�W?��p���p?cFf?in�in?jn?fFf���p?��p?�W��s?�s?)$B�G�s?G�s?�%���z?��h?�%��t?�t?�%���~?�fX?<B�<B?�?�6B��`X?�T~?m5X�m5X?]}?�`X��6B?�T~?+B�*�h?=�z?��W��6h?�y?�6h���W?�y?)�h�+B?;�z?�g��g?b�v?�%��%?  �?�%��<B?U�?�<B��%?U�?�%��fX?��~?�%���h?��z?�%��t?�t?)$B�G�s?G�s?�W��s?�s?fFf���p?��p?in�in?jn?��p�dFf?��p?�s��W?�s?G�s�($B?G�s?��h��%?��z?�t��%?�t?�fX��%?��~?   1�<B?U�?    �fX?��~?�%��fX?��~?    ��h?��z?�%���h?��z?  0��%?  �?    �t?�t?��z���h?   /��~��fX?  `1��~��fX?�%?��z���h?�%?  ���%?�%?U���<B?�%?T���<B?  ��  ���%?   ��t��t?�%?�t��t?  �0<�z�)�h?+B?�T~��`X?�6B?^}�l5X?m5X?�y��6h?��W?��<B?<B?�T~��6B?�`X?�y���W?�6h?b�v��g?�g?<�z�+B?)�h?H�s�H�s?)$B?U���%?�<B?��~��%?�fX?��z��%?��h?�t��%?�t?G�s�($B?G�s?�s��W?�s?��p�dFf?��p?��p���p?cFf?in�in?jn?�s��s?�W?�fX��%?��~?��h��%?��z?�<B��%?U�?��z��%?��h?  ���%?�%?  ���z?��h?   0��~?�fX?�%���z?��h?  @0  �?�%?�%�U�?�<B?  @�T�?�<B?    �t?�t?�<B�U�?   0�fX���~?  ���t��t?  �0��h���z?   /�%���?���<B?�?<B?�6B?�T~?�`X?m5X?]}?m5X?�`X?�T~?�6B?+B?=�z?(�h?��W?�y?�6h?�6h?�y?��W?)�h?;�z?+B?�g?b�v?�g?�%?U�?�<B?�<B?U�?�%?�%?��~?�fX?�%?��z?��h?�%?�t?�t?)$B?H�s?H�s?�W?�s?�s?eFf?��p?��p?jn?hn?hn?��p?��p?eFf?�s?�s?�W?G�s?G�s?)$B?��h?��z?�%?�t?�t?�%?�fX?��~?�%?<B?<B?�?�`X?�6B?�T~?m5X?m5X?]}?�6B?�`X?�T~?*�h?+B?=�z?�6h?��W?�y?��W?�6h?�y?+B?)�h?;�z?�g?�g?b�v?�%?�%?  �?�<B?�%?U�?�%?�<B?U�?�fX?�%?��~?��h?�%?��z?�t?�%?�t?H�s?)$B?H�s?�s?�W?�s?��p?dFf?��p?jn?hn?hn?eFf?��p?��p?�W?�s?�s?)$B?H�s?H�s?�%?��h?��z?�%?�t?�t?�%?�fX?��~?�%?�fX?��~?�%?��h?��z?�%?�%?  �?��z?��h?   ���z?��h?�%?��~?�fX?�%?��~?�fX?  @1U�?�<B?�%?U�?�<B?  @0�t?�t?    �t?�t?�%?  �?��%?�%?  �?��%?    ;�z?)�h?+B?�y?�6h?��W?_}?k5X?l5X?�T~?�`X?�6B?c�v?�g?�g?�y?��W?�6h?�T~?�6B?�`X?�?<B?<B?<�z?+B?)�h?G�s?G�s?)$B?�s?�s?�W?��p?��p?eFf?jn?hn?hn?��p?dFf?��p?�s?�W?�s?H�s?)$B?H�s?�t?�%?�t?��z?�%?��h?��~?�%?�fX?U�?�%?�<B?��h?�%?��z?�fX?�%?��~?��~?�%?�fX?��z?�%?��h?  �?��%?�%?U�?�%?�<B?�%?��z?��h?�%?��~?�fX?�%?U�?�<B?�<B?U�?  �1�fX?��~?    ��h?��z?   ��%? �?��
0�t?�t?    <B���<B��`X��T~��6B�m5X�]}�m5X��6B��T~��`X�*�h�=�z�+B��6h��y���W���W��y��6h�+B�;�z�'�h��g�b�v��g��<B�U���%��%�U���<B��fX���~��%���h���z��%��t��t��%�H�s�H�s�)$B��s��s��W���p���p�cFf�in�in�jn�fFf���p���p��W��s��s�)$B�G�s�G�s��%���z���h��%��t��t��%���~��fX�<B�<B����6B��`X��T~�m5X�m5X�]}��`X��6B��T~�+B�*�h�=�z���W��6h��y��6h���W��y�)�h�+B�;�z��g��g�b�v��%��%�  ���%��<B�U���<B��%�U���%��fX���~��%���h���z��%��t��t�)$B�G�s�G�s��W��s��s�fFf���p���p�in�in�jn���p�dFf���p��s��W��s�G�s�($B�G�s���h��%���z��t��%��t��fX��%���~�   1�<B�U��    �fX���~��%��fX���~�    ��h���z��%���h���z� � ��%�  ��    �t��t���~��fX��%���z���h��%�  ���%��%�U���<B��%��t��t��%�<�z�)�h�+B��T~��`X��6B�^}�l5X�m5X��y��6h���W���<B�<B��T~��6B��`X��y���W��6h�b�v��g��g�<�z�+B�)�h�H�s�H�s�)$B�U���%��<B���~��%��fX���z��%���h��t��%��t�G�s�($B�G�s��s��W��s���p�dFf���p���p���p�cFf�in�in�jn��s��s��W���h�  ����z��fX�  `���~��fX��%���~���h��%���z��%� 0�4  ���<B��%�U���<B�  �1T���t�  @1�t���z�   1��h���z��%���h���~�   ��fX�U��   0�<B��t�  @1�t�  ���%��%�  ��  �0�%�  ���z���h�   0��~��fX��%���z���h�  �  ���%��%�U���<B�  @�T���<B�    �t��t�<B?��<B��6B?�T~��`X�m5X?]}�m5X��`X?�T~��6B�+B?=�z�(�h���W?�y��6h��6h?�y���W�)�h?;�z�+B��g?b�v��g��%?U���<B��<B?U���%��%?��~��fX��%?��z���h��%?�t��t�)$B?H�s�H�s��W?�s��s�eFf?��p���p�jn?hn�hn���p?��p�eFf��s?�s��W�G�s?G�s�)$B���h?��z��%��t?�t��%��fX?��~��%�<B?<B����`X?�6B��T~�m5X?m5X�]}��6B?�`X��T~�*�h?+B�=�z��6h?��W��y���W?�6h��y�+B?)�h�;�z��g?�g�b�v��%?�%�  ���<B?�%�U���%?�<B�U���fX?�%���~���h?�%���z��t?�%��t�H�s?)$B�H�s��s?�W��s���p?dFf���p�jn?hn�hn�eFf?��p���p��W?�s��s�)$B?H�s�H�s��%?��h���z��%?�t��t��%?�fX���~��%?�fX���~��%?��h���z��%?�%�  ����z?��h��%���~?�fX��%�U�?�<B��%��t?�t��%�  �?��%��%�;�z?)�h�+B��y?�6h���W�_}?k5X�l5X��T~?�`X��6B�c�v?�g��g��y?��W��6h��T~?�6B��`X��?<B�<B�<�z?+B�)�h�G�s?G�s�)$B��s?�s��W���p?��p�eFf�jn?hn�hn���p?dFf���p��s?�W��s�H�s?)$B�H�s��t?�%��t���z?�%���h���~?�%��fX�U�?�%��<B���h?   1��z���h?�%���z��fX?�%���~��fX?   ���~��<B?  �0U���t?    �t��%? �4  ����z?   ���h���~?  ���fX���~?�%��fX���z?�%���h�  �?��%��%�U�?�%��<B�T�?   ��<B�  �?��9�%��t?    �t��%?��z���h��%?��~��fX��%?U���<B�<B��?<B��6B��T~?�`X�m5X�]}?m5X��`X��T~?�6B�+B�=�z?(�h���W��y?�6h��6h��y?��W�)�h�;�z?+B��g�b�v?�g��%�U�?�<B��<B�U�?�%��%���~?�fX��%���z?��h��%��t?�t�)$B�H�s?H�s��W��s?�s�eFf���p?��p�jn�hn?hn���p���p?eFf��s��s?�W�G�s�G�s?)$B���h���z?�%��t��t?�%��fX���~?�%�<B�<B?���`X��6B?�T~�m5X�m5X?]}��6B��`X?�T~�*�h�+B?=�z��6h���W?�y���W��6h?�y�+B�)�h?;�z��g��g?b�v��%��%?  ���<B��%?U���%��<B?U���fX��%?��~���h��%?��z��t��%?�t�H�s�)$B?H�s��s��W?�s���p�dFf?��p�jn�hn?hn�eFf���p?��p��W��s?�s�)$B�H�s?H�s��%���h?��z��%��t?�t��%��fX?��~��%��fX?��~�  ���fX?��~�   1�<B?U��   ��t?�t�  1��h?��z��%���h?��z� � ��%?  ���%��%?  ����z���h?�%���~��fX?�%�U���<B?�%��t��t?�%�  ���%?�%�;�z�)�h?+B��y��6h?��W�_}�k5X?l5X��T~��`X?�6B�c�v��g?�g��y���W?�6h��T~��6B?�`X���<B?<B�<�z�+B?)�h�G�s�G�s?)$B��s��s?�W���p���p?eFf�jn�hn?hn���p�dFf?��p��s��W?�s�H�s�)$B?H�s��t��%?�t���z��%?��h���~��%?�fX�U���%?�<B���h��%?��z��fX��%?��~���~��%?�fX���z��%?��h�  ���%?�%�U���%?�<B�    ��z?��h��%���z?��h��%���~?�fX�   0��~?�fX��%�U�?�<B�  �U�?�<B�   ��t?�t�  @�  �?�%�<B?�?<B��`X?�T~?�6B�m5X?]}?m5X��6B?�T~?�`X�*�h?=�z?+B��6h?�y?��W���W?�y?�6h�+B?;�z?'�h��g?b�v?�g��<B?U�?�%��%?U�?�<B��fX?��~?�%���h?��z?�%��t?�t?�%�H�s?H�s?)$B��s?�s?�W���p?��p?cFf�in?in?jn�fFf?��p?��p��W?�s?�s�)$B?G�s?G�s��%?��z?��h��%?�t?�t��%?��~?�fX�<B?<B?���6B?�`X?�T~�m5X?m5X?]}��`X?�6B?�T~�+B?*�h?=�z���W?�6h?�y��6h?��W?�y�)�h?+B?;�z��g?�g?b�v��%?�%?  ���%?�<B?U���<B?�%?U���%?�fX?��~��%?��h?��z��%?�t?�t�)$B?G�s?G�s��W?�s?�s�fFf?��p?��p�in?in?jn���p?dFf?��p��s?�W?�s�G�s?($B?G�s���h?�%?��z��t?�%?�t��fX?�%?��~��%?�fX?��~��%?��h?��z���~?�fX?�%���z?��h?�%�  �?��%?�%�U�?�<B?�%��t?�t?�%�<�z?)�h?+B��T~?�`X?�6B�^}?l5X?m5X��y?�6h?��W��?<B?<B��T~?�6B?�`X��y?��W?�6h�b�v?�g?�g�<�z?+B?)�h�H�s?H�s?)$B�U�?�%?�<B���~?�%?�fX���z?�%?��h��t?�%?�t�G�s?($B?G�s��s?�W?�s���p?dFf?��p���p?��p?cFf�in?in?jn��s?�s?�W��fX?�%?��~���h?�%?��z��<B?�%?U����z?�%?��h�  �?��%?�%��%?��z?��h��%?U�?�<B�K^��  ���,��s��  ���,��㛇�  ��U���D�  ��U���Y��  ��2?��x�  ���6վG^&�  ���6վD�  ��y���㛇�  ��y������>  ��U���D>  ��U���G^&>  ���6վ��x>  ���6վ���  ��3�G^�=  ���,��M^�=  �����.  P�  ��  �/�ᶰ  �����G^&�  ���4�>��x�  ���4�>㛇�  ��a��>D�  ��a��>H^�=  �������>  ��������>  ��y���C>  ��y�����x>  ���4�>G^&>  ���4�>C>  ��a��>���>  ��a��>D�  �����>㛇�  �����>K^��  ����?s��  ����?s��  ���*�>G^��  ���*�>H^�=  ���*�>��>  ���*�>D>  �����>���>  �����>s��  �����G^��  �������>  ����?G^�=  ����?H^��  ��  �/���  ����>��>  ��������>  ���,�����  ����>s��  ��  �/��>  �������>  ��������>  ����>�Ͼ  ��  �/�Ͼ  ������Ͼ  ����>�=�>  ���,���=�>  ��b� ��=�>  ���*�>�=��  ��  �/�=��  ���,���=��  ���*�>��  ��  �/��  ��U�����  ��a��>�?  ��U����?  �����?  ��a��>�j�  ��  �/�=���*��  ���=�� ��6  ����c���  ���� ��6  ��@�F^�=  ��t���,�>  ��H>J^��  ����>�*��  �����>c���  ��P^�=C�  ��D^��C�  ��䛇�c���  ��t���*��  ��@�J^��  ��䛇�U��>  ��@^��C>  ��P^�=C>  ��>V��>  ��}�>�,�>  ��H>F^�=  ���%? �4  ���j? ��6  ���=�> ��6  ���=�>�*��  ��  �4����  ��䛇�����  ��   4y��>  ��>x��>  ��   4��?  ��~�>��?  ���? ��6  ���?c���  ��  �4���  ��t�����  ���j� ��6  ��   43?  �� � ��%?  ��  �42�  �� � ��%�  ����>���  ���%� 0�4  ��t����?  �����>����  ��䛇�y��>  ���?U��>  ���=�>�,�>  ����U��>  ���=���,�>  ��  ����h1���>  ������>  ��}����?  ��Όk1��?  ����d15�>  ����x�5�>  ���1�2�  ���1w��  ��z�>y��  ����1c���  ��ꛇ>b���  ��䛇�b���  ��t��y��  ��ꛇ>���>  ��z�>��?  ����>���  ����>  ��  ���=�>  ��  ���=�>�,��  ����>��>  ����>  ��  ��z�>�*�>  ����x��6վ  ��r�&1�6վ  ����x>�6վ  ��3�.1<���  ��ꛇ>>���  ���Ͼ���  ���Ͼ�8�  �����/'�  ��s���,��  ���Ͼ��>  ���=��% �  ���=���*�>  ��;�`1r��>  ���u��>  ����x>5�>  ��[�l12?  ��  �0�%�  ������  ����t��>  ���=���,��  ����>���  ���j��-�  ���=�>�*�>  ���?  ��  ���?>���  ���?v��>  ���j?  ��  ��z�>�,��  ���>  ��  ��ꛇ>v��>  ��  P1  ��  ��񛇾�c԰  ��~���*�>  ��䛇�>���  ���%�   �  ���%?   �  ��  1�%?  �?���9G^&>  �?v��U���  �?Gǥ�C�  �?���E^��  �?�襾�,��  �?���9G^&�  �?�&�j1  �?>�Ͼ���  �?,4�>�*�>  �?�_>F^�=  �?ǩ&>���  �?���>��>  �?5�x��6վ  �?59y>�4�>  �?G��=C>  �?���>a��>  �?�&�j1�%��%?  �?�%?�%�  �?      �?G^&>G^&���?�Xᱟt2  �?G^&�G^&>  �?�x*1G^&>  �?�x*1      �?                                      �<      �                      �?      �<                                      �?   @�z�?                                   @�z��                                   @�z��                                      �?      Y�   �yU�                   �yU�>      Y�                                      Y@                                      �?           (              *   O       �      �       ��;-) primChildren dice defaultPrim upAxis Y metersPerUnit customLayerData author  copyright generator fab-model-conversion title url specifier typeName Xform assetInfo name kind component Materials Meshes Scope Dice_White_Mat QBlack 5 � pbr_shader properties outputs:surface S" �info:id in �diffuseColo  �metallic$ �roughness dnormal zemissivD Qocclu�Sketchfab_8  x�Op:scale  Or�  Ptrans' �( _d0b667003424464918f01bf0c2690c0_fbx RootNode Cube_001	 _B+_0 M!_0z� subdivi� �Scheme points �  s K�VertexIn` 0Cou+ �extent doubleSided m��:binding api` %as�B �API bool variability�� float3[] int[] token UsdPreviewS�c�"3f/ � �3f targetPath� "3fL �erpolation v� p connec 0 / BnoneZ 3� �rix4d token[] 	          	   
                     J       H        �%    UUUUTUEUTQU@�������,�- ��-
��-�-�-�-�        X  0)  C @ d 1	 l  P  *@ A @� 1  1@� 1)  @@	 0)  C @   R 3@, T ` p � � � � � 0h � � 1  � 3) ;   # , 3@> 3�( ? H 3�l �  2! 0�@ C @A B  P @�$
 0 C  5@D  � `@  �? 1� @ͽ�> �@ @" 	%1 0" F A @ 3�H  �T	 @��� 3" � J A @� @��� 0�K C @L  dd�3@M  �	 3 � �  @� N A @� ����    ��       �        �   @EEQTQEUAQEUTUUUTEQUUUTUUUUQ �v ����
��������	��!�!�$�$�$�$�)��+�+�.�0�.�.�.���7�7��)�)�)�=�=�)�!�A�C�C�C�C�H�*�H�+�@       @       3        �   U T U �U  (��(��+� ��*�?        R   U �
EQEE	��:�����7� �5��P�T�U�V�X�X��_�W��0        �    Q T EQE@E@�����  ������@               @     �P     ��@        �   UUUU UD @UU � ��
  �    � �              �       	 �     ���       TOKENS          ��      �      STRINGS         ��      ,       FIELDS          ��      �      FIELDSETS       ��      �       PATHS           ��      �       SPECS           i�      �       PK  
     �>�Y!�a���  ��  	                dice.usdc�                      PK      P   �    
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
  },
  {
    "id": "treasure_cursed_lantern",
    "name": "Cursed Lantern",
    "description": "An old lantern that glows with an eerie light.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "from Cursed Lantern"
    },
    "tags": ["Haunted", "Light Source"]
  },
  {
    "id": "treasure_silver_key",
    "name": "Silver Key",
    "description": "Opens a locked door somewhere in the tomb.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "from Silver Key"
    },
  "tags": ["Key"]
  },
  {
    "id": "treasure_test_gem",
    "name": "Test Gem",
    "description": "Glows with uncertain power.",
    "grantedModifier": { "bonusDice": 1, "description": "from Test Gem" },
    "tags": ["Test"]
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
    ,
    {
      "id": "template_shadowy_corner",
      "title": "Shadowy Corner",
      "description": "Darkness conceals something here.",
      "tags": ["Dark"],
      "availableActions": [
        {
          "name": "Illuminate",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "requiredTag": "Light Source",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_ancient_coin" }, { "type": "removeInteractable", "id": "self" } ]
          }
        }
      ]
    },
    {
      "id": "template_locked_door",
      "title": "Locked Door",
      "description": "A heavy door with a silver keyhole.",
      "tags": ["Door"],
      "availableActions": [
        {
          "name": "Use Silver Key",
          "actionType": "Tinker",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "requiredTag": "Key",
          "outcomes": { "success": [ { "type": "removeInteractable", "id": "self" } ] }
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
  ],
  "examples_dynamic": [
    {
      "id": "example_simple_lever",
      "title": "Simple Lever",
      "description": "A lever with warning signs.",
      "availableActions": [
        {
          "name": "Throw the Lever",
          "actionType": "Tinker",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              {
                "type": "gainTreasure",
                "treasureId": "treasure_test_gem",
                "conditions": [
                  { "type": "requiresMinEffectLevel", "effectParam": "great" }
                ]
              }
            ],
            "failure": [
              {
                "type": "sufferHarm",
                "level": "lesser",
                "familyId": "gear_damage",
                "conditions": [
                  { "type": "requiresMinPositionLevel", "positionParam": "desperate" }
                ]
              }
            ]
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
  },
  {
    "id": "treasure_cursed_lantern",
    "name": "Cursed Lantern",
    "description": "An old lantern that glows with an eerie light.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "from Cursed Lantern"
    },
    "tags": ["Haunted", "Light Source"]
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
    ,
    {
      "id": "template_wall_switch",
      "title": "Wall Switch",
      "description": "A lever that seems safe to pull.",
      "availableActions": [
        {
          "name": "Flip the switch",
          "actionType": "Tinker",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_ancient_coin" }, { "type": "removeInteractable", "id": "self" } ]
          }
        }
      ]
    },
    {
      "id": "template_shadowy_corner",
      "title": "Shadowy Corner",
      "description": "Darkness conceals something here.",
      "tags": ["Dark"],
      "availableActions": [
        {
          "name": "Illuminate",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "requiredTag": "Light Source",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_ancient_coin" }, { "type": "removeInteractable", "id": "self" } ]
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
  },
  {
    "id": "treasure_cursed_lantern",
    "name": "Cursed Lantern",
    "description": "An old lantern that glows with an eerie light.",
    "grantedModifier": {
      "bonusDice": 1,
      "description": "from Cursed Lantern"
    },
  "tags": ["Haunted", "Light Source"]
  },
  {
    "id": "treasure_test_gem",
    "name": "Test Gem",
    "description": "Glows with uncertain power.",
    "grantedModifier": { "bonusDice": 1, "description": "from Test Gem" },
    "tags": ["Test"]
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
    ,
    {
      "id": "template_wall_switch",
      "title": "Wall Switch",
      "description": "A lever that seems safe to pull.",
      "availableActions": [
        {
          "name": "Flip the switch",
          "actionType": "Tinker",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_ancient_coin" }, { "type": "removeInteractable", "id": "self" } ]
          }
        }
      ]
    },
    {
      "id": "template_shadowy_corner",
      "title": "Shadowy Corner",
      "description": "Darkness conceals something here.",
      "tags": ["Dark"],
      "availableActions": [
        {
          "name": "Illuminate",
          "actionType": "Survey",
          "position": "controlled",
          "effect": "standard",
          "requiresTest": false,
          "requiredTag": "Light Source",
          "outcomes": {
            "success": [ { "type": "gainTreasure", "treasureId": "treasure_ancient_coin" }, { "type": "removeInteractable", "id": "self" } ]
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
  ],
  "examples_dynamic": [
    {
      "id": "example_setpiece_machine",
      "title": "Arcane Machine",
      "description": "Cables snake from a humming device.",
      "availableActions": [
        {
          "name": "Experiment with Device",
          "actionType": "Study",
          "position": "risky",
          "effect": "standard",
          "outcomes": {
            "success": [
              { "type": "gainTreasure", "treasureId": "treasure_test_gem" },
              {
                "type": "gainStress",
                "amount": 1,
                "conditions": [
                  { "type": "clockProgress", "stringParam": "Test Clock", "intParam": 2 }
                ]
              },
              {
                "type": "gainTreasure",
                "treasureId": "treasure_test_gem",
                "conditions": [
                  { "type": "characterHasTreasureId", "stringParam": "treasure_test_gem" }
                ]
              }
            ],
            "failure": [
              { "type": "sufferHarm", "level": "moderate", "familyId": "electric_shock" },
              { "type": "tickClock", "clockName": "Test Clock", "amount": 1 },
              {
                "type": "sufferHarm",
                "level": "lesser",
                "familyId": "electric_shock",
                "conditions": [
                  { "type": "characterHasTreasureId", "stringParam": "treasure_test_gem" }
                ]
              }
            ]
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

### `Docs/S15_3DDiceRollVisualization/3-PhysicsBasedDiceRoll.md`

```

Task 3: Implementing Physics-Based Rolling
Description: Add physics to the dice and the tray. Implement a mechanism to "roll" the dice by applying forces, allowing them to tumble and settle realistically.

Actions:

Add Physics Bodies in DieNode.swift (or setup in SceneKitDiceView):
For each die SCNNode, create and assign an SCNPhysicsBody.
Type: .dynamic.
Shape: Use SCNPhysicsShape created from the die's geometry (or a slightly simplified convex hull/box shape for performance if needed).
Properties: Experiment with and set initial values for mass, friction, restitution (bounciness), rollingFriction, and angularDamping/damping.
Implement Roll Trigger in SceneKitDiceView.swift:
Add a public method, e.g., rollDice().
When rollDice() is called:
For each die node:
Reset its position to slightly above the tray floor, spread out a bit.
Apply a random initial linear force or impulse (upwards and sideways).
Apply a random initial torque (angular force) to make them spin.
Ensure physics is active for these dice.
Connect to DiceRollView.swift:
When the "Roll the Dice!" button is tapped in DiceRollView.swift:
Call the rollDice() method on the SceneKitDiceView instance.
The existing startShaking() logic (sound, vignette) can be repurposed or timed to coincide with the 3D roll initiation.
```

### `Docs/S15_3DDiceRollVisualization/7-CleanupAndPerformanceTesting.md`

```

Task 7: Cleanup and Performance Testing
Description: Remove obsolete 2D dice code, ensure the 3D dice view performs well, and clean up any debugging aids.

Actions:

Remove Old 2D Dice Code:
Delete the Image(systemName: "die.face...") rendering logic from DiceRollView.swift.
Remove unused @State variables related to 2D dice animations (diceOffsets, diceRotations, potentially diceValues if SceneKitDiceView manages its own state completely).
Performance Profiling:
Test the 3D dice roll on various target devices, especially with the maximum number of dice.
Profile using Xcode's tools to identify any performance bottlenecks (e.g., overly complex physics shapes, too many draw calls).
Optimize die models/textures or physics settings if necessary.
Disable Debug Features:
Turn off allowsCameraControl in the SCNView if it was enabled for debugging.
Remove any print statements or temporary debug overlays.
```

### `Docs/S15_3DDiceRollVisualization/5-FullIntegrationWithExistingSystems.md`

```

Task 5: Full Integration with DiceRollView and GameViewModel
Description: Connect the 3D dice rolling mechanism completely into the DiceRollView's state flow and ensure results are correctly passed back to the GameViewModel.

Actions:

Modify DiceRollView.swift State Management:
The isRolling state will now represent the 3D dice actively rolling.
The stopShaking() method's primary responsibility will shift:
It will be called (or its logic adapted) once SceneKitDiceView signals that the 3D dice have settled and results are available.
It will fetch the actualDiceRolled array from SceneKitDiceView.
It will then proceed to call viewModel.performAction(...) with these 3D results.
The rest of stopShaking() (setting self.result, highlightIndex, fadeOthers, popDie, showOutcome) will use the data derived from the 3D roll.
Adapt DiceRollView.onAppear:
Still needs to calculate projection and determine diceCount.
This diceCount should be passed to SceneKitDiceView to initialize the correct number of 3D dice.
The 2D diceValues, diceOffsets, diceRotations arrays can likely be removed or repurposed if not used for any other preliminary display.
Ensure DiceRollResult is Populated Correctly:
The actualDiceRolled: [Int]? field in DiceRollResult (returned by viewModel.performAction) will now be populated by the values read from the 3D dice. GameViewModel doesn't need to change its expectation of this data.
```

### `Docs/S15_3DDiceRollVisualization/4-ReadDiceResultsFromScene.md`

```

Task 4: Reading Dice Results from the 3D Scene
Description: Develop a reliable method to determine the numerical value of the "up" face of each die after it has come to rest, using the user-provided perspective-to-face mapping.

Actions:

Detect Settled State:
In SceneKitDiceView.swift (e.g., in renderer(_:updateAtTime:)), monitor each die's SCNPhysicsBody for isResting or near-zero velocity.
Signal DiceRollView when all dice have settled.
Determine "Up" Face and Value for Each Die:
Once a die SCNNode has settled, get its worldTransform.
Define the world "up" vector: worldUp = SCNVector3(0, 1, 0).
Extract the world-space directions of the die's local positive and negative X, Y, and Z axes from its worldTransform matrix.
Local +X: SCNVector3(transform.m11, transform.m12, transform.m13)
Local +Y: SCNVector3(transform.m21, transform.m22, transform.m23)
Local +Z: SCNVector3(transform.m31, transform.m32, transform.m33)
(And their negatives by negating components).
Calculate the dot product of each of these six world-space local-axis-directions with worldUp.
The local axis direction yielding the highest dot product is the one most pointing "up."
Use the user-provided mapping to convert this "winning" local axis direction to a face value:
Local +Y up: Face 5
Local -Y up: Face 2
Local +X up: Face 4
Local -X up: Face 3
Local -Z up: Face 6
Local +Z up: Face 1
Store Results:
Store the determined numerical value for each die.
Once all dice are settled and read, this array of results becomes the actualDiceRolled.
```

### `Docs/S15_3DDiceRollVisualization/1-SceneKitFoundationAndDiceTraySetup.md`

```

Task 1: SceneKit Foundation & Dice Tray Setup
Description: Establish the basic SceneKit view within the existing DiceRollView and create the foundational "dice tray" environment.

Actions:

Project Configuration:
Ensure the SceneKit framework is linked in the project.
Create SceneKitDiceView.swift:
Implement a new SwiftUI UIViewRepresentable struct named SceneKitDiceView.
This struct will wrap an SCNView.
makeUIView(context:):
Initialize an SCNView.
Create an SCNScene.
Set up a basic camera pointed downwards at an angle (like looking into a dice tray).
Add ambient and omnidirectional lighting for good visibility.
Create a large, flat SCNNode with an SCNPlane or SCNBox geometry to act as the "floor" or "tray surface." Assign a static SCNPhysicsBody to this floor.
Assign the scene to the SCNView.
Enable isPlaying and allowsCameraControl (for debugging, can be turned off later).
updateUIView(_:context:):
Initially, this can be empty. It will later be used to update the dice based on view model state.
Initial Integration into DiceRollView.swift:
In DiceRollView.swift, temporarily replace the HStack displaying the 2D dice Image views with an instance of SceneKitDiceView.
Pass necessary initial parameters to SceneKitDiceView (e.g., the number of dice to display, though actual dice will be added in Task 2).
Asset Callouts:

(Optional Texture) texture_dicetray_surface.png: A subtle texture for the floor of the dice tray (e.g., felt, wood, stone). Canvas Size: 512x512 pixels (tileable).
```

### `Docs/S15_3DDiceRollVisualization/2-3DDiceModelAndManagement.md`

```

Task 2: 3D Dice Model Integration and Instantiation
Description: Integrate the provided dice.usdz model and implement logic to dynamically add the correct number of dice instances to the SceneKit scene. Custom texturing is deferred if the default model appearance is acceptable.

Actions:

Integrate dice.usdz Model:
Add the dice.usdz file to the project bundle (e.g., in a "3DAssets" group, ensuring "Copy items if needed" and target membership are checked), not directly into Assets.xcassets if it caused issues.
Develop DieNode.swift (or similar helper structure/class):
This class/struct will be responsible for:
Loading the die model from dice.usdz. This involves loading the scene from the USDZ file and then extracting the specific SCNNode that represents the die geometry (e.g., by name or by traversing the loaded scene's node hierarchy).
Storing its current numerical value (to be determined in Task 4).
Holding a reference to its SCNNode instance.
(Deferred) Applying custom face textures: If the default appearance of dice.usdz is sufficient for now, applying custom textures like texture_d6_face_1.png can be deferred.
Update SceneKitDiceView.swift:
Add a property to hold an array of DieNode (or your custom die representation) instances.
In makeUIView or a new setup method:
Based on an input parameter (e.g., numberOfDice), instantiate the required number of DieNode objects. Each DieNode will load/clone its 3D model from the dice.usdz.
Position these dice initially above the tray floor.
Add each die's SCNNode to the scene.rootNode.
Pass the diceValues.count (derived from projection.finalDiceCount in DiceRollView.onAppear) to SceneKitDiceView to determine how many dice to show.
Asset Callouts:

3D Model: dice.usdz (Provided by user).
(Deferred Textures) texture_d6_face_1.png to texture_d6_face_6.png: Custom face textures are optional for the initial 3D implementation if the dice.usdz default appearance is acceptable.
```

### `Docs/S15_3DDiceRollVisualization/6-VisualPolishAndFeedback.md`

```

Task 6: Visual Polish, Feedback, and Sound Sync
Description: Refine the 3D dice roll visuals, integrate existing feedback mechanisms (like highlighting the highest die and pushed dice), and synchronize sound effects.

Actions:

Highlight Highest Die in 3D:
After results are read, identify the 3D DieNode that corresponds to the result.highestRoll.
In SceneKitDiceView, apply a visual effect to this die:
Change its material's emission property to make it glow (e.g., with a cyan color).
Optionally, add a subtle scaling animation or a temporary spotlight focused on it.
The popScale animation in DiceRollView might need to be rethought or removed if the 3D effect is sufficient.
Represent Pushed Dice:
If extraDiceFromPush > 0, visually distinguish the pushed die/dice in the 3D scene before the roll.
This could be a different initial color/texture, or a subtle emissive glow. SceneKitDiceView will need to be aware of which dice are "pushed."
Fade Other Dice:
The fadeOthers logic in DiceRollView (setting opacity of non-highlighted 2D dice to 0.5) should be replicated for the 3D dice.
Non-highlighted DieNode instances can have their opacity property animated or their materials made more transparent.
Sound Synchronization:
sfx_dice_shake.wav: Play when the 3D dice begin their roll animation.
sfx_dice_land.wav: Might need to be triggered multiple times as individual dice settle, or once when all dice are mostly still. SceneKit's physics contact delegates could be used for more precise sound timing if desired.
sfx_ui_pop.wav: Play when the highest die is highlighted in 3D and/or when the result.outcome text animates in.
Vignette Effect:
The showVignette and Image("vfx_damage_vignette") can still be used, timed with the initiation of the 3D roll.
Camera Polish (Optional):
Consider a subtle camera animation during the roll (e.g., a slight zoom in, a gentle shake).
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

### `Docs/S14_DynamicConsequencesAndRolls/4-UpdateContentSchemaAndCreateExampleContent.md`

```

### Task 4: Update Content Schema & Create Example Interactables

**Goal:** Document the new JSON capabilities for `interactables.json`, `treasures.json`, and create test content demonstrating the new conditional consequence system and roll dynamics.

**Actions:**

1.  **Update JSON Schema Documentation:**
    * For `interactables.json`: Detail the new `Consequence` struct format, including the `conditions` array and `GameCondition` objects, and parameters for each `ConditionType`. Specify how shallow vs. deep pools would be structured if there's a formal distinction (e.g., a flag, or just by the number of consequences listed).
    * For `treasures.json`: Add `tags: [String]?` to the `Treasure` schema if implementing `partyHasTreasureWithTag`.
2.  **Create Example Content in `Content/` & `Content/Scenarios/`:**
    * **Simple Interactable:** In `interactables.json` (or a scenario-specific version), define an interactable with:
        * An action leading to shallow consequence pools.
        * A negative consequence gated by `requiresMinPositionLevel: "desperate"`.
        * A positive consequence gated by `requiresMinEffectLevel: "great"`.
    * **Set-Piece Interactable (Template):**
        * Define an action with deeper pools of potential positive and negative consequences.
        * Include consequences gated by `characterHasTreasureId` (referencing a test treasure).
        * Include consequences gated by `clockProgress` (referencing a test clock).
    * **Test Treasure:** Add a treasure in `treasures.json` with a specific ID and optionally a tag, to be used by the gating conditions.
3.  **Initialize Test Clocks:** In `DungeonGenerator.swift` or `GameViewModel.startNewRun()`, ensure a test clock mentioned in a gated consequence can be initialized.
```

### `Docs/S14_DynamicConsequencesAndRolls/1-CoreRollMechanicEnhancements.md`

```

### Task 1: Core Roll Mechanic Enhancements (Zero Rating & Criticals)

**Goal:** Implement foundational changes to dice roll processing for zero action ratings and critical successes, making rolls more varied and their extreme outcomes more meaningful.

**Actions:**

1.  **Modify `GameViewModel.swift` - `performAction()`:**
    * **Zero Action Rating:** If a character's rating for the `action.actionType` is 0, roll 2d6 and set `effectiveHighestRoll` to the *minimum* of the two dice. Store both dice rolled.
    * **Critical Success:** After rolling all dice for any action (including the two for a zero-rating roll), count the number of 6s. If `sixes > 1` (or your chosen threshold), set an `isCritical` flag to true.
        * **Benefit:** For now, a critical success will increase the `finalEffect` by one step (e.g., Standard to Great). This can be logged in the `consequencesDescription`.
    * Store all `actualDiceRolled` from any roll.

    ```swift
    // In GameViewModel.swift - performAction()

    // ... Determine base characterActionRating, bonusDice ...
    var actualDiceRolled: [Int] = []
    var effectiveHighestRoll: Int
    var isCritical = false
    // let projection = calculateProjection(for: action, with: character) // Call this to get final dice, position, effect
    // let initialDiceCount = projection.finalDiceCount // Or however you determine actual dice to roll
    // let finalPosition = projection.finalPosition
    // var finalEffect = projection.finalEffect


    if character.actions[action.actionType] ?? 0 == 0 { // Check original rating for zero-roll mechanic
        let d1 = Int.random(in: 1...6)
        let d2 = Int.random(in: 1...6)
        actualDiceRolled = [d1, d2]
        effectiveHighestRoll = min(d1, d2)
        // Check for critical on 0-rating roll (e.g. double 6s still a crit, but outcome based on lowest)
        // This might be rare/impossible for 0-rating to be a "success" crit.
        // For now, focus criticals on positive outcomes from normal rolls.
    } else {
        let dicePool = max(projection.finalDiceCount, 1) // Use finalDiceCount from projection
        for _ in 0..<dicePool {
            actualDiceRolled.append(Int.random(in: 1...6))
        }
        effectiveHighestRoll = actualDiceRolled.max() ?? 0
        let sixes = actualDiceRolled.filter { $0 == 6 }.count
        if sixes > 1 { // Or your preferred critical condition
            isCritical = true
        }
    }

    if isCritical {
        // Example: Improve effect on critical, if the outcome is already positive
        if effectiveHighestRoll >= 4 { // Only boost effect on partial or full success crits
             finalEffect = finalEffect.increased()
             // Add note to consequences string later
        }
    }

    // ... determine outcomeString, consequencesToApply based on effectiveHighestRoll ...
    // ... consequencesDescription = processConsequences(...)

    // Ensure DiceRollResult includes these new fields
    return DiceRollResult(
        highestRoll: effectiveHighestRoll,
        outcome: outcomeString,
        consequences: consequencesDescription,
        actualDiceRolled: actualDiceRolled, // New
        isCritical: isCritical,             // New
        finalEffect: finalEffect            // New or ensure it's passed if modified
    )
    ```

2.  **Update `Models.swift` - `DiceRollResult` (defined in `CardGame/DiceRollView.swift` currently):**
    * Add `let actualDiceRolled: [Int]?`
    * Add `let isCritical: Bool?`
    * Add `let finalEffect: RollEffect?` (if not already there or to ensure it carries modifications).

3.  **Update `GameViewModel.swift` - `calculateProjection()`:**
    * If character's action rating is 0, add a specific note to `RollProjectionDetails.notes` (e.g., "`\(character.name)` has 0 rating in `\(action.actionType)`: Rolling 2d6, taking lowest.").
    * `RollProjectionDetails.finalDiceCount` could be set to `2` for display purposes in `DiceRollView` for 0-rating rolls.

4.  **Update `CardGame/DiceRollView.swift`:**
    * Modify `onAppear` to set initial `diceValues` count to 2 if `projection.notes` indicates a 0-rating roll (or if `projection.finalDiceCount` signals it).
    * In `stopShaking()`, use `result.actualDiceRolled` to populate `self.diceValues`.
    * Set `self.highlightIndex` to the index of `result.highestRoll` within `self.diceValues`.
    * Display "Critical Success!" and the `result.finalEffect` if `result.isCritical` is true.
```

### `Docs/S14_DynamicConsequencesAndRolls/3-ImplementConsequenceGatingAndPositionEffectModulation.md`

```

### Task 3: Implement Consequence Gating and Position/Effect Modulation

**Goal:** Refactor `GameViewModel.performAction` to filter consequences based on their new conditions and to use `finalEffect` and `finalPosition` to determine the quantity/potency of actual applied consequences.

**Actions:**

1.  **Create `areConditionsMet()` helper in `GameViewModel.swift`:**
    ```swift
    private func areConditionsMet(
        conditions: [GameCondition]?,
        forCharacter character: Character,
        finalEffect: RollEffect,
        finalPosition: RollPosition
        // Pass gameState directly or access self.gameState
    ) -> Bool {
        guard let conditions = conditions, !conditions.isEmpty else { return true } // No conditions means eligible

        for condition in conditions {
            var conditionMet = false
            switch condition.type {
            case .requiresMinEffectLevel:
                if let reqEffect = condition.effectParam { conditionMet = finalEffect.isBetterThanOrEqualTo(reqEffect) } //
            case .requiresExactEffectLevel:
                conditionMet = (condition.effectParam == finalEffect)
            case .requiresMinPositionLevel:
                if let reqPos = condition.positionParam { conditionMet = finalPosition.isWorseThanOrEqualTo(reqPos) } // Assuming Position enum gets an orderValue
            case .requiresExactPositionLevel:
                conditionMet = (condition.positionParam == finalPosition)
            case .characterHasTreasureId:
                if let tId = condition.stringParam { conditionMet = character.treasures.contains(where: { $0.id == tId }) } //
            case .partyHasTreasureWithTag:
                // Assuming Treasure struct gets a `tags: [String]?` field.
                // And GameCondition stringParam holds the tag.
                // conditionMet = gameState.party.flatMap { $0.treasures }.contains(where: { $0.tags?.contains(condition.stringParam ?? "") == true })
                print("WARN: partyHasTreasureWithTag condition not fully implemented yet.")
            case .clockProgress:
                if let cName = condition.stringParam, let minProg = condition.intParam {
                    if let clock = gameState.activeClocks.first(where: { $0.name == cName }) { //
                        var metMin = clock.progress >= minProg
                        if let maxProg = condition.intParamMax { // Optional max check
                            metMin = metMin && clock.progress <= maxProg
                        }
                        conditionMet = metMin
                    }
                }
            }
            if !conditionMet { return false } // All conditions must be met
        }
        return true
    }
    ```
    *(Note: `RollPosition` will need an `orderValue` and `isWorseThanOrEqualTo` similar to `RollEffect` for min/max checks: Desperate > Risky > Controlled).*

2.  **Refactor `GameViewModel.performAction()` processing logic:**
    * After determining `finalRollOutcome`, `isCritical`, `finalPosition`, `finalEffect`:
    * Get the base list of `Consequence` structs for the `finalRollOutcome` from `action.outcomes`.
    * Filter this list using `areConditionsMet()` to create a new list of *eligibleConsequences*.
    * **Apply Consequences based on Pools & Modulation:**
        * **Success Outcome:**
            * From *eligibleConsequences* that are positive:
                * Shallow pool: Apply defined consequence(s). `finalEffect` might increase potency/quantity if defined (e.g., an "amount" field in Consequence struct could be base, and `finalEffect` applies a multiplier or adds to it).
                * Deep pool: Draw N positive consequences based on `finalEffect`. `isCritical` could allow an extra draw or access to special crit-only gated consequences.
        * **Partial Success Outcome:**
            * Positive side: From *eligibleConsequences*, apply/draw based on `finalEffect`.
            * Negative side: From *eligibleConsequences*, apply/draw based on `finalPosition`.
        * **Failure Outcome:**
            * From *eligibleConsequences* that are negative: Apply/draw based on `finalPosition`.
    * The `processConsequences` method will then take this *final, filtered, and selected* list of consequences to apply to the `gameState`.

```

### `Docs/S14_DynamicConsequencesAndRolls/5-UIPolishForProjectionsAndResults.md`

```

### Task 5: UI Polish for Projections and Results

**Goal:** Ensure the `DiceRollView` clearly communicates the new dynamics introduced by zero-rating rolls, criticals, and the final impact of Position/Effect on outcomes.

**Actions:**

1.  **Verify `CardGame/DiceRollView.swift` - `projection.notes`:**
    * Ensure notes for 0-rating rolls are clearly displayed.
    * Consider if other active gates (e.g., "carrying X, special outcome possible!") should be hinted at in projection notes if determinable beforehand (this can be complex).
2.  **Display Critical & Final Effect:**
    * When `result.isCritical` is true, display a "CRITICAL SUCCESS!" message.
    * Display the `result.finalEffect` achieved on the roll.
3.  **Accurate Consequence Display:**
    * The existing logic of displaying `result.consequences` (the string description) should naturally reflect the actually applied consequences. Double-check this description is accurately built by `processConsequences` from the final list.
```

### `Docs/S14_DynamicConsequencesAndRolls/2-ModelConditionalConsequences.md`

```

### Task 2: Model Conditional Consequences (Gating Logic)

**Goal:** Define the data structures in `Models.swift` that allow consequences to have prerequisites (conditions) for their application, based on game state, roll position/effect, or player inventory.

**Actions:**

1.  **Define `GameCondition` struct/enum in `CardGame/Models.swift`:**
    ```swift
    struct GameCondition: Codable {
        enum ConditionType: String, Codable {
            case requiresMinEffectLevel
            case requiresExactEffectLevel
            case requiresMinPositionLevel
            case requiresExactPositionLevel
            case characterHasTreasureId   // Param: treasureId (String)
            case partyHasTreasureWithTag  // Param: treasureTag (String)
            case clockProgress           // Params: clockName (String), minProgress (Int), maxProgress (Int, optional)
            // Future: characterHasHarm, characterClass, etc.
        }

        let type: ConditionType
        // Using a dictionary for flexible parameters, or add specific optional fields
        let stringParam: String?   // e.g., treasureId, clockName, tag
        let intParam: Int?         // e.g., clock minProgress
        let intParamMax: Int?      // e.g., clock maxProgress
        let effectParam: RollEffect? // For requiresMinEffectLevel, requiresExactEffectLevel
        let positionParam: RollPosition? // For requiresMinPositionLevel, requiresExactPositionLevel

        // Example Initializer (you'll need custom Codable conformance if params are too varied)
        init(type: ConditionType, stringParam: String? = nil, intParam: Int? = nil, intParamMax: Int? = nil, effectParam: RollEffect? = nil, positionParam: RollPosition? = nil) {
            self.type = type
            self.stringParam = stringParam
            self.intParam = intParam
            self.intParamMax = intParamMax
            self.effectParam = effectParam
            self.positionParam = positionParam
        }
    }
    ```

2.  **Refactor `Consequence` in `CardGame/Models.swift`:**
    * It's highly recommended to refactor `Consequence` from an `enum` with associated values to a `struct`. This makes it much easier to add common properties like `conditions`.
    ```swift
    struct Consequence: Codable {
        // Define the actual effect of the consequence
        enum ConsequenceKind: String, Codable {
            case gainStress, sufferHarm, tickClock, unlockConnection, removeInteractable, removeSelfInteractable, addInteractable, addInteractableHere, gainTreasure
        }
        let kind: ConsequenceKind
        // Parameters for the consequence itself
        let amount: Int?
        let level: HarmLevel?
        let familyId: String?
        let clockName: String?
        let fromNodeID: UUID?
        let toNodeID: UUID?
        let interactableId: String? // For removeInteractable
        let inNodeID: UUID? // For addInteractable
        let newInteractable: Interactable? // For addInteractable/addInteractableHere
        let treasureId: String? // For gainTreasure

        // Gating Conditions
        var conditions: [GameCondition]?

        // You will need custom init(from: Decoder) and encode(to: Encoder) to handle this structure,
        // similar to how you've done for other complex enums/structs.
        // It would map a "type" field in JSON to 'kind' and then decode relevant parameters.
    }
    ```
    *If refactoring `Consequence` now is too large a step, you'll need a more complex way to associate conditions with enum cases during JSON parsing and processing, which can be error-prone.*

3.  **Update `CardGame/ContentLoader.swift`:**
    * Modify JSON parsing logic to correctly decode `Consequence` structs including their optional `conditions` arrays and parameters. This will involve careful handling in your `JSONDecoder` setup, potentially for `ActionOption` and `Interactable` where consequences are defined.
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

