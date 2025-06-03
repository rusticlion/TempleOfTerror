Task 2: 3D Dice Model Integration and Instantiation
Description: Integrate the provided dice.usdz model and implement logic to dynamically add the correct number of dice instances to the SceneKit scene. Custom texturing is deferred if the default model appearance is acceptable.

Actions:

Integrate dice.usdz Model:
Add the dice.usdz file to the project bundle (e.g., in a "3DAssets" group, ensuring "Copy items if needed" and target membership are checked), not directly into Assets.xcassets if it caused issues.
Develop DieNode.swift (or similar helper structure/class):
This class/struct will be responsible for:
Loading the die model from dice.usdz. This involves loading the scene from the USDZ file and then extracting the specific SCNNode that represents the die geometry (e.g., by name or by traversing the loaded scene's node hierarchy).
Storing its current numerical value (to be determined in Task 4).
Holding a reference to its SCNNode instance.
(Deferred) Applying custom face textures: If the default appearance of dice.usdz is sufficient for now, applying custom textures like texture_d6_face_1.png can be deferred.
Update SceneKitDiceView.swift:
Add a property to hold an array of DieNode (or your custom die representation) instances.
In makeUIView or a new setup method:
Based on an input parameter (e.g., numberOfDice), instantiate the required number of DieNode objects. Each DieNode will load/clone its 3D model from the dice.usdz.
Position these dice initially above the tray floor.
Add each die's SCNNode to the scene.rootNode.
Pass the diceValues.count (derived from projection.finalDiceCount in DiceRollView.onAppear) to SceneKitDiceView to determine how many dice to show.
Asset Callouts:

3D Model: dice.usdz (Provided by user).
(Deferred Textures) texture_d6_face_1.png to texture_d6_face_6.png: Custom face textures are optional for the initial 3D implementation if the dice.usdz default appearance is acceptable.