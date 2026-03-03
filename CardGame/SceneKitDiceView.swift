import SwiftUI
import SceneKit
import UIKit

private final class LayoutAwareSCNView: SCNView {
    var onLayoutChange: ((LayoutAwareSCNView) -> Void)?
    private var lastNotifiedSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        notifyLayoutChange(force: bounds.size != lastNotifiedSize)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.notifyLayoutChange(force: true)
        }
    }

    private func notifyLayoutChange(force: Bool) {
        guard force || bounds.size != lastNotifiedSize else { return }
        lastNotifiedSize = bounds.size
        onLayoutChange?(self)
    }
}

class SceneKitDiceController: NSObject, ObservableObject, SCNSceneRendererDelegate {
    fileprivate var dice: [DieNode] = []
    var onDiceSettled: (([Int]) -> Void)? = nil
    @Published private(set) var isViewportReady = false
    private var awaitingResults = false
    var pushedDiceCount: Int = 0
    /// Ensures we don't return a result until the dice have actually moved.
    private var hasStartedRolling = false
    private var rollStartTime: TimeInterval = 0

    /// Dynamic tray dimensions in world-space units.
    var trayInnerWidth: Float = 8.0
    var trayInnerDepth: Float = 8.0
    var trayPlayableHalfWidth: Float = 3.8
    var trayPlayableHalfDepth: Float = 3.8
    /// Runtime containment radius derived from the actual die model scale.
    var dieContainmentRadius: Float = 0.6

    #if DEBUG
    private let debugInstrumentation = true
    private var debugRollID: Int = 0
    private var debugOutOfBoundsEventCount: Int = 0
    private var debugMaxAbsX: Float = 0
    private var debugMaxAbsZ: Float = 0
    private var debugMaxY: Float = 0
    private var debugMaxOverflowX: Float = 0
    private var debugMaxOverflowZ: Float = 0
    private var debugPrintedStuckSnapshot = false
    #endif

    private func clamp(_ value: Float, min minValue: Float, max maxValue: Float) -> Float {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    func setViewportReady(_ ready: Bool) {
        guard isViewportReady != ready else { return }
        isViewportReady = ready
    }

    #if DEBUG
    private func resetDebugRollStats() {
        debugOutOfBoundsEventCount = 0
        debugMaxAbsX = 0
        debugMaxAbsZ = 0
        debugMaxY = 0
        debugMaxOverflowX = 0
        debugMaxOverflowZ = 0
        debugPrintedStuckSnapshot = false
    }
    #endif

    func rollDice() {
        guard !dice.isEmpty else { return }

        awaitingResults = true
        hasStartedRolling = false
        rollStartTime = CACurrentMediaTime()
        highlightDie(at: nil, fadeOthers: false)

        let maxX = Swift.max(trayPlayableHalfWidth - dieContainmentRadius - 0.18, 0.40)
        let maxZ = Swift.max(trayPlayableHalfDepth - dieContainmentRadius - 0.18, 0.40)
        let spreadScale = Swift.min(0.55, maxX / Swift.max(Float(dice.count), 1.0))

        #if DEBUG
        if debugInstrumentation {
            debugRollID += 1
            resetDebugRollStats()
            print("[DiceDebug][roll \(debugRollID)] begin dice=\(dice.count) containR=\(String(format: "%.3f", dieContainmentRadius)) maxX=\(String(format: "%.3f", maxX)) maxZ=\(String(format: "%.3f", maxZ)) playableHalf=(\(String(format: "%.3f", trayPlayableHalfWidth)), \(String(format: "%.3f", trayPlayableHalfDepth))) trayInner=(\(String(format: "%.3f", trayInnerWidth)), \(String(format: "%.3f", trayInnerDepth)))")
        }
        #endif

        for (index, die) in dice.enumerated() {
            let spread = Float(index) - Float(dice.count - 1) / 2
            let rawX = spread * spreadScale + Float.random(in: -0.18...0.18)
            let rawZ = Float.random(in: -(maxZ * 0.30)...(maxZ * 0.30))

            let pos = SCNVector3(
                clamp(rawX, min: -maxX, max: maxX),
                1.05 + Float.random(in: 0.0...0.22),
                clamp(rawZ, min: -maxZ, max: maxZ)
            )
            die.prepareForRoll(at: pos)

            let force = SCNVector3(
                Float.random(in: -1.9...1.9),
                Float.random(in: 0.52...0.96),
                Float.random(in: -1.9...1.9)
            )
            die.node.physicsBody?.applyForce(force, asImpulse: true)

            let torque = SCNVector4(
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -1...1),
                Float.random(in: -4.0...4.0)
            )
            die.node.physicsBody?.applyTorque(torque, asImpulse: true)
        }
    }

