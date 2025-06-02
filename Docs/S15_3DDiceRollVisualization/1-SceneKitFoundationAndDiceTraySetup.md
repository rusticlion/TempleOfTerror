Task 1: SceneKit Foundation & Dice Tray Setup
Description: Establish the basic SceneKit view within the existing DiceRollView and create the foundational "dice tray" environment.

Actions:

Project Configuration:
Ensure the SceneKit framework is linked in the project.
Create SceneKitDiceView.swift:
Implement a new SwiftUI UIViewRepresentable struct named SceneKitDiceView.
This struct will wrap an SCNView.
makeUIView(context:):
Initialize an SCNView.
Create an SCNScene.
Set up a basic camera pointed downwards at an angle (like looking into a dice tray).
Add ambient and omnidirectional lighting for good visibility.
Create a large, flat SCNNode with an SCNPlane or SCNBox geometry to act as the "floor" or "tray surface." Assign a static SCNPhysicsBody to this floor.
Assign the scene to the SCNView.
Enable isPlaying and allowsCameraControl (for debugging, can be turned off later).
updateUIView(_:context:):
Initially, this can be empty. It will later be used to update the dice based on view model state.
Initial Integration into DiceRollView.swift:
In DiceRollView.swift, temporarily replace the HStack displaying the 2D dice Image views with an instance of SceneKitDiceView.
Pass necessary initial parameters to SceneKitDiceView (e.g., the number of dice to display, though actual dice will be added in Task 2).
Asset Callouts:

(Optional Texture) texture_dicetray_surface.png: A subtle texture for the floor of the dice tray (e.g., felt, wood, stone). Canvas Size: 512x512 pixels (tileable).