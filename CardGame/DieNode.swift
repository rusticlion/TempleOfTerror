import SceneKit

class DieNode {
    var node: SCNNode
    var value: Int = 1
    private let defaultScale: Float = 0.01
    private var calculatedEffectiveSideLength: CGFloat = 0.8 // Default fallback

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
            
            // --- Calculate effective side length from the scaled visualNode ---
                    // To get accurate bounds, the node needs to be part of a scene graph
                    // or have its geometry explicitly flattened if it's complex.
                    // A simpler way is to calculate from unscaled, then apply scale.

                    // Create a temporary node to measure the unscaled model from USDZ
                    let tempMeasureNode = SCNNode()
                    if let sceneURL = Bundle.main.url(forResource: "dice", withExtension: "usdz"),
                       let tempDiceScene = try? SCNScene(url: sceneURL, options: nil) {
                        for child in tempDiceScene.rootNode.childNodes {
                            tempMeasureNode.addChildNode(child.clone()) // Add all children that constitute the die
                        }
                    } else {
                        // Fallback if USDZ can't be loaded for measurement
                        // This means calculatedEffectiveSideLength will use its default value
                        print("Error: Could not load dice.usdz for measurement. Using default physics size.")
                    }
                    
                    // Force SceneKit to compute the bounding box.
                    // Adding it to a temporary scene and getting presenter node can be more robust.
                    let tempSceneForMeasurement = SCNScene()
                    tempSceneForMeasurement.rootNode.addChildNode(tempMeasureNode)
                    // Using presentation node ensures current transformations are applied if any were pending
                    let (unscaledMin, unscaledMax) = tempMeasureNode.presentation.boundingBox

                    let unscaledWidth = unscaledMax.x - unscaledMin.x
                    let unscaledHeight = unscaledMax.y - unscaledMin.y
                    let unscaledLength = unscaledMax.z - unscaledMin.z

                    if unscaledWidth > 0 { // Check if bounds are valid
                        let scaledWidth = CGFloat(unscaledWidth * defaultScale)
                        let scaledHeight = CGFloat(unscaledHeight * defaultScale)
                        let scaledLength = CGFloat(unscaledLength * defaultScale)

                        // For a die, these should be roughly equal. Take the max to be safe,
                        // or average if you prefer. Or, if you know it's a perfect cube, use one.
                        self.calculatedEffectiveSideLength = max(scaledWidth, scaledHeight, scaledLength)
                        
                        print("DieNode: Unscaled Visual Dimensions (from USDZ): W:\(unscaledWidth), H:\(unscaledHeight), L:\(unscaledLength)")
                        print("DieNode: Applied Scale: \(defaultScale)")
                        print("DieNode: Calculated Scaled Visual Dimensions: W:\(scaledWidth), H:\(scaledHeight), L:\(scaledLength)")
                        print("DieNode: Using Effective Side Length for Physics: \(self.calculatedEffectiveSideLength)")
                    } else if visualNode.geometry != nil { // Fallback for the fallback visual box if USDZ failed
                        let (minBounds, maxBounds) = visualNode.boundingBox // visualNode is already scaled here
                        let visualWidth = maxBounds.x - minBounds.x
                        let visualHeight = maxBounds.y - minBounds.y
                        let visualLength = maxBounds.z - minBounds.z
                        self.calculatedEffectiveSideLength = CGFloat(max(visualWidth, visualHeight, visualLength))
                        print("DieNode: Using dimensions from fallback visual geometry: \(self.calculatedEffectiveSideLength)")
                    }
            // --- End of calculation ---

            // Simple cube physics shape matching the final scaled size
            let cubeGeometry = SCNBox(
                width: calculatedEffectiveSideLength,
                height: calculatedEffectiveSideLength,
                length: calculatedEffectiveSideLength,
                chamferRadius: calculatedEffectiveSideLength * 0.05
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
            let fallbackBox = SCNBox(width: calculatedEffectiveSideLength, height: calculatedEffectiveSideLength, length: calculatedEffectiveSideLength, chamferRadius: 0.05)
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
            (SCNVector3(-zPos.x, -zPos.y, -zPos.z), 1),
            (zPos, 6)
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