    func highlightDie(at index: Int?, fadeOthers: Bool) {
        guard let index else {
            for die in dice {
                die.setHighlighted(false)
                die.setOpacity(1.0)
            }
            return
        }

        for (i, die) in dice.enumerated() {
            let isSelected = i == index
            die.setHighlighted(isSelected)
            die.setOpacity(isSelected ? 1.0 : (fadeOthers ? 0.14 : 0.8))
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard awaitingResults else { return }

        enforceContainmentBounds()

        #if DEBUG
        if debugInstrumentation, hasStartedRolling, !debugPrintedStuckSnapshot {
            let elapsed = CACurrentMediaTime() - rollStartTime
            if elapsed > 5.0 {
                debugPrintedStuckSnapshot = true
                let elapsedText = String(format: "%.2f", elapsed)
                print("[DiceDebug][roll \(debugRollID)] stuck elapsed=\(elapsedText)s")
                for (idx, die) in dice.enumerated() {
                    let pos = die.node.presentation.position
                    let body = die.node.physicsBody
                    let vel = body?.velocity ?? SCNVector3Zero
                    let isResting = body?.isResting ?? false
                    let px = String(format: "%.3f", pos.x)
                    let py = String(format: "%.3f", pos.y)
                    let pz = String(format: "%.3f", pos.z)
                    let vx = String(format: "%.3f", vel.x)
                    let vy = String(format: "%.3f", vel.y)
                    let vz = String(format: "%.3f", vel.z)
                    print("[DiceDebug][roll \(debugRollID)] die=\(idx) resting=\(isResting) pos=(\(px), \(py), \(pz)) vel=(\(vx), \(vy), \(vz))")
                }
            }
        }
        #endif

        if !hasStartedRolling {
            let anyMoving = dice.contains { !($0.node.physicsBody?.isResting ?? true) }
            if anyMoving {
                hasStartedRolling = true
            }
            return
        }

        let allResting = dice.allSatisfy { $0.node.physicsBody?.isResting ?? false }
        if allResting {
            awaitingResults = false
            for die in dice {
                die.updateValueFromOrientation()
            }
            let values = dice.map { $0.value }
            #if DEBUG
            if debugInstrumentation {
                print("[DiceDebug][roll \(debugRollID)] settle values=\(values) maxAbs=(x:\(String(format: "%.3f", debugMaxAbsX)), z:\(String(format: "%.3f", debugMaxAbsZ))) maxY=\(String(format: "%.3f", debugMaxY)) maxOverflow=(x:\(String(format: "%.3f", debugMaxOverflowX)), z:\(String(format: "%.3f", debugMaxOverflowZ))) oobEvents=\(debugOutOfBoundsEventCount)")
            }
            #endif
            DispatchQueue.main.async {
                self.onDiceSettled?(values)
            }
        }
    }

    /// Safety clamp so dice can never escape the visible tray bounds even on high bounces.
    private func enforceContainmentBounds() {
        let maxX = max(trayPlayableHalfWidth - dieContainmentRadius, 0.35)
        let maxZ = max(trayPlayableHalfDepth - dieContainmentRadius, 0.35)

        for (index, die) in dice.enumerated() {
            guard let body = die.node.physicsBody else { continue }
            var position = die.node.position
            var velocity = body.velocity
            var clamped = false
            let overflowX = max(abs(position.x) - maxX, 0)
            let overflowZ = max(abs(position.z) - maxZ, 0)

            #if DEBUG
            if debugInstrumentation {
                debugMaxAbsX = max(debugMaxAbsX, abs(position.x))
                debugMaxAbsZ = max(debugMaxAbsZ, abs(position.z))
                debugMaxY = max(debugMaxY, position.y)
                debugMaxOverflowX = max(debugMaxOverflowX, overflowX)
                debugMaxOverflowZ = max(debugMaxOverflowZ, overflowZ)
            }
            #endif

            if position.x < -maxX {
                position.x = -maxX
                velocity.x = abs(velocity.x) * 0.35
                clamped = true
            } else if position.x > maxX {
                position.x = maxX
                velocity.x = -abs(velocity.x) * 0.35
                clamped = true
            }

            if position.z < -maxZ {
                position.z = -maxZ
                velocity.z = abs(velocity.z) * 0.35
                clamped = true
            } else if position.z > maxZ {
                position.z = maxZ
                velocity.z = -abs(velocity.z) * 0.35
                clamped = true
            }

            if clamped {
                position.y = max(position.y, 0.42)
                die.node.position = position
                body.velocity = velocity

                #if DEBUG
                if debugInstrumentation {
                    debugOutOfBoundsEventCount += 1
                    if debugOutOfBoundsEventCount <= 20 {
                        print("[DiceDebug][roll \(debugRollID)] OOB die=\(index) preOverflow=(x:\(String(format: "%.3f", overflowX)), z:\(String(format: "%.3f", overflowZ))) correctedPos=(\(String(format: "%.3f", position.x)), \(String(format: "%.3f", position.y)), \(String(format: "%.3f", position.z))) vel=(\(String(format: "%.3f", velocity.x)), \(String(format: "%.3f", velocity.y)), \(String(format: "%.3f", velocity.z))) bounds=(±\(String(format: "%.3f", maxX)), ±\(String(format: "%.3f", maxZ)))")
                    }
                }
                #endif
            }
        }
    }
}

struct SceneKitDiceView: UIViewRepresentable {
    final class Coordinator {
        var desiredDiceCount: Int = 0
        var desiredPushedDice: Int = 0
    }

