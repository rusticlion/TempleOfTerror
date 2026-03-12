import SceneKit
import UIKit

class DieNode {
    var node: SCNNode
    /// The node containing the visible dice geometry.
    /// Stored so materials can be modified later for highlighting.
    var visualNode: SCNNode
    var value: Int = 1
    var isPushed: Bool = false

    // Smaller to keep 3+ dice readable in the tray.
    private let defaultScale: Float = 0.0052
    private var calculatedEffectiveSideLength: CGFloat = 0.8
    private var baseVisualScale: SCNVector3 = SCNVector3(1, 1, 1)

    private var isHighlighted: Bool = false
    private var isCriticalHighlight: Bool = false
    private let highlightActionKey = "die-highlight-pulse"

    /// Containment radius used by tray bounds logic.
    /// Uses near half-diagonal coverage so a tumbling cube stays inside bounds.
    var containmentRadius: Float {
        Float(calculatedEffectiveSideLength) * 0.90
    }

    init() {
        self.node = SCNNode()
        self.visualNode = SCNNode()

        if let sceneURL = Bundle.main.url(forResource: "dice", withExtension: "usdz"),
           let diceScene = try? SCNScene(url: sceneURL, options: nil) {

            let visualNode = SCNNode()
            for child in diceScene.rootNode.childNodes {
                visualNode.addChildNode(child.clone())
            }
            visualNode.scale = SCNVector3(defaultScale, defaultScale, defaultScale)
            self.visualNode = visualNode
            self.baseVisualScale = visualNode.scale
            self.node.addChildNode(visualNode)

            let tempMeasureNode = SCNNode()
            if let tempSceneURL = Bundle.main.url(forResource: "dice", withExtension: "usdz"),
               let tempDiceScene = try? SCNScene(url: tempSceneURL, options: nil) {
                for child in tempDiceScene.rootNode.childNodes {
                    tempMeasureNode.addChildNode(child.clone())
                }
            }

            let tempSceneForMeasurement = SCNScene()
            tempSceneForMeasurement.rootNode.addChildNode(tempMeasureNode)
            let (unscaledMin, unscaledMax) = tempMeasureNode.presentation.boundingBox

            let unscaledWidth = unscaledMax.x - unscaledMin.x
            let unscaledHeight = unscaledMax.y - unscaledMin.y
            let unscaledLength = unscaledMax.z - unscaledMin.z

            if unscaledWidth > 0 {
                let scaledWidth = CGFloat(unscaledWidth * defaultScale)
                let scaledHeight = CGFloat(unscaledHeight * defaultScale)
                let scaledLength = CGFloat(unscaledLength * defaultScale)
                self.calculatedEffectiveSideLength = max(scaledWidth, scaledHeight, scaledLength)
            } else if visualNode.geometry != nil {
                let (minBounds, maxBounds) = visualNode.boundingBox
                let visualWidth = maxBounds.x - minBounds.x
                let visualHeight = maxBounds.y - minBounds.y
                let visualLength = maxBounds.z - minBounds.z
                self.calculatedEffectiveSideLength = CGFloat(max(visualWidth, visualHeight, visualLength))
            }

            let cubeGeometry = SCNBox(
                width: calculatedEffectiveSideLength,
                height: calculatedEffectiveSideLength,
                length: calculatedEffectiveSideLength,
                chamferRadius: calculatedEffectiveSideLength * 0.05
            )
            let shape = SCNPhysicsShape(geometry: cubeGeometry, options: nil)

            let body = SCNPhysicsBody(type: .dynamic, shape: shape)
            body.continuousCollisionDetectionThreshold = 0.001
            body.mass = 0.45
            body.friction = 0.72
            body.restitution = 0.16
            body.rollingFriction = 0.62
            body.damping = 0.18
            body.angularDamping = 0.18
            self.node.physicsBody = body

            configureVisualMaterials()
        } else {
            let fallbackBox = SCNBox(
                width: calculatedEffectiveSideLength,
                height: calculatedEffectiveSideLength,
                length: calculatedEffectiveSideLength,
                chamferRadius: 0.05
            )
            fallbackBox.firstMaterial?.lightingModel = .physicallyBased
            fallbackBox.firstMaterial?.diffuse.contents = UIColor(white: 0.88, alpha: 1)
            fallbackBox.firstMaterial?.roughness.contents = 0.25
            fallbackBox.firstMaterial?.metalness.contents = 0.05

            let v = SCNNode(geometry: fallbackBox)
            self.visualNode = v
            self.baseVisualScale = v.scale
            self.node.addChildNode(v)
        }
    }

