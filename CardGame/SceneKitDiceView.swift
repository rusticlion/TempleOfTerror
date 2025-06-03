import SwiftUI
import SceneKit

struct SceneKitDiceView: UIViewRepresentable {
    let diceCount: Int

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

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Future updates will add dice here
    }
}