    @ObservedObject var controller: SceneKitDiceController
    let diceCount: Int
    let pushedDice: Int

    private let visibleHeight: Float = 8.2
    private let edgeInset: Float = 0.34
    private let wallHeight: Float = 2.25
    private let wallThickness: Float = 0.34

    private func clamp(_ value: Float, min minValue: Float, max maxValue: Float) -> Float {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func hasValidBounds(_ scnView: SCNView) -> Bool {
        scnView.bounds.width > 1 && scnView.bounds.height > 1
    }

    private func syncDice(in scene: SCNScene, desiredDiceCount: Int, desiredPushedDice: Int) {
        controller.pushedDiceCount = desiredPushedDice

        if controller.dice.count < desiredDiceCount {
            spawnDice(count: desiredDiceCount - controller.dice.count,
                      pushedDice: desiredPushedDice,
                      in: scene,
                      append: true,
                      startingIndex: controller.dice.count,
                      totalDice: desiredDiceCount)
        } else if controller.dice.count > desiredDiceCount {
            while controller.dice.count > desiredDiceCount {
                let die = controller.dice.removeLast()
                die.node.removeFromParentNode()
            }
        }

        controller.dieContainmentRadius = controller.dice.map(\.containmentRadius).max() ?? 0.6
        clampDiceIntoVisibleBounds()

        for (i, die) in controller.dice.enumerated() {
            let shouldBePushed = i >= desiredDiceCount - desiredPushedDice
            if die.isPushed != shouldBePushed {
                die.markPushed(shouldBePushed)
            }
        }
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = LayoutAwareSCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.delegate = controller

        scnView.backgroundColor = UIColor(red: 0.10, green: 0.09, blue: 0.08, alpha: 1)
        scnView.antialiasingMode = .multisampling4X
        scnView.rendersContinuously = true
        scnView.isPlaying = true
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false

        scene.physicsWorld.gravity = SCNVector3(0, -10.0, 0)

        configureCamera(in: scene, on: scnView)
        configureLights(in: scene)
        applyViewportLayout(to: scnView, force: true)

        context.coordinator.desiredDiceCount = diceCount
        context.coordinator.desiredPushedDice = pushedDice

        scnView.onLayoutChange = { view in
            self.applyViewportLayout(to: view, force: false)
            guard let activeScene = view.scene, self.hasValidBounds(view) else { return }
            self.syncDice(in: activeScene,
                          desiredDiceCount: context.coordinator.desiredDiceCount,
                          desiredPushedDice: context.coordinator.desiredPushedDice)
        }

        controller.dice.removeAll()
        controller.dieContainmentRadius = 0.6
        controller.setViewportReady(false)

        if hasValidBounds(scnView) {
            syncDice(in: scene,
                     desiredDiceCount: context.coordinator.desiredDiceCount,
                     desiredPushedDice: context.coordinator.desiredPushedDice)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }

        context.coordinator.desiredDiceCount = diceCount
        context.coordinator.desiredPushedDice = pushedDice

        configureCamera(in: scene, on: uiView)
        applyViewportLayout(to: uiView, force: false)

        if hasValidBounds(uiView) {
            syncDice(in: scene,
                     desiredDiceCount: context.coordinator.desiredDiceCount,
                     desiredPushedDice: context.coordinator.desiredPushedDice)
        }
    }

    private func configureCamera(in scene: SCNScene, on scnView: SCNView) {
        let cameraNode: SCNNode
        if let existing = scene.rootNode.childNode(withName: "tray-camera", recursively: false) {
            cameraNode = existing
        } else {
            cameraNode = SCNNode()
            cameraNode.name = "tray-camera"
            scene.rootNode.addChildNode(cameraNode)
        }

        let camera = cameraNode.camera ?? SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = Double(visibleHeight / 2)
        camera.wantsHDR = true
        camera.wantsExposureAdaptation = true
        camera.bloomIntensity = 0.07
        camera.bloomThreshold = 0.58
        camera.bloomBlurRadius = 2.5
        camera.zNear = 0.1
        camera.zFar = 60

        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 8.8, 0)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)

