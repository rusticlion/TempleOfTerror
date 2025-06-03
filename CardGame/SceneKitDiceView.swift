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
        let wallHeight: Float = 2
        let wallGeometry = SCNBox(width: CGFloat(traySize), height: CGFloat(wallHeight), length: CGFloat(wallThickness), chamferRadius: 0)
        wallGeometry.firstMaterial?.diffuse.contents = floor.firstMaterial?.diffuse.contents

        let backWall = SCNNode(geometry: wallGeometry)
        backWall.position = SCNVector3(0, wallHeight/2 - 0.1, -traySize/2)
        backWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(backWall)

        let frontWall = SCNNode(geometry: wallGeometry)
        frontWall.position = SCNVector3(0, wallHeight/2 - 0.1, traySize/2)
        frontWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(frontWall)

        let sideWallGeometry = SCNBox(width: CGFloat(wallThickness), height: CGFloat(wallHeight), length: CGFloat(traySize), chamferRadius: 0)
        sideWallGeometry.firstMaterial?.diffuse.contents = floor.firstMaterial?.diffuse.contents

        let leftWall = SCNNode(geometry: sideWallGeometry)
        leftWall.position = SCNVector3(-traySize/2, wallHeight/2 - 0.1, 0)
        leftWall.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(leftWall)

        let rightWall = SCNNode(geometry: sideWallGeometry)
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

