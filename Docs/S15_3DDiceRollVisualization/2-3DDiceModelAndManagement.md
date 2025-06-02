Task 2: 3D Dice Models, Textures, and Instantiation
Description: Import or create 3D dice models, apply textures for faces, and implement logic to dynamically add the correct number of dice to the SceneKit scene.

Actions:

Acquire/Create 3D Dice Model:
Source a low-polygon 3D model of a standard six-sided die (e.g., in .usdz, .scn, or .obj format). Ensure its geometry allows for distinct materials/textures per face.
Add the model file to the project's Assets.xcassets or a dedicated 3D assets folder.
Create Dice Face Textures:
Design six image textures, one for each die face (1 through 6 pips). Ensure clarity and thematic consistency with the game's art style.
Add these textures to Assets.xcassets.
Develop DieNode.swift (Subclass of SCNNode or Helper Struct):
Create a reusable way to construct a die node.
This class/struct should:
Load the 3D die model.
Have a method to apply the six face textures to the correct materials of the loaded model. Each material corresponds to a face.
Store its current numerical value (to be determined in Task 4).
Update SceneKitDiceView.swift:
Add a property to hold an array of DieNode (or your custom die representation) instances.
In makeUIView or a new setup method:
Based on an input parameter (e.g., numberOfDice), instantiate the required number of DieNode objects.
Position these dice initially above the tray floor, ready to be dropped.
Add each die node to the scene.rootNode.
Pass the diceValues.count (derived from projection.finalDiceCount in DiceRollView.onAppear) to SceneKitDiceView to determine how many dice to show.
Asset Callouts:

3D Model: model_d6_dice.usdz (or other format): A standard six-sided die.
Textures (Faces):
texture_d6_face_1.png
texture_d6_face_2.png
texture_d6_face_3.png
texture_d6_face_4.png
texture_d6_face_5.png
texture_d6_face_6.png
Canvas Size: e.g., 128x128 pixels per face texture.