        scnView.pointOfView = cameraNode
    }

    private func configureLights(in scene: SCNScene) {
        if scene.rootNode.childNode(withName: "tray-ambient", recursively: false) == nil {
            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.color = UIColor(red: 0.34, green: 0.30, blue: 0.24, alpha: 1)
            ambient.intensity = 190
            let ambientNode = SCNNode()
            ambientNode.name = "tray-ambient"
            ambientNode.light = ambient
            scene.rootNode.addChildNode(ambientNode)
        }

        if scene.rootNode.childNode(withName: "tray-key", recursively: false) == nil {
            let key = SCNLight()
            key.type = .spot
            key.castsShadow = true
            key.shadowRadius = 5.2
            key.shadowColor = UIColor.black.withAlphaComponent(0.36)
            key.intensity = 1480
            key.color = UIColor(red: 0.99, green: 0.90, blue: 0.74, alpha: 1)
            key.spotInnerAngle = 42
            key.spotOuterAngle = 88

            let keyNode = SCNNode()
            keyNode.name = "tray-key"
            keyNode.light = key
            keyNode.position = SCNVector3(0.35, 10.2, 0.35)
            keyNode.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(keyNode)
        }

        if scene.rootNode.childNode(withName: "tray-fill", recursively: false) == nil {
            let fill = SCNLight()
            fill.type = .directional
            fill.intensity = 200
            fill.color = UIColor(red: 0.40, green: 0.36, blue: 0.30, alpha: 1)

            let fillNode = SCNNode()
            fillNode.name = "tray-fill"
            fillNode.light = fill
            fillNode.position = SCNVector3(-0.25, 8.2, -0.25)
            fillNode.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(fillNode)
        }
    }

    private func applyViewportLayout(to scnView: SCNView, force: Bool) {
        guard let scene = scnView.scene else { return }
        let size = scnView.bounds.size
        guard size.width > 1, size.height > 1 else {
            controller.setViewportReady(false)
            #if DEBUG
            print("[DiceDebug][layout] skipped invalidSize=\(Int(size.width))x\(Int(size.height))")
            #endif
            return
        }

        let aspect = Float(size.width / size.height)
        let visibleWidth = visibleHeight * aspect

        let innerWidth = Swift.max(visibleWidth - edgeInset * 2, 3.8)
        let innerDepth = Swift.max(visibleHeight - edgeInset * 2, 3.8)

        let widthChanged = abs(controller.trayInnerWidth - innerWidth) > 0.01
        let depthChanged = abs(controller.trayInnerDepth - innerDepth) > 0.01
        let trayMissing = scene.rootNode.childNode(withName: "tray-root", recursively: false) == nil

        if force || widthChanged || depthChanged || trayMissing {
            controller.trayInnerWidth = innerWidth
            controller.trayInnerDepth = innerDepth
            controller.trayPlayableHalfWidth = innerWidth * 0.5 - wallThickness * 0.5
            controller.trayPlayableHalfDepth = innerDepth * 0.5 - wallThickness * 0.5
            buildTray(in: scene, innerWidth: innerWidth, innerDepth: innerDepth)
            clampDiceIntoVisibleBounds()

            #if DEBUG
            print("[DiceDebug][layout] view=\(Int(size.width))x\(Int(size.height)) aspect=\(String(format: "%.3f", aspect)) visible=(w:\(String(format: "%.3f", visibleWidth)), h:\(String(format: "%.3f", visibleHeight))) inner=(w:\(String(format: "%.3f", innerWidth)), d:\(String(format: "%.3f", innerDepth))) playableHalf=(\(String(format: "%.3f", controller.trayPlayableHalfWidth)), \(String(format: "%.3f", controller.trayPlayableHalfDepth))) wallHalfThickness=\(String(format: "%.3f", wallThickness * 0.5))")
            #endif
        }

        controller.setViewportReady(true)
    }

