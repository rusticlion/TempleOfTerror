Task 6: Visual Polish, Feedback, and Sound Sync
Description: Refine the 3D dice roll visuals, integrate existing feedback mechanisms (like highlighting the highest die and pushed dice), and synchronize sound effects.

Actions:

Highlight Highest Die in 3D:
After results are read, identify the 3D DieNode that corresponds to the result.highestRoll.
In SceneKitDiceView, apply a visual effect to this die:
Change its material's emission property to make it glow (e.g., with a cyan color).
Optionally, add a subtle scaling animation or a temporary spotlight focused on it.
The popScale animation in DiceRollView might need to be rethought or removed if the 3D effect is sufficient.
Represent Pushed Dice:
If extraDiceFromPush > 0, visually distinguish the pushed die/dice in the 3D scene before the roll.
This could be a different initial color/texture, or a subtle emissive glow. SceneKitDiceView will need to be aware of which dice are "pushed."
Fade Other Dice:
The fadeOthers logic in DiceRollView (setting opacity of non-highlighted 2D dice to 0.5) should be replicated for the 3D dice.
Non-highlighted DieNode instances can have their opacity property animated or their materials made more transparent.
Sound Synchronization:
sfx_dice_shake.wav: Play when the 3D dice begin their roll animation.
sfx_dice_land.wav: Might need to be triggered multiple times as individual dice settle, or once when all dice are mostly still. SceneKit's physics contact delegates could be used for more precise sound timing if desired.
sfx_ui_pop.wav: Play when the highest die is highlighted in 3D and/or when the result.outcome text animates in.
Vignette Effect:
The showVignette and Image("vfx_damage_vignette") can still be used, timed with the initiation of the 3D roll.
Camera Polish (Optional):
Consider a subtle camera animation during the roll (e.g., a slight zoom in, a gentle shake).