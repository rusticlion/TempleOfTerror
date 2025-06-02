Task 4: Reading Dice Results from the 3D Scene
Description: Develop a reliable method to determine the numerical value of the "up" face of each die after it has come to rest in the 3D scene.

Actions:

Detect Settled State:
In SceneKitDiceView.swift, within the SCNSceneRendererDelegate method renderer(_:updateAtTime:) (or a similar update loop):
Monitor the isResting property of each die's SCNPhysicsBody.
Alternatively, check if their linear and angular velocities are below a small threshold for a certain duration.
Implement a callback or a binding that SceneKitDiceView can use to notify DiceRollView when all dice have settled.
Determine "Up" Face:
For each die node, once settled:
Analyze its final transform or orientation (quaternion).
Determine which of its local axes (e.g., +Y, -Y, +X, etc.) is most closely aligned with the world's "up" vector (e.g., SCNVector3(0, 1, 0)).
This will require knowing how the die model's faces are oriented relative to its local axes. For example, if face "6" is on the local +Y axis of the model, and the die lands with its local +Y pointing upwards in world space, then "6" is the result.
Map this determined "up" face to its numerical value (1-6). This might involve pre-defining which texture/material corresponds to which face value during DieNode setup.
Store Results:
Store the determined numerical value for each die within its DieNode instance or a separate array in SceneKitDiceView.
Once all dice are settled and read, the array of these results will be the actualDiceRolled.