    private func buildTray(in scene: SCNScene, innerWidth: Float, innerDepth: Float) {
        scene.rootNode.childNodes
            .filter { $0.name == "tray-root" }
            .forEach { $0.removeFromParentNode() }

        let root = SCNNode()
        root.name = "tray-root"

        let outerWidth = innerWidth + 0.92
        let outerDepth = innerDepth + 0.92

        let frameGeometry = SCNBox(
            width: CGFloat(outerWidth),
            height: 0.56,
            length: CGFloat(outerDepth),
            chamferRadius: 0.24
        )
        frameGeometry.materials = Array(repeating: makeFrameMaterial(), count: 6)
        let frameNode = SCNNode(geometry: frameGeometry)
        frameNode.position = SCNVector3(0, -0.42, 0)
        root.addChildNode(frameNode)

        let floorGeometry = SCNBox(
            width: CGFloat(innerWidth),
            height: 0.22,
            length: CGFloat(innerDepth),
            chamferRadius: 0.1
        )
        floorGeometry.materials = Array(repeating: makeFloorMaterial(), count: 6)
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, -0.20, 0)
        floorNode.physicsBody = SCNPhysicsBody.static()
        root.addChildNode(floorNode)

        let wallMaterial = makeWallMaterial()

        let frontBackWallGeometry = SCNBox(
            width: CGFloat(innerWidth),
            height: CGFloat(wallHeight),
            length: CGFloat(wallThickness),
            chamferRadius: 0.06
        )
        frontBackWallGeometry.materials = Array(repeating: wallMaterial, count: 6)

        let backWall = SCNNode(geometry: frontBackWallGeometry)
        backWall.position = SCNVector3(0, wallHeight / 2 - 0.21, -innerDepth / 2)
        backWall.physicsBody = SCNPhysicsBody.static()
        root.addChildNode(backWall)

        let frontWall = SCNNode(geometry: frontBackWallGeometry)
        frontWall.position = SCNVector3(0, wallHeight / 2 - 0.21, innerDepth / 2)
        frontWall.physicsBody = SCNPhysicsBody.static()
        root.addChildNode(frontWall)

        let leftRightWallGeometry = SCNBox(
            width: CGFloat(wallThickness),
            height: CGFloat(wallHeight),
            length: CGFloat(innerDepth),
            chamferRadius: 0.06
        )
        leftRightWallGeometry.materials = Array(repeating: wallMaterial, count: 6)

        let leftWall = SCNNode(geometry: leftRightWallGeometry)
        leftWall.position = SCNVector3(-innerWidth / 2, wallHeight / 2 - 0.21, 0)
        leftWall.physicsBody = SCNPhysicsBody.static()
        root.addChildNode(leftWall)

        let rightWall = SCNNode(geometry: leftRightWallGeometry)
        rightWall.position = SCNVector3(innerWidth / 2, wallHeight / 2 - 0.21, 0)
        rightWall.physicsBody = SCNPhysicsBody.static()
        root.addChildNode(rightWall)

        let lipMaterial = makeLipMaterial()
        let lipHeight: Float = 0.12
        let lipDepth: Float = 0.22

        let horizontalLip = SCNBox(
            width: CGFloat(innerWidth),
            height: CGFloat(lipHeight),
            length: CGFloat(lipDepth),
            chamferRadius: 0.03
        )
        horizontalLip.materials = Array(repeating: lipMaterial, count: 6)