    func prepareForRoll(at position: SCNVector3) {
        node.position = position
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
            a.x * b.x + a.y * b.y + a.z * b.z
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

    private func traverse(node: SCNNode, apply: (SCNMaterial) -> Void) {
        if let materials = node.geometry?.materials {
            for m in materials {
                apply(m)
            }
        }
        for child in node.childNodes {
            traverse(node: child, apply: apply)
        }
    }

    private func configureVisualMaterials() {
        traverse(node: visualNode) { material in
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.3
            material.metalness.contents = 0.06
            material.specular.contents = UIColor(white: 1, alpha: 0.35)
        }
    }

    private func scaled(_ scale: SCNVector3, by factor: Float) -> SCNVector3 {
        SCNVector3(scale.x * factor, scale.y * factor, scale.z * factor)
    }

    private func restingScale() -> SCNVector3 {
        scaled(baseVisualScale, by: isPushed ? 1.03 : 1.0)
    }

    private func applyIdleVisualState(animated: Bool) {
        visualNode.removeAction(forKey: highlightActionKey)

        if isPushed {
            setEmissiveColor(UIColor(red: 0.80, green: 0.62, blue: 0.26, alpha: 1))
        } else {
            setEmissiveColor(nil)
        }

        let target = restingScale()
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.14
            visualNode.scale = target
            SCNTransaction.commit()
        } else {
            visualNode.scale = target
        }
    }

    func setHighlighted(_ highlighted: Bool, critical: Bool = false) {
        isHighlighted = highlighted
        isCriticalHighlight = highlighted && critical

        if highlighted {
            let emissive = critical
                ? UIColor(red: 1.0, green: 0.90, blue: 0.58, alpha: 1)
                : UIColor(red: 1.0, green: 0.85, blue: 0.42, alpha: 1)
            setEmissiveColor(emissive)
            visualNode.removeAction(forKey: highlightActionKey)

            let base = scaled(restingScale(), by: critical ? 1.12 : 1.08)
            let peak = scaled(restingScale(), by: critical ? 1.22 : 1.18)
            let restingHighlight = scaled(restingScale(), by: critical ? 1.14 : 1.10)
            visualNode.scale = base

            let pulseUp = SCNAction.scale(to: CGFloat(peak.x), duration: 0.12)
            pulseUp.timingMode = .easeInEaseOut
            let pulseDown = SCNAction.scale(to: CGFloat(base.x), duration: 0.16)
            pulseDown.timingMode = .easeInEaseOut
            let settle = SCNAction.scale(to: CGFloat(restingHighlight.x), duration: 0.16)
            settle.timingMode = .easeInEaseOut
            let pulse = SCNAction.sequence([pulseUp, pulseDown, settle])
            visualNode.runAction(pulse, forKey: highlightActionKey)
        } else {
            applyIdleVisualState(animated: true)
        }
    }

    func setEmissiveColor(_ color: UIColor?) {
        traverse(node: visualNode) { material in
            material.emission.contents = color
        }
    }

    func setOpacity(_ opacity: CGFloat) {
        visualNode.opacity = opacity
    }

    func markPushed(_ pushed: Bool) {
        isPushed = pushed

        if isHighlighted {
            setHighlighted(true, critical: isCriticalHighlight)
        } else {
            applyIdleVisualState(animated: true)
        }
    }
}
