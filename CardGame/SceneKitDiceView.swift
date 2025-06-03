import SwiftUI
import SceneKit

struct SceneKitDiceView: UIViewRepresentable {
    let diceCount: Int

    class Coordinator {
        var dice: [DieNode] = []
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let scene = SCNScene()
        scnView.scene = scene

        // Camera looking down into the tray
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 5)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 4, 0, 0)
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
        let floor = SCNBox(width: 10, height: 0.2, length: 10, chamferRadius: 0)
        floor.firstMaterial?.diffuse.contents = UIImage(named: "texture_dicetray_surface")
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -0.1, 0)
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)

        scnView.isPlaying = true
        scnView.allowsCameraControl = true

        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)

        // Add dice nodes
        for _ in 0..<diceCount {
            let die = DieNode()
            die.node.position = SCNVector3(
                Float.random(in: -4...4),
                1.0,
                Float.random(in: -4...4)
            )
            scene.rootNode.addChildNode(die.node)
            context.coordinator.dice.append(die)
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }

        if context.coordinator.dice.count < diceCount {
            for _ in context.coordinator.dice.count..<diceCount {
                let die = DieNode()
                die.node.position = SCNVector3(
                    Float.random(in: -4...4),
                    1.0,
                    Float.random(in: -4...4)
                )
                scene.rootNode.addChildNode(die.node)
                context.coordinator.dice.append(die)
            }
        } else if context.coordinator.dice.count > diceCount {
            while context.coordinator.dice.count > diceCount {
                let die = context.coordinator.dice.removeLast()
                die.node.removeFromParentNode()
            }
        }
    }
}