        let topLip = SCNNode(geometry: horizontalLip)
        topLip.position = SCNVector3(0, 0.02, -innerDepth / 2 + lipDepth / 2)
        root.addChildNode(topLip)

        let bottomLip = SCNNode(geometry: horizontalLip)
        bottomLip.position = SCNVector3(0, 0.02, innerDepth / 2 - lipDepth / 2)
        root.addChildNode(bottomLip)

        let verticalLip = SCNBox(
            width: CGFloat(lipDepth),
            height: CGFloat(lipHeight),
            length: CGFloat(innerDepth - lipDepth * 2),
            chamferRadius: 0.03
        )
        verticalLip.materials = Array(repeating: lipMaterial, count: 6)

        let leftLip = SCNNode(geometry: verticalLip)
        leftLip.position = SCNVector3(-innerWidth / 2 + lipDepth / 2, 0.02, 0)
        root.addChildNode(leftLip)

        let rightLip = SCNNode(geometry: verticalLip)
        rightLip.position = SCNVector3(innerWidth / 2 - lipDepth / 2, 0.02, 0)
        root.addChildNode(rightLip)

        scene.rootNode.addChildNode(root)
    }

    private func spawnDice(count: Int,
                           pushedDice: Int,
                           in scene: SCNScene,
                           append: Bool,
                           startingIndex: Int = 0,
                           totalDice: Int? = nil) {
        let expectedTotal = totalDice ?? count
        for i in 0..<count {
            let index = startingIndex + i
            let die = DieNode()
            controller.dieContainmentRadius = max(controller.dieContainmentRadius, die.containmentRadius)
            if index >= expectedTotal - pushedDice {
                die.markPushed(true)
            }
            die.node.position = randomSpawnPosition()
            scene.rootNode.addChildNode(die.node)
            if append {
                controller.dice.append(die)
            }

            #if DEBUG
            print("[DiceDebug][spawn] die=\(index) containmentR=\(String(format: "%.3f", die.containmentRadius)) pos=(\(String(format: "%.3f", die.node.position.x)), \(String(format: "%.3f", die.node.position.y)), \(String(format: "%.3f", die.node.position.z)))")
            #endif
        }
    }

    private func randomSpawnPosition() -> SCNVector3 {
        let maxX = Swift.max(controller.trayPlayableHalfWidth - controller.dieContainmentRadius - 0.12, 0.35)
        let maxZ = Swift.max(controller.trayPlayableHalfDepth - controller.dieContainmentRadius - 0.12, 0.35)

        return SCNVector3(
            Float.random(in: -maxX...maxX),
            Float.random(in: 0.90...1.22),
            Float.random(in: -maxZ...maxZ)
        )
    }

    private func clampDiceIntoVisibleBounds() {
        let maxX = Swift.max(controller.trayPlayableHalfWidth - controller.dieContainmentRadius, 0.3)
        let maxZ = Swift.max(controller.trayPlayableHalfDepth - controller.dieContainmentRadius, 0.3)

        for die in controller.dice {
            var pos = die.node.position
            pos.x = clamp(pos.x, min: -maxX, max: maxX)
            pos.z = clamp(pos.z, min: -maxZ, max: maxZ)
            pos.y = Swift.max(pos.y, 0.6)
            die.node.position = pos
        }
    }

    private func makeFrameMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.19, green: 0.16, blue: 0.13, alpha: 1)
        material.roughness.contents = 0.75
        material.metalness.contents = 0.03
        material.specular.contents = UIColor(white: 0.35, alpha: 1)
        return material
    }

    private func makeWallMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1)
        material.roughness.contents = 0.88
        material.metalness.contents = 0.02
        return material
    }

    private func makeLipMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.21, green: 0.17, blue: 0.13, alpha: 1)
        material.roughness.contents = 0.62
        material.metalness.contents = 0.06
        return material
    }

    private func makeFloorMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        if let texture = UIImage(named: "texture_dicetray_surface") {
            material.diffuse.contents = texture
        } else {
            material.diffuse.contents = UIColor(red: 0.24, green: 0.20, blue: 0.15, alpha: 1)
        }
        material.roughness.contents = 0.95
        material.metalness.contents = 0.02
        material.specular.contents = UIColor(white: 0.15, alpha: 1)
        return material
    }
}
