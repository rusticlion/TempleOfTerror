Ticket 2: The High-Stakes Dice Roll
Description: The dice roll is the moment of truth. We'll make it a physical, multi-stage animation with clear visual feedback, combining several ideas from your brainstorm.

Implementation Plan:

Shake & Roll: In DiceRollView, on button press, trigger a 1-second animation where the dice images are given small, random x/y offsets and rotation effects to "shake."
Highlight Result: After the performAction logic runs, instead of just showing the text, we'll start a new animation.
The dice that did not contribute to the highest roll will have their opacity animated to 0.5.
The single highest-rolling die will animate its scale to 1.3x and back down to 1.0x (a "pop" effect) and gain a temporary glow using .shadow(color: .cyan, radius: 10).
Animate Outcome Text: The Text(result.outcome) view will be modified with .transition(.scale.combined(with: .opacity)) and we will wrap its appearance in a withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) block to make it pop onto the screen.
Asset Callouts:

Audio:
sfx_dice_shake.wav: A short, lo-fi rattling sound.
sfx_dice_land.wav: A single sharp "clack" sound.
sfx_ui_pop.wav: A satisfying "pop" to accompany the highest die and result text scaling up.
Visual:
vfx_damage_vignette.png: A full-screen, mostly transparent PNG. The edges should have a dithered red or black pattern. We can flash this on screen for a split second along with the shake to amplify the effect.
Canvas Size: 1024x1024 pixels. (A large square allows it to be scaled to fit any device screen without distortion.)