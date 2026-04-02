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
    weak var scene: SCNScene?
    private var awaitingResults = false
    var pushedDiceCount: Int = 0
    /// Ensures we don't return a result until the dice have actually moved.
    private var hasStartedRolling = false
    private var rollStartTime: TimeInterval = 0
    private let winnerMarkerName = "tray-winner-marker"

    /// Dynamic tray dimensions in world-space units.
    var trayInnerWidth: Float = 8.0
    var trayInnerDepth: Float = 8.0
    var trayPlayableHalfWidth: Float = 3.8
    var trayPlayableHalfDepth: Float = 3.8
    /// Runtime containment radius derived from the actual die model scale.
    var dieContainmentRadius: Float = 0.6
    private var manuallySettledIndices: Set<Int> = []
    private var lowEnergyStartTimes: [Int: TimeInterval] = [:]
    private var cornerBumpCounts: [Int: Int] = [:]
    private var lastCornerBumpTimes: [Int: TimeInterval] = [:]
    private let lowEnergyHoldDuration: TimeInterval = 0.28
    private let minimumManualSettleDelay: TimeInterval = 0.75
    private let linearSettleThreshold: Float = 0.085
    private let verticalSettleThreshold: Float = 0.05
    private let angularSettleThreshold: Float = 0.24
    private let floorSettleSlack: Float = 0.18
    private let wallSettleSlack: Float = 0.14
    private let cornerBumpCooldown: TimeInterval = 0.18
    private let cornerBumpLinearThreshold: Float = 0.22
    private let cornerBumpVerticalThreshold: Float = 0.16
    private let cornerBumpAngularThreshold: Float = 0.75
    private let cornerBumpImpulse: Float = 0.14
    private let cornerBumpLift: Float = 0.05
    private let maxCornerBumps = 2

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

    private func resetTrackedSettleState() {
        manuallySettledIndices.removeAll()
        lowEnergyStartTimes.removeAll()
        cornerBumpCounts.removeAll()
        lastCornerBumpTimes.removeAll()
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
        resetTrackedSettleState()
        highlightDice(at: [], fadeOthers: false, isCritical: false)

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

    func highlightDice(at indices: [Int], fadeOthers: Bool, isCritical: Bool) {
        let validIndices = indices.filter { dice.indices.contains($0) }

        guard !validIndices.isEmpty else {
            for die in dice {
                die.setHighlighted(false, critical: false)
                die.setOpacity(1.0)
            }
            updateWinnerMarkers(for: [], isCritical: false)
            return
        }

        let highlighted = Set(validIndices)
        for (i, die) in dice.enumerated() {
            let isSelected = highlighted.contains(i)
            die.setHighlighted(isSelected, critical: isCritical && isSelected)
            die.setOpacity(isSelected ? 1.0 : (fadeOthers ? 0.22 : 0.8))
        }

        updateWinnerMarkers(for: validIndices, isCritical: isCritical)
    }

    private func updateWinnerMarkers(for indices: [Int], isCritical: Bool) {
        scene?.rootNode.childNodes
            .filter { $0.name == winnerMarkerName }
            .forEach { $0.removeFromParentNode() }

        guard let scene else { return }

        let validIndices = indices.filter { dice.indices.contains($0) }
        guard !validIndices.isEmpty else { return }

        let markerColor = isCritical
            ? UIColor(red: 1.0, green: 0.90, blue: 0.58, alpha: 1)
            : UIColor(red: 1.0, green: 0.84, blue: 0.44, alpha: 1)

        let positions = validIndices.map { index -> SCNVector3 in
            let die = dice[index]
            let position = die.node.presentation.position
            let ringRadius = CGFloat(max(die.containmentRadius * (isCritical ? 0.78 : 0.72), 0.34))
            let pipeRadius = CGFloat(max(die.containmentRadius * 0.08, 0.035))

            let ring = SCNTorus(ringRadius: ringRadius, pipeRadius: pipeRadius)
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = UIColor.clear
            material.emission.contents = markerColor
            material.transparent.contents = UIColor.white
            ring.materials = [material]

            let markerNode = SCNNode(geometry: ring)
            markerNode.name = winnerMarkerName
            markerNode.position = SCNVector3(position.x, 0.03, position.z)
            markerNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            markerNode.opacity = 0.0
            markerNode.scale = SCNVector3(isCritical ? 0.78 : 0.82, isCritical ? 0.78 : 0.82, isCritical ? 0.78 : 0.82)
            scene.rootNode.addChildNode(markerNode)

            let fadeIn = SCNAction.fadeOpacity(to: isCritical ? 1.0 : 0.95, duration: 0.12)
            fadeIn.timingMode = .easeInEaseOut
            let scaleUp = SCNAction.scale(to: 1.0, duration: 0.18)
            scaleUp.timingMode = .easeInEaseOut
            markerNode.runAction(.group([fadeIn, scaleUp]))

            return position
        }

        guard isCritical, positions.count > 1 else { return }

        for index in 0..<(positions.count - 1) {
            let start = positions[index]
            let end = positions[index + 1]
            let dx = end.x - start.x
            let dz = end.z - start.z
            let distance = sqrt(dx * dx + dz * dz)
            guard distance > 0.01 else { continue }

            let link = SCNBox(
                width: CGFloat(distance),
                height: 0.02,
                length: 0.06,
                chamferRadius: 0.02
            )
            let linkMaterial = SCNMaterial()
            linkMaterial.lightingModel = .constant
            linkMaterial.diffuse.contents = UIColor.clear
            linkMaterial.emission.contents = markerColor
            link.materials = [linkMaterial]

            let linkNode = SCNNode(geometry: link)
            linkNode.name = winnerMarkerName
            linkNode.position = SCNVector3((start.x + end.x) / 2, 0.03, (start.z + end.z) / 2)
            linkNode.eulerAngles = SCNVector3(0, -atan2(dz, dx), 0)
            linkNode.opacity = 0.0
            scene.rootNode.addChildNode(linkNode)

            let shimmerIn = SCNAction.fadeOpacity(to: 0.72, duration: 0.16)
            shimmerIn.timingMode = .easeInEaseOut
            let shimmerOut = SCNAction.fadeOpacity(to: 0.48, duration: 0.28)
            shimmerOut.timingMode = .easeInEaseOut
            linkNode.runAction(.sequence([shimmerIn, shimmerOut]))
        }
    }

    private func linearSpeed(of velocity: SCNVector3) -> Float {
        sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y) + (velocity.z * velocity.z))
    }

    private func isNearContainmentWall(_ position: SCNVector3, for die: DieNode) -> Bool {
        let maxX = max(trayPlayableHalfWidth - die.containmentRadius, 0.35)
        let maxZ = max(trayPlayableHalfDepth - die.containmentRadius, 0.35)

        return abs(position.x) >= maxX - wallSettleSlack
            || abs(position.z) >= maxZ - wallSettleSlack
    }

    private func isLowEnergyCandidate(_ die: DieNode, body: SCNPhysicsBody) -> Bool {
        let position = die.node.presentation.position
        let velocity = body.velocity
        let angularVelocity = body.angularVelocity
        let nearFloor = position.y <= max(die.containmentRadius + floorSettleSlack, 0.52)

        return nearFloor
            && isNearContainmentWall(position, for: die)
            && linearSpeed(of: velocity) <= linearSettleThreshold
            && abs(velocity.y) <= verticalSettleThreshold
            && abs(angularVelocity.w) <= angularSettleThreshold
    }

    private func cornerBumpVector(for position: SCNVector3, die: DieNode) -> SCNVector3? {
        let maxX = max(trayPlayableHalfWidth - die.containmentRadius, 0.35)
        let maxZ = max(trayPlayableHalfDepth - die.containmentRadius, 0.35)

        let nearPositiveX = position.x >= maxX - wallSettleSlack
        let nearNegativeX = position.x <= -maxX + wallSettleSlack
        let nearPositiveZ = position.z >= maxZ - wallSettleSlack
        let nearNegativeZ = position.z <= -maxZ + wallSettleSlack

        guard (nearPositiveX || nearNegativeX) && (nearPositiveZ || nearNegativeZ) else {
            return nil
        }

        let x = nearPositiveX ? -cornerBumpImpulse : cornerBumpImpulse
        let z = nearPositiveZ ? -cornerBumpImpulse : cornerBumpImpulse
        return SCNVector3(x, cornerBumpLift, z)
    }

    private func applyCornerBumpIfNeeded(_ die: DieNode, body: SCNPhysicsBody, index: Int, now: TimeInterval) -> Bool {
        let position = die.node.presentation.position
        let velocity = body.velocity
        let angularVelocity = body.angularVelocity
        let nearFloor = position.y <= max(die.containmentRadius + floorSettleSlack + 0.06, 0.58)

        guard nearFloor,
              let bump = cornerBumpVector(for: position, die: die),
              linearSpeed(of: velocity) <= cornerBumpLinearThreshold,
              abs(velocity.y) <= cornerBumpVerticalThreshold,
              abs(angularVelocity.w) <= cornerBumpAngularThreshold else {
            return false
        }

        let bumpCount = cornerBumpCounts[index] ?? 0
        if bumpCount >= maxCornerBumps {
            forceSettle(die, at: index)
            lowEnergyStartTimes.removeValue(forKey: index)
            lastCornerBumpTimes.removeValue(forKey: index)
            return true
        }

        let lastBumpTime = lastCornerBumpTimes[index] ?? 0
        guard now - lastBumpTime >= cornerBumpCooldown else { return false }

        die.node.position = position
        body.clearAllForces()
        body.resetTransform()

        var nudgedVelocity = body.velocity
        nudgedVelocity.x = bump.x
        nudgedVelocity.y = max(nudgedVelocity.y, bump.y)
        nudgedVelocity.z = bump.z
        body.velocity = nudgedVelocity
        body.angularVelocity.w *= 0.65

        cornerBumpCounts[index] = bumpCount + 1
        lastCornerBumpTimes[index] = now
        lowEnergyStartTimes[index] = now

        #if DEBUG
        if debugInstrumentation {
            print("[DiceDebug][roll \(debugRollID)] cornerBump die=\(index) vel=(\(String(format: "%.3f", nudgedVelocity.x)), \(String(format: "%.3f", nudgedVelocity.y)), \(String(format: "%.3f", nudgedVelocity.z)))")
        }
        #endif

        return true
    }

    private func forceSettle(_ die: DieNode, at index: Int) {
        guard let body = die.node.physicsBody else { return }

        die.node.transform = die.node.presentation.transform
        body.clearAllForces()
        body.resetTransform()
        body.velocity = SCNVector3Zero
        body.angularVelocity = SCNVector4Zero
        manuallySettledIndices.insert(index)

        #if DEBUG
        if debugInstrumentation {
            let pos = die.node.presentation.position
            print("[DiceDebug][roll \(debugRollID)] forcedSettle die=\(index) pos=(\(String(format: "%.3f", pos.x)), \(String(format: "%.3f", pos.y)), \(String(format: "%.3f", pos.z)))")
        }
        #endif
    }

    private func stabilizeLowEnergyDice() {
        let now = CACurrentMediaTime()
        guard now - rollStartTime >= minimumManualSettleDelay else { return }

        for (index, die) in dice.enumerated() {
            guard !manuallySettledIndices.contains(index),
                  let body = die.node.physicsBody else {
                lowEnergyStartTimes.removeValue(forKey: index)
                continue
            }

            guard !body.isResting else {
                lowEnergyStartTimes.removeValue(forKey: index)
                continue
            }

            if applyCornerBumpIfNeeded(die, body: body, index: index, now: now) {
                continue
            }

            guard isLowEnergyCandidate(die, body: body) else {
                lowEnergyStartTimes.removeValue(forKey: index)
                continue
            }

            let holdStart = lowEnergyStartTimes[index] ?? now
            lowEnergyStartTimes[index] = holdStart

            if now - holdStart >= lowEnergyHoldDuration {
                forceSettle(die, at: index)
                lowEnergyStartTimes.removeValue(forKey: index)
            }
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

        stabilizeLowEnergyDice()

        let allResting = dice.enumerated().allSatisfy { index, die in
            manuallySettledIndices.contains(index) || (die.node.physicsBody?.isResting ?? false)
        }
        if allResting {
            awaitingResults = false
            for die in dice {
                die.updateValueFromOrientation()
            }
            let values = dice.map { $0.value }
            resetTrackedSettleState()
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
        for (index, die) in dice.enumerated() {
            guard let body = die.node.physicsBody else { continue }
            let maxX = max(trayPlayableHalfWidth - die.containmentRadius, 0.35)
            let maxZ = max(trayPlayableHalfDepth - die.containmentRadius, 0.35)
            var position = die.node.presentation.position
            var velocity = body.velocity
            var angularVelocity = body.angularVelocity
            var clamped = false
            let overflowX = max(abs(position.x) - maxX, 0)
            let overflowZ = max(abs(position.z) - maxZ, 0)
            let minimumSafeY = max(die.containmentRadius + 0.08, 0.42)

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
                clamped = true
            } else if position.x > maxX {
                position.x = maxX
                clamped = true
            }

            if position.z < -maxZ {
                position.z = -maxZ
                clamped = true
            } else if position.z > maxZ {
                position.z = maxZ
                clamped = true
            }

            if clamped {
                position.y = max(position.y, minimumSafeY)
                velocity.x = 0
                velocity.z = 0
                velocity.y = max(min(velocity.y, 0.25), -0.15)
                angularVelocity.w *= 0.45
                die.node.position = position
                body.clearAllForces()
                body.resetTransform()
                body.velocity = velocity
                body.angularVelocity = angularVelocity

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
    private let containmentWallHeight: Float = 4.6
    private let containmentWallThickness: Float = 0.18
    private let containmentWallInset: Float = 0.04

    private func clamp(_ value: Float, min minValue: Float, max maxValue: Float) -> Float {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    private func playableHalfExtent(for innerExtent: Float) -> Float {
        max(innerExtent * 0.5 - wallThickness * 0.5 - containmentWallThickness - containmentWallInset, 1.2)
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
        controller.scene = scene
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
        controller.scene = scene

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
            controller.trayPlayableHalfWidth = playableHalfExtent(for: innerWidth)
            controller.trayPlayableHalfDepth = playableHalfExtent(for: innerDepth)
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

        addContainmentWalls(to: root, innerWidth: innerWidth, innerDepth: innerDepth)

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
            let original = die.node.position
            var pos = die.node.position
            pos.x = clamp(pos.x, min: -maxX, max: maxX)
            pos.z = clamp(pos.z, min: -maxZ, max: maxZ)
            pos.y = Swift.max(pos.y, 0.6)

            guard abs(pos.x - original.x) > 0.001
                || abs(pos.y - original.y) > 0.001
                || abs(pos.z - original.z) > 0.001 else {
                continue
            }

            die.node.position = pos
            die.node.physicsBody?.resetTransform()
        }
    }

    private func addContainmentWalls(to root: SCNNode, innerWidth: Float, innerDepth: Float) {
        let wallMaterial = makeContainmentMaterial()
        let containmentY = containmentWallHeight * 0.5 - 0.21
        let containmentHalfWidth = controller.trayPlayableHalfWidth + containmentWallThickness * 0.5
        let containmentHalfDepth = controller.trayPlayableHalfDepth + containmentWallThickness * 0.5

        let frontBackContainmentGeometry = SCNBox(
            width: CGFloat(innerWidth),
            height: CGFloat(containmentWallHeight),
            length: CGFloat(containmentWallThickness),
            chamferRadius: 0.01
        )
        frontBackContainmentGeometry.materials = Array(repeating: wallMaterial, count: 6)

        let backContainment = SCNNode(geometry: frontBackContainmentGeometry)
        backContainment.position = SCNVector3(0, containmentY, -containmentHalfDepth)
        backContainment.physicsBody = SCNPhysicsBody.static()
        backContainment.opacity = 0.0
        backContainment.castsShadow = false
        root.addChildNode(backContainment)

        let frontContainment = SCNNode(geometry: frontBackContainmentGeometry)
        frontContainment.position = SCNVector3(0, containmentY, containmentHalfDepth)
        frontContainment.physicsBody = SCNPhysicsBody.static()
        frontContainment.opacity = 0.0
        frontContainment.castsShadow = false
        root.addChildNode(frontContainment)

        let leftRightContainmentGeometry = SCNBox(
            width: CGFloat(containmentWallThickness),
            height: CGFloat(containmentWallHeight),
            length: CGFloat(innerDepth),
            chamferRadius: 0.01
        )
        leftRightContainmentGeometry.materials = Array(repeating: wallMaterial, count: 6)

        let leftContainment = SCNNode(geometry: leftRightContainmentGeometry)
        leftContainment.position = SCNVector3(-containmentHalfWidth, containmentY, 0)
        leftContainment.physicsBody = SCNPhysicsBody.static()
        leftContainment.opacity = 0.0
        leftContainment.castsShadow = false
        root.addChildNode(leftContainment)

        let rightContainment = SCNNode(geometry: leftRightContainmentGeometry)
        rightContainment.position = SCNVector3(containmentHalfWidth, containmentY, 0)
        rightContainment.physicsBody = SCNPhysicsBody.static()
        rightContainment.opacity = 0.0
        rightContainment.castsShadow = false
        root.addChildNode(rightContainment)
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

    private func makeContainmentMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = UIColor.clear
        material.emission.contents = UIColor.clear
        material.transparency = 0.0
        material.writesToDepthBuffer = false
        material.colorBufferWriteMask = []
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
