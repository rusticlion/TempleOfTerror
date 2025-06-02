Task 3: Implementing Physics-Based Rolling
Description: Add physics to the dice and the tray. Implement a mechanism to "roll" the dice by applying forces, allowing them to tumble and settle realistically.

Actions:

Add Physics Bodies in DieNode.swift (or setup in SceneKitDiceView):
For each die SCNNode, create and assign an SCNPhysicsBody.
Type: .dynamic.
Shape: Use SCNPhysicsShape created from the die's geometry (or a slightly simplified convex hull/box shape for performance if needed).
Properties: Experiment with and set initial values for mass, friction, restitution (bounciness), rollingFriction, and angularDamping/damping.
Implement Roll Trigger in SceneKitDiceView.swift:
Add a public method, e.g., rollDice().
When rollDice() is called:
For each die node:
Reset its position to slightly above the tray floor, spread out a bit.
Apply a random initial linear force or impulse (upwards and sideways).
Apply a random initial torque (angular force) to make them spin.
Ensure physics is active for these dice.
Connect to DiceRollView.swift:
When the "Roll the Dice!" button is tapped in DiceRollView.swift:
Call the rollDice() method on the SceneKitDiceView instance.
The existing startShaking() logic (sound, vignette) can be repurposed or timed to coincide with the 3D roll initiation.