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

    /// Determine which face is pointing upward based on the node's orientation.
    func updateValueFromOrientation() {
        let transform = node.presentation.worldTransform
        let worldUp = SCNVector3(0, 1, 0)

        func dot(_ a: SCNVector3, _ b: SCNVector3) -> Float {
            return a.x * b.x + a.y * b.y + a.z * b.z
        }

        let xPos = SCNVector3(transform.m11, transform.m12, transform.m13)
        let yPos = SCNVector3(transform.m21, transform.m22, transform.m23)
        let zPos = SCNVector3(transform.m31, transform.m32, transform.m33)

        let axes: [(SCNVector3, Int)] = [
            (yPos, 5),
            (SCNVector3(-yPos.x, -yPos.y, -yPos.z), 2),
            (xPos, 4),
            (SCNVector3(-xPos.x, -xPos.y, -xPos.z), 3),
            (SCNVector3(-zPos.x, -zPos.y, -zPos.z), 6),
            (zPos, 1)
        ]

        var bestVal = 1
        var bestDot: Float = -Float.infinity

        for (vec, val) in axes {
            let d = dot(vec, worldUp)
            if d > bestDot {
                bestDot = d
                bestVal = val
            }
        }

        self.value = bestVal
    }
}
