Task 4: Reading Dice Results from the 3D Scene
Description: Develop a reliable method to determine the numerical value of the "up" face of each die after it has come to rest, using the user-provided perspective-to-face mapping.

Actions:

Detect Settled State:
In SceneKitDiceView.swift (e.g., in renderer(_:updateAtTime:)), monitor each die's SCNPhysicsBody for isResting or near-zero velocity.
Signal DiceRollView when all dice have settled.
Determine "Up" Face and Value for Each Die:
Once a die SCNNode has settled, get its worldTransform.
Define the world "up" vector: worldUp = SCNVector3(0, 1, 0).
Extract the world-space directions of the die's local positive and negative X, Y, and Z axes from its worldTransform matrix.
Local +X: SCNVector3(transform.m11, transform.m12, transform.m13)
Local +Y: SCNVector3(transform.m21, transform.m22, transform.m23)
Local +Z: SCNVector3(transform.m31, transform.m32, transform.m33)
(And their negatives by negating components).
Calculate the dot product of each of these six world-space local-axis-directions with worldUp.
The local axis direction yielding the highest dot product is the one most pointing "up."
Use the user-provided mapping to convert this "winning" local axis direction to a face value:
Local +Y up: Face 5
Local -Y up: Face 2
Local +X up: Face 4
Local -X up: Face 3
Local -Z up: Face 6
Local +Z up: Face 1
Store Results:
Store the determined numerical value for each die.
Once all dice are settled and read, this array of results becomes the actualDiceRolled.