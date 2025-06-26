import SwiftUI
import SceneKit

class SceneKitDiceController: NSObject, ObservableObject, SCNSceneRendererDelegate {
    fileprivate var dice: [DieNode] = []
    var onDiceSettled: (([Int]) -> Void)? = nil
    private var awaitingResults = false
    private var highlightedIndex: Int? = nil
    var pushedDiceCount: Int = 0
    /// Ensures we don't return a result until the dice have actually moved.
    private var hasStartedRolling = false

    func rollDice() {
        awaitingResults = true
        hasStartedRolling = false
        highlightDie(at: nil, fadeOthers: false)
        for (index, die) in dice.enumerated() {
            let spread = Float(index) - Float(dice.count - 1) / 2
            let pos = SCNVector3(spread * 1.2 + Float.random(in: -0.2...0.2), 1.0, Float.random(in: -0.2...0.2))
            die.prepareForRoll(at: pos)
            let force = SCNVector3(Float.random(in: -2...2), Float.random(in: 0.2...0.5), Float.random(in: -2...2))
            die.node.physicsBody?.applyForce(force, asImpulse: true)
            let torque = SCNVector4(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -3...3))
            die.node.physicsBody?.applyTorque(torque, asImpulse: true)
        }
    }

    func highlightDie(at index: Int?, fadeOthers: Bool) {
        highlightedIndex = index
        for (i, die) in dice.enumerated() {
            if let idx = index, i == idx {
                die.setOpacity(1.0)
            } else {
                die.setEmissiveColor(die.isPushed ? .orange : nil)
                die.setOpacity(fadeOthers && index != nil ? 0.5 : 1.0)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard awaitingResults else { return }

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
            DispatchQueue.main.async {
                self.onDiceSettled?(values)
            }
        }
    }
}

struct SceneKitDiceView: UIViewRepresentable {
    @ObservedObject var controller: SceneKitDiceController
    let diceCount: Int
    let pushedDice: Int
    private let traySize: Float = 10

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene
        scnView.delegate = controller

        // Camera looking straight down into the tray
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
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
        floor.firstMaterial?.diffuse.contents = nil // UIImage(named: "texture_dicetray_surface")
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
        frontBackWallGeometry.firstMaterial?.diffuse.contents = nil

        let backWall = SCNNode(geometry: frontBackWallGeometry)
        backWall.position = SCNVector3(0, wallHeight/2 - 0.1, -traySize/2)
        backWall.physicsBody = SCNPhysicsBody.static()
        backWall.isHidden = true
        scene.rootNode.addChildNode(backWall)

        let frontWall = SCNNode(geometry: frontBackWallGeometry)
        frontWall.position = SCNVector3(0, wallHeight/2 - 0.1, traySize/2)
        frontWall.physicsBody = SCNPhysicsBody.static()
        frontWall.isHidden = true
        scene.rootNode.addChildNode(frontWall)

        // Geometry for left/right walls
        let leftRightWallGeometry = SCNBox(
            width: CGFloat(wallThickness),
            height: CGFloat(wallHeight),
            length: CGFloat(traySize),
            chamferRadius: wallChamferRadius
        )
        leftRightWallGeometry.firstMaterial?.diffuse.contents = nil

        let leftWall = SCNNode(geometry: leftRightWallGeometry)
        leftWall.position = SCNVector3(-traySize/2, wallHeight/2 - 0.1, 0)
        leftWall.physicsBody = SCNPhysicsBody.static()
        leftWall.isHidden = true
        scene.rootNode.addChildNode(leftWall)

        let rightWall = SCNNode(geometry: leftRightWallGeometry)
        rightWall.position = SCNVector3(traySize/2, wallHeight/2 - 0.1, 0)
        rightWall.physicsBody = SCNPhysicsBody.static()
        rightWall.isHidden = true
        scene.rootNode.addChildNode(rightWall)

        scnView.isPlaying = true
        scnView.allowsCameraControl = false

        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)

        controller.pushedDiceCount = pushedDice

        // Add dice nodes
        for i in 0..<diceCount {
            let die = DieNode()
            if i >= diceCount - pushedDice {
                die.markPushed(true)
            }
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

        controller.pushedDiceCount = pushedDice

        if controller.dice.count < diceCount {
            for i in controller.dice.count..<diceCount {
                let die = DieNode()
                if i >= diceCount - pushedDice {
                    die.markPushed(true)
                }
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

        // Update pushed state for existing dice
        for (i, die) in controller.dice.enumerated() {
            let shouldBePushed = i >= diceCount - pushedDice
            if die.isPushed != shouldBePushed {
                die.markPushed(shouldBePushed)
            }
        }
    }
}

