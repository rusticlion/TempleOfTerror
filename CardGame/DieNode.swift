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
            self.node = container
        } else {
            // Fallback to an empty node if the model can't be loaded
            let node = SCNNode()
            node.scale = SCNVector3(defaultScale, defaultScale, defaultScale)
            self.node = node
        }
    }
}
