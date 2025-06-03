import SceneKit

class DieNode {
    var node: SCNNode
    var value: Int = 1
    private let defaultScale: Float = 0.01

    init() {
        if let sceneURL = Bundle.main.url(forResource: "dice", withExtension: "usdz"),
           let diceScene = try? SCNScene(url: sceneURL, options: nil) {
            let container = SCNNode()
            for child in diceScene.rootNode.childNodes {
                container.addChildNode(child.clone())
            }
            container.scale = SCNVector3(defaultScale, defaultScale, defaultScale)
            let shape = SCNPhysicsShape(node: container, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull])
            let body = SCNPhysicsBody(type: .dynamic, shape: shape)
            body.continuousCollisionDetectionThreshold = 0.001
            body.mass = 1.0
            body.friction = 0.8
            body.restitution = 0.2
            body.rollingFriction = 0.5
            body.damping = 0.5
            body.angularDamping = 0.8
            container.physicsBody = body
            self.node = container
        } else {
            // Fallback to an empty node if the model can't be loaded
            let node = SCNNode()
            node.scale = SCNVector3(defaultScale, defaultScale, defaultScale)
            self.node = node
        }
    }

    func prepareForRoll(at position: SCNVector3) {
        node.position = position
        node.eulerAngles = SCNVector3Zero
        node.physicsBody?.clearAllForces()
        node.physicsBody?.velocity = SCNVector3Zero
        node.physicsBody?.angularVelocity = SCNVector4Zero
    }
}
